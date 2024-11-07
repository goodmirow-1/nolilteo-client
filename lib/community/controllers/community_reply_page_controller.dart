import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';
import '../../repository/post_repository.dart';
import '../../repository/user_repository.dart';
import '../models/reply.dart';

class CommunityReplyPageController extends GetxController {
  static get to => Get.find<CommunityReplyPageController>();

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  bool loading = true;
  bool canLikeEvent = true; // 좋아요 가능 여부
  RxBool showNickNameBox = false.obs;
  Rx<Reply> selectedModifyReply = Reply.nullReply.obs; // 수정하기 위해 선택된 댓글 or 답글

  RxString replyContents = ''.obs; // 댓글 or 답글 내용
  late Reply reply;

  @override
  void onInit() {
    super.onInit();

    focusNode.addListener(() {
      if (focusNode.hasFocus) showNickNameBox(true);
    });
  }

  @override
  void onClose() {
    super.onClose();

    textEditingController.dispose();
    focusNode.dispose();
    scrollController.dispose();
  }

  void fetchData(int replyID) async {
    Reply? result = await PostRepository.getReplyByID(replyID);

    if (result != null) {
      reply = result;

      loading = false;
      update();
    } else {
      Get.back(); // 마이페이지로
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
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

  // 답글 쓰기
  Future<void> writeReplyReply() async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');
    textEditingController.clear();
    focusNode.unfocus();
    showNickNameBox(false);

    ReplyReply? resultReplyReply = await PostRepository.writeReplyReply(replyID: reply.id, contents: replyContents.value);
    replyContents('');

    if (resultReplyReply != null) {
      reply.replyReplyList.add(resultReplyReply);
      update();

      // 스크롤 이동
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });
    } else {
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }

  // 댓글 좋아요 함수
  Future<bool> replyLikeFunc() async {
    if (canLikeEvent) {
      canLikeEvent = false;

      bool? result = await PostRepository.replyLike(postID: reply.parentsID, replyID: reply.id);

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

  // 사용자 차단
  void userBan() {
    if (GlobalData.blockedUserIDList.contains(reply.userID)) return GlobalFunction.showToast(msg: '이미 차단한 사용자입니다.');

    showCustomDialog(
      title: '이 사용자를 차단하시겠어요?\n게시글과 댓글이 숨김처리됩니다.',
      isCancelButton: true,
      okText: '네',
      cancelText: '아니오',
      okFunc: () async {
        bool? result = await UserRepository.userBan(targetID: reply.userID);

        if (result != null && result) {
          GlobalData.blockedUserIDList.add(reply.userID); // 차단 리스트에 추가
          GlobalFunction.showToast(msg: '차단되었습니다.');
        } else {
          Get.close(2); // 다이어로그, 바텀 시트 끄기
          GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
        }
      },
    );
  }

  bool isNormal(Reply reply) => (!reply.isBlind && reply.deleteType == deleteTypeShow); // 정상적인 글인지 (블라인드, 삭제 등이 아닌)

// 수정 댓글 텍스트 필드 열기
  void openModifyReplyTextField(Reply reply) {
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
      reply.contents = replyContents.value;
      reply.isModify = true;

      textEditingController.clear();
      focusNode.unfocus();
      selectedModifyReply(Reply.nullReply);
      showNickNameBox(false);

      update();
      GlobalFunction.showToast(msg: '수정이 완료되었습니다.');
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
  }

  // 답글 수정
  void modifyReplyReply() async {
    if (GlobalFunction.removeSpace(replyContents.value).isEmpty) return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해주세요.');

    bool? result = await PostRepository.modifyReplyReply(id: selectedModifyReply.value.id, contents: replyContents.value);

    if (result != null) {
      for (ReplyReply replyReply in reply.replyReplyList) {
        if (replyReply.id == selectedModifyReply.value.id) {
          replyReply.contents = replyContents.value;
          replyReply.isModify = true;

          textEditingController.clear();
          focusNode.unfocus();
          selectedModifyReply(Reply.nullReply);
          showNickNameBox(false);

          update();
          GlobalFunction.showToast(msg: '수정이 완료되었습니다.');
          break;
        }
      }
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
  }
}
