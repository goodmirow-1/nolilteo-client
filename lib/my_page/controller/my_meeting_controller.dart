import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../data/global_data.dart';
import '../../meeting/model/meeting_post.dart';
import '../../repository/post_repository.dart';

class MyMeetingController extends GetxController {
  MyMeetingController({required this.tag});

  final String tag;

  List<MeetingPost> postList = []; // 포스트 리스트

  bool canScrollEvent = true; // 스크롤 이벤트 중복 호출 방지
  RxBool loading = false.obs;
  late final int userID; // 어떤 유저의 모여라 받을 것인지

  @override
  void onInit() {
    super.onInit();

    GlobalData.myMeetingPageCount++;
  }

  @override
  void onClose() {
    super.onClose();

    GlobalData.myMeetingPageCount--;
  }

  Future<void> fetchData(int userID) async {
    this.userID = userID;
    loading = true.obs;
    update();

    await setPostList().then((value) {
      update(['fetchData']);
      loading = false.obs;
    });
  }

  // 게시글 데이터 세팅
  Future<void> setPostList() async {
    postList = await PostRepository.getMeetingPostListByUserID(index: postList.length, userID: userID);
  }

  // 새로고침
  void onRefresh() async {
    postList.clear();
    await setPostList(); // 리스트 세팅
    canScrollEvent = true; // 스크롤 이벤트 허용
    update();
  }

  bool _isMaxScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;
    return currentScroll == maxScroll;
  }

  // 스크롤 이벤트
  void maxScrollEvent(ScrollController scrollController) async {
    // 중복 호출 방지
    if (!canScrollEvent) return;

    if (_isMaxScroll(scrollController)) {
      canScrollEvent = false;
      if (this.postList.isEmpty) return;

      List<MeetingPost> postList = await PostRepository.getMeetingPostListByUserID(index: this.postList.length, userID: userID);

      if (postList.isEmpty) return; // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴

      this.postList.addAll(postList); // 게시글 세팅

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  void remove(int index){
    postList.removeAt(index);
    update();
  }
}