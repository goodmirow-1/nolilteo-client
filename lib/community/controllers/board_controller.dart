import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/controllers/community_controller.dart';
import 'package:nolilteo/community/interest_register_page.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:nolilteo/wbti/controller/wbti_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../data/global_data.dart';
import '../../home/main_page.dart';
import '../models/post.dart';

class BoardController extends GetxController {
  BoardController({required this.tag});

  final String tag;

  static get to => Get.find<BoardController>();

  final ScrollController scrollController = ScrollController();
  String category = ''; // 카테고리, 태그 명
  int type = nullInt; // 게시글 타입

  bool isJob = false; // 일터, 놀터 구분
  String? tagInfo;
  List<Post> postList = [];
  List<Post> hotList = [];
  List<String>? interestList; // 인기 게시글 관심목록
  bool isMeeting = false; // 모여라 여부
  bool isShowInterest = false; // 태그 여부
  RxBool isInterest = false.obs; // 관심목록 여부

  bool fetchLoading = true;
  bool canScrollEvent = true;

  @override
  void onInit() {
    super.onInit();

    GlobalData.boardPageCount++;

    scrollController.addListener(() => maxScrollEvent());
  }

  @override
  void onClose() {
    super.onClose();

    GlobalData.boardPageCount--;

    scrollController.dispose();
  }

  // 데이터 세팅
  Future<void> fetchData() async {
    category = GlobalFunction.decodeUrl(Get.parameters['category'] ?? '');
    type = int.parse(Get.parameters['type'] ?? nullInt.toString());
    isMeeting = type == Post.postTypeMeeting;

    if (category.isEmpty || type == nullInt) {
      GlobalFunction.showToast(msg: '유효하지 않은 게시판입니다.');
      return Get.offAllNamed(MainPage.route);
    }

    await GlobalFunction.setLoginData(); // 로그인 데이터 세팅
    await setPostList(); // 게시글 세팅
    GlobalData.hotListByHour(await PostRepository.getHotPostListByHour()); // 시간별 핫 리스트 세팅
    GlobalData.popularListByRealTime(await PostRepository.getPopularListByRealTime()); // 실시간 인기 리스트 세팅

    fetchLoading = false;
    update();
  }

  // 새로고침
  Future<void> onRefresh() async {
    await setPostList();
    update();
  }

