import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../community/models/post.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';
import '../../repository/post_repository.dart';

class MyPostController extends GetxController {
  MyPostController({required this.tag});

  final String tag;

  final List<String> titleList = ['일터', '놀터', 'WBTI'];
  final List<double> titleWidthList = [30 * sizeUnit, 30 * sizeUnit, 50 * sizeUnit];
  final PageController pageController = PageController();

  late final int userID; // 어떤 유저의 게시글을 받을 것이지
  List<Post> postList = []; // 포스트 리스트
  List<Post> playList = [];
  List<Post> workList = [];
  List<Post> wbtiList = [];

  int barIndex = Post.postTypeJob;
  int get showIndex => barIndex == 2 ? 2 : isJob ? Post.postTypeTopic : Post.postTypeJob;

  bool get isJob => barIndex == Post.postTypeJob; // 일거리인지
  bool fetchLoading = true;
  bool loading = false; // 게시글 불러올 때
  bool canScrollEvent = true; // 스크롤 이벤트 중복 호출 방지
  bool isLike = false;

  @override
  void onInit() {
    super.onInit();

    GlobalData.myPostPageCount++;
  }

  @override
  void onClose() {
    super.onClose();

    GlobalData.myPostPageCount--;
  }

  Future<void> fetchData(int userID) async {
    if (fetchLoading) {
      this.userID = userID;
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
    //좋아요 게시글
    if (barIndex == Post.postTypeTopic) {
      if (playList.isEmpty) {
        if (isLike == false) {
          playList = await PostRepository.getPostListByUserID(type: Post.postTypeTopic, targetID: userID, index: playList.length);
        } else {
          playList = await PostRepository.getLikesPost(type: Post.postTypeTopic, index: playList.length);
        }

        postList = playList;
      } else {
        postList = playList;
      }
    } else if(barIndex == Post.postTypeJob){
      if (workList.isEmpty) {
        if (isLike == false) {
          workList = await PostRepository.getPostListByUserID(type: Post.postTypeJob, targetID: userID, index: workList.length);
        } else {
          workList = await PostRepository.getLikesPost(type: Post.postTypeJob, index: workList.length);
        }

        postList = workList;
      } else {
        postList = workList;
      }
    } else {
      if (wbtiList.isEmpty) {
        if (isLike == false) {
          wbtiList = await PostRepository.getPostListByUserID(type: Post.postTypeWbti, targetID: userID, index: wbtiList.length);
        } else {
          wbtiList = await PostRepository.getLikesPost(type: Post.postTypeWbti, index: wbtiList.length);
        }

        postList = wbtiList;
      } else {
        postList = wbtiList;
      }
    }
  }

  // 새로고침
  void onRefresh() async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    playList.clear();
    workList.clear();
    wbtiList.clear();
    await setPostList(); // 게시글 세팅
    update();
  }

  bool _isMaxScroll(ScrollController scrollController) {
    if (!scrollController.hasClients) return false;
    if(postList.isNotEmpty && postList.length <= 2) return false;

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

      if(barIndex == Post.postTypeTopic){
        if(postList.isEmpty) return;

        if(isLike == false){
          List<Post> postList = await PostRepository.getPostListByUserID(type: barIndex, targetID: userID, index: this.postList.length);
          this.postList.addAll(postList);
        }else{
          List<Post> playList = await PostRepository.getLikesPost(type: Post.postTypeTopic, index: this.playList.length);
          // this.playList.addAll(playList);
          postList.addAll(playList);
        }
      }else if(barIndex == Post.postTypeJob){
        if(postList.isEmpty) return;

        if(isLike == false){
          List<Post> workList = await PostRepository.getPostListByUserID(type: Post.postTypeJob, targetID: userID, index: this.workList.length);
          postList.addAll(workList);
        }else{
          List<Post> workList = await PostRepository.getLikesPost(type: Post.postTypeJob, index: this.workList.length);
          // this.workList.addAll(workList);
          postList.addAll(workList);
        }
      } else {
        if(postList.isEmpty) return;

        if(isLike == false){
          List<Post> wbtiList = await PostRepository.getPostListByUserID(type: Post.postTypeWbti, targetID: userID, index: this.wbtiList.length);
          postList.addAll(wbtiList);
        }else{
          List<Post> wbtiList = await PostRepository.getLikesPost(type: Post.postTypeWbti, index: this.wbtiList.length);
          // this.wbtiList.addAll(wbtiList);
          postList.addAll(wbtiList);
        }
      }

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  // 페이지 전환
  void pageChange(int index) async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    if(index == 0) {
      barIndex = Post.postTypeJob;
    } else if(index == 1) {
      barIndex = Post.postTypeTopic;
    } else {
      barIndex = index;
    }
    update();

    await setPostList(); // 게시글 세팅

    update();
  }

  void remove(int index){
    postList.removeAt(index);
    update();
  }

  void sync(int index){
    if(postList[index].isLike == false) {
      postList.removeAt(index);
      update();
    }
  }
}
