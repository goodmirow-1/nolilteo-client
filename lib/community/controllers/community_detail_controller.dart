import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import 'package:gallery_saver/gallery_saver.dart';
import 'package:get/get.dart';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:nolilteo/community/community_detail_page.dart';
import 'package:nolilteo/community/controllers/board_controller.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/get_extended_image.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/meeting/controller/meeting_controller.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:nolilteo/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';
import 'package:nolilteo/share/share_link.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import '../../community/controllers/community_controller.dart';
import '../../config/analytics.dart';
import '../../config/global_function.dart';
import '../../data/global_data.dart';

import '../../config/constants.dart';
import '../../home/main_page.dart';
import '../community_write_or_modify_page.dart';
import '../models/post.dart';
import '../models/reply.dart';


class ContentsWithURL{
  String contents = '';
  bool isURL = false;
}

class CommunityDetailController extends GetxController {
  CommunityDetailController({required this.tag});

  final String tag;

  static get to => Get.find<CommunityDetailController>();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final Duration duration = const Duration(milliseconds: 300);
  final Curve curve = Curves.ease;
  final double replyItemHeight = 58 * sizeUnit;
  final bool isRegistered = Get.isRegistered<CommunityController>();
  final int replyMaxLength = 500; // 댓글, 답글 최대 길이

  late bool isMeeting;
  late Post post; // 포스트
  late MeetingPost meetingPost; //모임 포스트
  late List<Reply> replyList; // 댓글 리스트

  bool fetchLoading = true;

  bool canLikeEvent = true; // 좋아요 가능 여부
  RxBool rxIsWriteReply = false.obs; // 댓글 썼는지 여부
  RxBool showWebOptionsBox = false.obs; // 웹에서 옵션 박스 보여주기 여부

  RxString replyContents = ''.obs; // 댓글 or 답글 내용
  RxList<int> showReplyReplyList = <int>[].obs; // 답글 보기 리스트
  Rx<Reply> selectedReply = Reply.nullReply.obs; // 답글 달기 위해 선택된 댓글
  Rx<Reply> selectedModifyReply = Reply.nullReply.obs; // 수정 하기 위해 선택된 댓글

  bool participantsLoading = true; // 참여자 페이지 로딩
  bool isParticipation = true; // 참여한 모임인지

  bool canScrollEvent = true; // 스크롤 중복 호출 방지

  List<String> contentsList = [];
  List<ContentsWithURL> contentsWithURLList = [];
  List<PreviewData?> previewDataList = [];