  bool _isMaxScroll() {
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

    if (_isMaxScroll()) {
      canScrollEvent = false;
      if (this.postList.isEmpty) return;

      List<Post> postList = [];
      List<Post> hotList = [];

      if (category == '인기 게시글') {
        // 인기 게시글인 경우
        List<String> categoryInterestList = [];
        List<String> tagInterestList = [];

        // wbti 아니고, 커뮤니티 컨트롤러가 살아있으면
        if (type != Post.postTypeWbti && Get.isRegistered<CommunityController>()) {
          final CommunityController communityController = Get.find<CommunityController>();

          // 전체 보기가 아닐 때 관심 목록 세팅
          if (!communityController.isAllView) {
            categoryInterestList = communityController.filteredCategoryList;
            tagInterestList = communityController.filteredTagList;
          }
        }

        late final String categoryText;
        late final String tagText;

        // wbti인 경우
        if (type == Post.postTypeWbti) {
          categoryText = WbtiController.to.selectedWbti.type;
          tagText = '';
        } else {
          categoryText = GlobalFunction.stringListToString(categoryInterestList);
          tagText = GlobalFunction.stringListToString(tagInterestList);
        }

        postList = await PostRepository.getPopularPostList(
          type: type,
          categoryText: categoryText,
          tagText: tagText,
          index: this.postList.length,
        );
      } else if (category[0] == '#') {
        // 태그인 경우
        postList = await PostRepository.getPostList(
          type: type,
          needAll: false,
          tagText: category.replaceFirst('#', ''),
          index: this.postList.length,
        );
      } else {
        // 카테고리인 경우
        postList = await PostRepository.getPostList(
          type: type,
          needAll: false,
          categoryText: category,
          index: this.postList.length,
        );

        if (!isMeeting) {
          hotList = await PostRepository.getHotPostList(
            type: type,
            categoryText: category,
            index: this.hotList.length,
          );
        }

        generatePostList(postList, hotList);
      }

      // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴
      if (postList.isEmpty && hotList.isEmpty) return;

      // 핫 게시글 세팅
      this.hotList.addAll(hotList);

      // 게시글 세팅
      this.postList.addAll(postList);

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  // 게시글 세팅
  Future<void> setPostList() async {
    if (category == '인기 게시글') {
      // 인기 게시글인 경우
      List<String> categoryInterestList = [];
      List<String> tagInterestList = [];

      // wbti 아니고, 커뮤니티 컨트롤러가 살아있으면
      if (type != Post.postTypeWbti && Get.isRegistered<CommunityController>()) {
        final CommunityController communityController = Get.find<CommunityController>();

        // 전체 보기가 아닐 때 관심 목록 세팅
        if (!communityController.isAllView) {
          categoryInterestList = communityController.filteredCategoryList;
          tagInterestList = communityController.filteredTagList;

          interestList = [...categoryInterestList, ...tagInterestList];
        }
      }

      late final String categoryText;
      late final String tagText;

      // wbti인 경우
      if (type == Post.postTypeWbti) {
        categoryText = WbtiController.to.selectedWbti.type;
        tagText = '';
      } else {
        categoryText = GlobalFunction.stringListToString(categoryInterestList);
        tagText = GlobalFunction.stringListToString(tagInterestList);
      }

      postList = await PostRepository.getPopularPostList(
        type: type,
        categoryText: categoryText,
        tagText: tagText,
      );
    } else if (category[0] == '#') {
      // 태그인 경우
      // 커뮤니티인 경우
      if (!isMeeting) {
        // wbti인 경우
        if(type == Post.postTypeWbti) {
          tagInfo = 'WBTI';
        } else {
          isShowInterest = true; // 관심목록 보여주기
          isJob = type == Post.postTypeJob;
          tagInfo = isJob ? '일터' : '놀터';

          // 내 관심사인지 체크
          if (isJob) {
            isInterest(GlobalData.interestJobTagList.contains(category));
          } else {
            isInterest(GlobalData.interestTopicTagList.contains(category));
          }
        }
      }

      postList = await PostRepository.getPostList(
        type: type,
        needAll: false,
        tagText: category.replaceFirst('#', ''),
      );
    } else {
      // 카테고리인 경우
      postList = await PostRepository.getPostList(
        type: type,
        needAll: false,
        categoryText: category,
      );

      if (!isMeeting) {
        hotList = await PostRepository.getHotPostList(
          type: type,
          categoryText: category,
        );
      }

      generatePostList(postList, hotList);
    }
  }

  void generatePostList(List<Post> post, List<Post> hot) {
    if (hot.isEmpty) return;
    if (post.isEmpty) return;

    //첫 번째 꺼 무조건 넣음
    post.insert(0, hot.first);

    bool check = false;
    for (var i = 1; i < hot.length; ++i) {
      for (var j = 1; j < post.length; ++j) {
        if (!check && (post[j].id == hot[0].id)) {
          post.removeAt(j--);
          check = true;
          continue;
        }

        if (post[j].id == hot[i].id) {
          post[j].isHot = true;
        }
      }
    }
  }

  // 관심사 토글
  void interestToggle() async {
    final prefs = await SharedPreferences.getInstance();
    final int interestLength = isJob ? GlobalData.interestJobList.length + GlobalData.interestJobTagList.length : GlobalData.interestTopicList.length + GlobalData.interestTopicTagList.length;
    final bool isMax = interestLength >= interestMaxNum;
    List<String> interestTagList = isJob ? GlobalData.interestJobTagList : GlobalData.interestTopicTagList;
    List<String> tmpInterestTagList = isJob ? GlobalData.tmpInterestJobTagList : GlobalData.tmpInterestTopicTagList;

    // 관심 태그 목록 세팅
    if (isInterest.value) {
      interestTagList.remove(category);
      isInterest(false);
    } else {
      final bool isContain = tmpInterestTagList.contains(category);

      if (isMax) {
        // 관심목록이 다 찬 경우
        showCustomDialog(
          title: '관심 등록이 가득 찼어요!\n관심 등록 페이지로 이동하시겠어요?',
          isCancelButton: true,
          okText: '네',
          cancelText: '아니오',
          okFunc: () async {
            // 임시 리스트에 저장
            if (!isContain) {
              tmpInterestTagList.add(category);
              await prefs.setStringList('tmpInterestJobTagList', tmpInterestTagList);
            }

            Get.back(); // 다이어로그 끄기
            Get.to(() => InterestRegisterPage(isJob: isJob))!.then((value) {
              isInterest(interestTagList.contains(category));
            });
          },
          cancelFunc: () => Get.back(),
        );
      } else {
        // 임시 리스트에 저장
        if (!isContain) {
          tmpInterestTagList.add(category);
          await prefs.setStringList('tmpInterestJobTagList', tmpInterestTagList);
        }

        interestTagList.add(category); // 태그 관심목록 리스트에 저장
        isInterest(true);
      }
    }
  }
}
