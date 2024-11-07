import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';

import '../../community/models/post.dart';
import '../../community/models/reply.dart';
import '../../config/global_widgets/animated_tap_bar.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../home/controllers/main_page_controller.dart';
import '../../repository/post_repository.dart';

class MyReplyController extends GetxController {
  static get to => Get.find<MyReplyController>();

  static const int replyIndex = 0; // 놀터
  static const int replyReplyIndex = 1; // 일터

  final List<String> titleList = ['댓글', '답글'];
  final List<double> titleWidthList = [30 * sizeUnit, 30 * sizeUnit];
  final PageController pageController = PageController();

  List<Reply> replyList = []; //댓글 리스트
  List<ReplyReply> replyReplyList = []; //답글 리스트

  int barIndex = replyIndex;

  bool fetchLoading = true;
  bool loading = false; // 게시글 불러올 때
  bool canScrollEvent = true;

  Future<void> fetchData() async {
    if (fetchLoading) {
    } else {
      loading = true;
      update();
    }

    await setPostList(); // 게시글 세팅

    if (fetchLoading) {
      // 처음 데이터 받는 경우
      fetchLoading = false;
      update(['fetchData']);
    } else {
      loading = false;
      update();
    }
  }

  // 게시글 데이터 세팅
  Future<void> setPostList() async {
    if (barIndex == 0) {
      if (replyList.isEmpty) {
        replyList = await PostRepository.getReplyList(index: replyList.isEmpty ? 0 : replyList.length);
      }
    } else {
      if (replyReplyList.isEmpty) {
        replyReplyList = await PostRepository.getReplyReplyList(index: replyReplyList.isEmpty ? 0 : replyReplyList.length);
      }
    }
  }

  // 새로고침
  void onRefresh() async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    await setPostList(); // 게시글 세팅
    update();
  }

  bool _isMaxScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return currentScroll == maxScroll;
    // return currentScroll >= (maxScroll * 0.9);
  }

  // 스크롤 이벤트
  void maxScrollEvent(ScrollController scrollController) async {
    // 중복 호출 방지
    if (!canScrollEvent) return;

    if (_isMaxScroll(scrollController)) {
      canScrollEvent = false;

      if (barIndex == replyIndex) {
        if (replyList.isEmpty) return; // 게시글 없으면 다시 호출 못하도록 리턴

        List<Reply> list = await PostRepository.getReplyList(index: replyList.isEmpty ? 0 : replyList.length);

        if (replyList.isEmpty) return; // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴

        // 게시글 세팅
        replyList.addAll(list);

        update();
        canScrollEvent = true; // 스크롤 이벤트 허용
      } else {
        if (replyReplyList.isEmpty) return; // 게시글 없으면 다시 호출 못하도록 리턴

        List<ReplyReply> list = await PostRepository.getReplyReplyList(index: replyReplyList.isEmpty ? 0 : replyReplyList.length);

        if (replyReplyList.isEmpty) return; // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴

        // 게시글 세팅
        replyReplyList.addAll(list);

        update();
        canScrollEvent = true; // 스크롤 이벤트 허용
      }
    }
  }

  // 페이지 전환
  void pageChange(int index) async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    barIndex = index;
    update();

    await setPostList(); // 게시글 세팅

    update();
  }
}