  @override
  void onInit() {
    super.onInit();

    GlobalData.detailPageCount++;
    scrollController.addListener(() => maxScrollEvent());
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        if (GlobalData.loginUser.id == nullInt) focusNode.unfocus();
        GlobalFunction.loginCheck(callback: () {});
      }
    });
  }

  @override
  void onClose() {
    super.onClose();

    textEditingController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    GlobalData.detailPageCount--;
  }

  // 데이터 세팅
  Future<void> fetchData(bool isMeeting) async {
    final int id = int.parse(Get.parameters['id'] ?? nullInt.toString());
    this.isMeeting = isMeeting;

    if (id < 0) {
      GlobalFunction.showToast(msg: '유효하지 않은 게시글입니다.');
      return Get.offAllNamed(MainPage.route);
    }
    await GlobalFunction.setLoginData(); // 로그인 데이터 세팅

    Post? post = await PostRepository.getPostByID(id);

    if (post != null) {
      if (post.deleteType != 0) {
        showCustomDialog(
            title: '삭제된 게시글입니다.',
            okText: '확인',
            okFunc: () {
              GlobalFunction.syncDeletedPost(post.id); // 삭제 동기화
              Get.close(2); // 다이어로그 끄기, 메인페이지로
            });
      }

      this.post = post; // 게시글 세팅
      if (post.type == Post.postTypeMeeting) {
        meetingPost = post as MeetingPost;
        isParticipation = meetingPost.userID == GlobalData.loginUser.id ? true : meetingPost.meetingMembers.contains(GlobalData.loginUser.id); // 참여한 모임인지
      }
    } else {
      GlobalFunction.showToast(msg: '유효하지 않은 게시글입니다.');
      return Get.offAllNamed(MainPage.route);
    }

    rxIsWriteReply(post.isWriteReply); // 댓글 썼는지
    replyList = await PostRepository.getReplyListByID(id: post.id); // 댓글 세팅

    GlobalData.hotListByHour(await PostRepository.getHotPostListByHour()); // 시간별 핫 리스트 세팅
    GlobalData.popularListByRealTime(await PostRepository.getPopularListByRealTime()); // 실시간 인기 리스트 세팅

    NolAnalytics.logEvent(name: 'post_detail', parameters: {'postID': post.id, 'type': post.type}); // 애널리틱스 글 디테일

    contentsList = GlobalFunction.checkURLList(post.contents);

    if(contentsList.isNotEmpty){
      contentsWithURLList = generateContentsWithURL(contentsList, post.contents);
      previewDataList = List.generate(contentsWithURLList.length, (index) => null);
    }

    fetchLoading = false;
    update();
  }

  List<ContentsWithURL> generateContentsWithURL(List<String> urlList, String description){
    int startIndex = 0;
    List<ContentsWithURL> list = [];
    for(var i = 0 ; i < urlList.length; ++i){
      var pos = description.indexOf(urlList[i]);

      ContentsWithURL urlCheck = ContentsWithURL();
      urlCheck.contents = description.substring(startIndex,pos);
      urlCheck.isURL = false;
      list.add(urlCheck);

      ContentsWithURL urlCheck2 = ContentsWithURL();
      urlCheck2.contents = urlList[i];
      urlCheck2.isURL = true;
      list.add(urlCheck2);

      startIndex = pos + urlList[i].length;
    }

    if(description.length > startIndex){
      ContentsWithURL urlCheck = ContentsWithURL();
      urlCheck.contents = description.substring(startIndex, description.length);
      urlCheck.isURL = false;

      list.add(urlCheck);
    }

    return list;
  }

  // 글 삭제
  void deletePost() async {
    if (isMeeting) if (meetingPost.meetingMembers.length > 1) return GlobalFunction.showToast(msg: '참여자가 있는 상태에서는 삭제할 수 없어요.');

    bool? result = await PostRepository.delete(id: post.id, postType: PostRepository.postType); // 게시글 삭제

    if (result != null && result) {
      GlobalFunction.syncDeletedPost(post.id); // 게시글 삭제 동기화

      if (Get.isRegistered<BoardController>()) {
        Get.close(3); // 다이어로그, 바텀시트, 디테일 페이지 닫기 -> 게시판 페이지로 이동
      } else {
        GlobalFunction.goToMainPage(); // 메인 페이지로 이동
      }

      GlobalFunction.showToast(msg: '삭제되었습니다.');
      NolAnalytics.logEvent(name: 'post_delete', parameters: {'postID': post.id, 'type': post.type}); // 애널리틱스 글삭제
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }
  }

  // 글 수정
  void modifyPost() {
    if(kIsWeb) {
      showWebOptionsBox(false); // 옵션 박스 끄기
    } else {
      Get.back(); // 바텀 시트 끄기
    }
    Get.to(() => CommunityWriteOrModifyPage(
              isWrite: false,
              post: post,
              type: post.type,
              meetingPost: isMeeting ? meetingPost : null,
            ))!
        .then((value) {
      if (value != null) {
        post = value;
        if (isMeeting) meetingPost = value;

        contentsList = GlobalFunction.checkURLList(post.contents);

        if(contentsList.isNotEmpty){
          contentsWithURLList = generateContentsWithURL(contentsList, post.contents);
          previewDataList = List.generate(contentsWithURLList.length, (index) => null);
        }

        update();
      }
    });
  }

  // 사용자 차단
  void userBan(int userID) {
    if (GlobalData.blockedUserIDList.contains(userID)) return GlobalFunction.showToast(msg: '이미 차단한 사용자입니다.');

    // 모여라 참여중인데 방장 차단한 경우
    if (isMeeting && isParticipation && userID == post.userID) {
      showCustomDialog(
        title: '참가중인 모여라를 나가야\n차단이 가능해요',
        okFunc: exitMeeting,
        // 모여라 나가기
        isCancelButton: true,
        okText: '나가기',
        cancelText: '아니오',
      );
      return;
    }

    showCustomDialog(
      title: '이 사용자를 차단하시겠어요?\n게시글과 댓글이 숨김처리됩니다.',
      isCancelButton: true,
      okText: '네',
      cancelText: '아니오',
      okFunc: () async {
        bool? result = await UserRepository.userBan(targetID: userID);

        if (result != null && result) {
          GlobalData.blockedUserIDList.add(userID); // 차단 리스트에 추가

          // 차단한 사용자의 게시글인 경우
          if (userID == post.userID) {
            if (isRegistered) {
              GlobalFunction.goToMainPage(); // 메인 페이지로 이동
              mainPageUpdate(); // 메인 페이지 업데이트
            } else {
              Get.offAllNamed(MainPage.route);
            }
          } else {
            // 차단한 사용자의 게시글이 아닌 경우
            Get.close(2); // 다이어로그, 바텀 시트 끄기
            update();
            if (isRegistered) mainPageUpdate(); // 메인 페이지 업데이트
          }

          GlobalFunction.showToast(msg: '차단되었습니다.');
        } else {
          Get.close(2); // 다이어로그, 바텀 시트 끄기
          GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
        }
      },
    );
  }

  // 댓글, 답글 삭제
  void deleteReply({required Reply reply, required int replyType}) async {
    bool? result = await PostRepository.delete(id: reply.id, postType: replyType); // 댓글 삭제

    if (result != null && result) {
      reply.deleteType = deleteTypeUser;
      GlobalFunction.showToast(msg: '삭제되었습니다.');
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }

    Get.close(2); // 다이어로그, 바텀 시트 끄기
    update();
  }

  // 댓글 쓰기
  Future<void> writeReply(bool agree) async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');
    textEditingController.clear();
    focusNode.unfocus();

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('agree', agree);

    Reply? reply = await PostRepository.writeReply(id: post.id, contents: GlobalFunction.controlSpace(replyContents.value), agree: agree);
    replyContents('');

    if (reply != null) {
      List<Reply> replyList = await PostRepository.getReplyListByID(id: post.id, index: this.replyList.length, limit: 9999); // 댓글 다 불러오기
      this.replyList.addAll(replyList); // 댓글 추가
      post.repliesLength = this.replyList.length; // 갯수 동기화
      if (!isMeeting) {
        post.isWriteReply = true;
        rxIsWriteReply(true);
        GlobalData.changedPost = post; // 게시글 동기화
      }

      if (agree) {
        post.isSubscribe = true;
      }

      update();

      // 스크롤 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 답글 쓰기
  Future<void> writeReplyReply() async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');
    textEditingController.clear();
    focusNode.unfocus();

    ReplyReply? resultReplyReply = await PostRepository.writeReplyReply(replyID: selectedReply.value.id, contents: replyContents.value);
    replyContents('');

    if (resultReplyReply != null) {
      for (Reply reply in replyList) {
        if (selectedReply.value.id == reply.id) {
          reply.replyReplyList.add(resultReplyReply);
          if (!showReplyReplyList.contains(reply.id)) showReplyReplyList.add(reply.id); // 답글 보이기
          break;
        }
      }

      update();

      // 스크롤 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.offset + selectedReply.value.replyReplyList.length * replyItemHeight);
        selectedReply(Reply.nullReply);
      });
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 답글 텍스트 필드 열기
  void openReplyReplyTextField(Reply reply) {
    selectedModifyReply(Reply.nullReply); // 수정 하기 끄기
    selectedReply(reply); // 선택된 댓글 세팅
    focusNode.requestFocus();
  }

  // 새로고침
  void onRefresh() async {
    Post? post = await PostRepository.getPostByID(this.post.id);
    canScrollEvent = true; // 스크롤 이벤트 허용

    if (post != null) {
      this.post = post;
      if (isMeeting) meetingPost = post as MeetingPost;
      GlobalData.changedPost = post; // 게시글 동기화
    } else {
      return GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }

    // 댓글 새로고침 및 유저 데이터 불러오기
    replyList = await PostRepository.getReplyListByID(id: post.id);

    update();
  }

  //링크보내기
  void goToLink(String url) async {
    if (url.isEmpty) {
      showCustomDialog(title: '연결된 링크가 없습니다.\n모임장에게 문의해 주세요 :)', okText: '확인');

      return;
    }
    if (!await launchUrl(Uri.https(url, ''))) {
      throw '링크 접근에 실패했습니다.';
    }
  }

  // 좋아요 함수
  Future<bool> likeFunc() async {
    if (canLikeEvent) {
      canLikeEvent = false;
      bool? result = await PostRepository.postLike(post.id, post.type);

      if (result != null) {
        post.isLike = result;

        if (post.isLike) {
          post.likesLength++;
        } else {
          post.likesLength--;
        }

        GlobalData.changedPost = post; // 게시글 동기화
      } else {
        GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요');
      }

      canLikeEvent = true;
    }

    return post.isLike;
  }

  // 댓글 좋아요 함수
  Future<bool> replyLikeFunc(Reply reply) async {
    if (canLikeEvent) {
      canLikeEvent = false;

      bool? result = await PostRepository.replyLike(postID: post.id, replyID: reply.id);

      if (result != null) {
        reply.isLike = result;

        if (reply.isLike) {
          reply.likesLength++;
        } else {
          reply.likesLength--;
        }
      } else {
        GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요');
      }

      canLikeEvent = true;
    }

    return reply.isLike;
  }

  // 답글 보기
  void showReplyReply(Reply reply) {
    showReplyReplyList.add(reply.id);

    // 스크롤 이동
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.offset + reply.replyReplyList.length * replyItemHeight,
        duration: duration,
        curve: curve,
      );
    });
  }

  // 참가하기
  void participate() async {
    if (meetingPost.isClosed) return; // 모집 마감된 경우
    if (meetingPost.personnel != null && (meetingPost.personnel! <= meetingPost.meetingMembers.length)) return; // 정원 찬 경우

    bool? result = await PostRepository.participate(meetingPost.meetingID);

    if (result != null && result) {
      meetingPost.meetingMembers.add(GlobalData.loginUser.id); // 참가 리스트에 추가
      isParticipation = true;
    }

    update();
    GlobalData.changedPost = meetingPost; // 게시글 동기화
  }

  // 모여라 나가기
  void exitMeeting() async {
    bool? result = await PostRepository.exitMeeting(meetingPost.meetingID);

    if (result != null && result) {
      meetingPost.meetingMembers.remove(GlobalData.loginUser.id); // 참가 리스트에서 삭제
      isParticipation = false;
      Get.close(2); // 다이어로그, 바텀시트 끄기
      if (Get.isRegistered<CommunityDetailController>()) {
        Get.until((route) => Get.currentRoute == '${CommunityDetailPage.meetingRoute}/${post.id}'); // 디테일 페이지로 이동
      }

      update();
      GlobalData.changedPost = meetingPost; // 게시글 동기화
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }
  }

  // 메인 페이지 업데이트
  void mainPageUpdate() {
    if (isMeeting) {
      MeetingController.to.update();
    } else {
      CommunityController.to.update();
    }
  }

  // 모집 마감
  void closeMeeting() async {
    if (meetingPost.isClosed) return GlobalFunction.showToast(msg: '이미 모집 마감된 모임입니다.');

    bool? result = await PostRepository.closeMeeting(meetingPost.meetingID);

    if (result != null && result) {
      meetingPost.isClosed = true;
      update();

      Get.close(2); // 다이어로그, 바텀시트 끄기
      GlobalFunction.showToast(msg: '참가자 모집이 마감되었습니다.');

      // 모여라 리스트에서 삭제
      if (Get.isRegistered<MeetingController>()) {
        final MeetingController meetingController = Get.find<MeetingController>();
        meetingController.postList.removeWhere((element) => element.id == meetingPost.id);
        meetingController.update();
      }
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해 주세요.');
    }
  }

  bool _isMaxScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return currentScroll == maxScroll;
    // return currentScroll >= (maxScroll * 0.9);
  }

  // 스크롤 이벤트
  void maxScrollEvent() async {
    // 중복 호출 방지
    if (!canScrollEvent) return;

    if (_isMaxScroll(scrollController)) {
      canScrollEvent = false;
      if (this.replyList.isEmpty) return; // 댓글 비어있으면

      List<Reply> replyList = await PostRepository.getReplyListByID(id: post.id, index: this.replyList.length);

      if (replyList.isEmpty) return; // 데이터가 더 이상 없을 경우 호출 못하게 리턴

      this.replyList.addAll(replyList); // 게시글 세팅

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  // 참가자 데이터 받아오기
  void initParticipants() async {
    for (int id in meetingPost.meetingMembers) {
      await GlobalFunction.getFutureUserByID(id);
    }

    participantsLoading = false;
    update(['participants']);
  }

  //공유하기
  void shareButtonFunc() {
    if (isMeeting) {
      shareLink(routeInfo: '${CommunityDetailPage.meetingRoute}/${meetingPost.id}', contents: '모여라: ${post.title}');
    } else {
      shareLink(routeInfo: '${CommunityDetailPage.route}/${post.id}', contents: '게시글: ${post.title}');
    }
  }

  //구독관련
  void insertOrDestroy(bool isCreate) async {
    post.isSubscribe = await PostRepository.subscribeCreateOrDestroy(postID: post.id, isCreate: isCreate);
    update();
  }

  // 프리뷰 데이터 세팅
  void onPreviewDataFetched(PreviewData data, {int index = 0}) {
    previewDataList[index] = data;
    update();
  }

  // 이미지 다이어로그
  void showImageDialog(String url) {
    Get.dialog(
      Column(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Center(
                child: GetExtendedImage(url: url, fit: BoxFit.contain, isZoom: true),
              ),
            ),
          ),
          ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1.6, sigmaY: 1.6),
              child: Container(
                width: double.infinity,
                height: 56 * sizeUnit,
                padding: EdgeInsets.only(right: 24 * sizeUnit),
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2E37).withOpacity(0.6),
                ),
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async{
                      if (kIsWeb) {
                        WebImageDownloader.downloadImageFromWeb(url, name: url.split('/').last);
                      } else {
                        // GallerySaver.saveImage(url).then((value) {
                        //   if(value == true) GlobalFunction.showToast(msg: '사진 저장 완료');
                        // });
                      }
                    },
                    child: SvgPicture.asset(GlobalAssets.svgSave, width: 24 * sizeUnit),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 수정 댓글 텍스트 필드 열기
  void openModifyReplyTextField(Reply reply) {
    selectedReply(Reply.nullReply); // 답글 달기 끄기

    // 선택된 댓글 세팅
    selectedModifyReply(reply);
    textEditingController.text = selectedModifyReply.value.contents;
    replyContents(selectedModifyReply.value.contents);

    focusNode.requestFocus();
  }

  // 댓글 수정
  void modifyReply() async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');

    bool? result = await PostRepository.modifyReply(id: selectedModifyReply.value.id, contents: replyContents.value);

    if (result != null) {
      for (Reply reply in replyList) {
        if (reply.id == selectedModifyReply.value.id) {
          reply.contents = replyContents.value;
          reply.isModify = true;

          textEditingController.clear();
          focusNode.unfocus();
          selectedModifyReply(Reply.nullReply);

          update();
          GlobalFunction.showToast(msg: '수정이 완료되었습니다.');
          break;
        }
      }
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
  }

  // 답글 수정
  void modifyReplyReply() async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');

    bool? result = await PostRepository.modifyReplyReply(id: selectedModifyReply.value.id, contents: replyContents.value);

    if (result != null) {
      bool isFind = false;

      for (Reply reply in replyList) {
        for (ReplyReply replyReply in reply.replyReplyList) {
          if (replyReply.id == selectedModifyReply.value.id) {
            isFind = true;
            replyReply.contents = replyContents.value;
            replyReply.isModify = true;

            textEditingController.clear();
            focusNode.unfocus();
            selectedModifyReply(Reply.nullReply);

            update();
            GlobalFunction.showToast(msg: '수정이 완료되었습니다.');
            break;
          }
        }

        if (isFind) break;
      }
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
  }
}
