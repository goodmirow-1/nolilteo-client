import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../community/models/post.dart';
import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../data/global_data.dart';

import '../../network/ApiProvider.dart';

class CommunityController extends GetxController {
  static get to => Get.find<CommunityController>();

  final List<String> titleList = ['일터', '놀터'];
  final List<double> titleWidthList = [30 * sizeUnit, 30 * sizeUnit];
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();

  List<Post> postList = []; // 포스트 리스트
  List<Post> hotList = []; //  핫 리스트
  List<Post> popularPostList = []; // 인기글 리스트

  // 놀터, 일터에 따른 관심등록 리스트
  List<String> get interestList => isJob ? [...GlobalData.interestJobList, ...GlobalData.interestJobTagList] : [...GlobalData.interestTopicList, ...GlobalData.interestTopicTagList];

  // 필터에 쓰이는 카테고리 리스트
  List<String> get filteredCategoryList => isJob
      ? selectedInterestForJob.isEmpty
          ? GlobalData.interestJobList
          : selectedInterestForJob[0] == '#'
              ? []
              : [selectedInterestForJob]
      : selectedInterestForTopic.isEmpty
          ? GlobalData.interestTopicList
          : selectedInterestForTopic[0] == '#'
              ? []
              : [selectedInterestForTopic];

  List<String> get filteredTagList => isJob
      ? selectedInterestForJob.isEmpty
          ? GlobalData.interestJobTagList
          : selectedInterestForJob[0] != '#'
              ? []
              : [selectedInterestForJob]
      : selectedInterestForTopic.isEmpty
          ? GlobalData.interestTopicTagList
          : selectedInterestForTopic[0] != '#'
              ? []
              : [selectedInterestForTopic];

  int barIndex = Post.postTypeJob;
  int get showIndex => isJob ? Post.postTypeTopic : Post.postTypeJob;

  bool get isJob => barIndex == Post.postTypeJob; // 일거리인지
  bool get isAllView => isJob ? jobAllView : topicAllView; // 전체 보기

  bool topicAllView = false; // 놀터 전체 보기
  bool jobAllView = false; // 일터 전체 보기
  bool isHot = false; // 핫 게시글 탭인지
  RxBool activeNewPost = false.obs; //새 게시글 버튼 활성화 여부
  bool canScrollEvent = true; // 스크롤 이벤트 중복 호출 방지
  bool fetchLoading = true;
  bool loading = false; // 게시글 불러올 때
  String selectedInterestForJob = ''; // 선택한 관심 분야 (일거리)
  String selectedInterestForTopic = ''; // 선택한 관심 분야 (놀거리)

  @override
  void onInit(){
    super.onInit();

    scrollController.addListener(() => maxScrollEvent());
  }

  @override
  void onClose() {
    super.onClose();

    scrollController.dispose();
    pageController.dispose();
  }

  // 데이터 세팅
  Future<void> fetchData() async {
    if (fetchLoading) {
      // 전체 보기 세팅
      final prefs = await SharedPreferences.getInstance();
      topicAllView = prefs.getBool('topicAllView') ?? true;
      jobAllView = prefs.getBool('jobAllView') ?? true;

      await GlobalFunction.setLoginData(); // 처음 데이터 받는 경우 로그인 데이터 세팅
    } else {
      loading = true;
      update();
    }

    await setPostList(); // 게시글 세팅
    GlobalData.hotListByHour(await PostRepository.getHotPostListByHour()); // 시간별 핫 리스트 세팅
    GlobalData.popularListByRealTime(await PostRepository.getPopularListByRealTime()); // 실시간 인기 리스트 세팅

    if (fetchLoading) {
      fetchLoading = false; // 처음 데이터 받는 경우
    } else {
      loading = false;
    }

    update();
  }

  Future<Post> getFuturePost(int postID) async {
    Post? post;

    for (int i = 0; i < postList.length; i++) {
      if (postList[i].id == postID) {
        post = postList[i];
        break;
      }
    }

    if (post == null) {
      var res = await ApiProvider().post('/CommunityPost/Select/ID', jsonEncode({'id': postID, 'userID': GlobalData.loginUser.id}));

      if (res != null) {
        post = Post.fromJson(res);

        await GlobalFunction.getFutureUserByID(res['userID']);

        postList.add(post);
        postList.sort((b, a) => a.id.compareTo(b.id));
      }
    }

    return Future.value(post);
  }

  // 페이지 전환
  void pageChange(BuildContext context, int index) async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    loading = true;
    barIndex = index == Post.postTypeTopic ? Post.postTypeJob : Post.postTypeTopic;

    update();

    MainPageController.to.changeCategoryList(isJob); // endDrawer 카테고리 리스트 세팅

    await setPostList(); // 게시글 세팅

    loading = false;
    update();
  }

  // 관심사 탭 했을 때
  void interestTapFunc(String interest) async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    loading = true;
    update();

    if (isJob) {
      if (interest == selectedInterestForJob) {
        selectedInterestForJob = '';
      } else {
        selectedInterestForJob = interest;
      }
    } else {
      if (interest == selectedInterestForTopic) {
        selectedInterestForTopic = '';
      } else {
        selectedInterestForTopic = interest;
      }
    }

    await setPostList(); // 게시글 세팅

    loading = false;
    update();
  }

  void hotSwitch(){
    isHot = !isHot;
    update();
  }

  // 새로고침
  void onRefresh() async {
    canScrollEvent = true; // 스크롤 이벤트 허용
    await setPostList(); // 게시글 세팅
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

      final String categoryText = isAllView ? '' : GlobalFunction.stringListToString(filteredCategoryList);
      final String tagText = isAllView ? '' : GlobalFunction.stringListToString(filteredTagList);

      List<Post> postList = await PostRepository.getPostList(
        type: barIndex,
        needAll: isAllView,
        categoryText: categoryText,
        tagText: tagText,
        index: this.postList.length,
      );

      List<Post> hotList = await PostRepository.getHotPostList(
        type: barIndex,
        index: this.hotList.length,
        categoryText: categoryText,
        tagText: tagText,
      );

      // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴
      if (postList.isEmpty && hotList.isEmpty) return;

      generatePostList(postList, hotList);

      // 핫 게시글 세팅
      this.hotList.addAll(hotList);

      // 게시글 세팅
      this.postList.addAll(postList);

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  // 전체 보기 토글
  void allToggle() async {
    if (interestList.isEmpty) return;

    loading = true;
    update();

    final prefs = await SharedPreferences.getInstance();

    if(barIndex == Post.postTypeTopic) {
      topicAllView = !topicAllView;
      await prefs.setBool('topicAllView', topicAllView);
    } else {
      jobAllView = !jobAllView;
      await prefs.setBool('jobAllView', jobAllView);
    }

    await setPostList();

    loading = false;
    update();
  }

  // 게시글 데이터 세팅
  Future<void> setPostList() async {
    activeNewPost(false);
    final String categoryText = isAllView ? '' : GlobalFunction.stringListToString(filteredCategoryList);
    final String tagText = isAllView ? '' : GlobalFunction.stringListToString(filteredTagList);

    // 게시글
    postList = await PostRepository.getPostList(
      type: barIndex,
      needAll: isAllView,
      categoryText: categoryText,
      tagText: tagText,
    );

    // 핫 게시글
    hotList = await PostRepository.getHotPostList(
      type: barIndex,
      categoryText: categoryText,
      tagText: tagText,
    );

    generatePostList(postList, hotList);

    // 인기 게시글
    popularPostList = await PostRepository.getPopularPostList(
      type: barIndex,
      categoryText: categoryText,
      tagText: tagText,
      limit: popularLimit,
    );
  }

  void generatePostList(List<Post> post, List<Post> hot) {
    if(hot.isEmpty) return;
    if(post.isEmpty) return;

    for(var i = 0 ; i < post.length; ++i){
      if(post[i].id == hot.first.id) {
        post.removeAt(i--);
        break;
      }
    }

    //첫 번째 꺼 무조건 넣음
    post.insert(0, hot.first);

    bool check = false;
    for(var i = 1 ; i < hot.length ; ++i){
      for(var j = 1 ; j < post.length ; ++j){
        if(!check && (post[j].id == hot[0].id)) {
          post.removeAt(j--);
          check = true;
          continue;
        }

        if(post[j].id == hot[i].id){
          post[j].isHot = true;
        }
      }
    }
  }

  // InterestRegisterPage or BoardPage(tag) 갔다온 후 관심목록 바뀐사항 있는지 체크
  void afterInterestRegister(List<String> originInterestList) async {
    // 데이터 세팅 함수
    Future<void> setData() async {
      if(barIndex == Post.postTypeTopic) {
        topicAllView = interestList.isEmpty;
      } else {
        jobAllView = interestList.isEmpty;
      }

      loading = true;
      update();
      await setPostList();
      loading = false;
      update();
    }

    // 필터 적용해놓은 카테고리 관심 해제 했으면 초기화
    if (isJob) {
      if (selectedInterestForJob.isNotEmpty && !interestList.contains(selectedInterestForJob)) {
        selectedInterestForJob = '';
        return await setData();
      }
    } else {
      if (selectedInterestForTopic.isNotEmpty && !interestList.contains(selectedInterestForTopic)) {
        selectedInterestForTopic = '';
        return await setData();
      }
    }

    // 관심목록 바뀐사항 있으면 데이터 세팅
    if (originInterestList.length != interestList.length) {
      await setData();
    } else {
      for (int i = 0; i < originInterestList.length; i++) {
        if (originInterestList[i] != interestList[i]) {
          await setData();
          break;
        }
      }
    }
  }

  void setActiveNewPost(bool bCheck){
    activeNewPost(bCheck);
    update();
  }

  void resetData(){
    fetchLoading = true;
    barIndex = Post.postTypeJob;
  }

  void addPost(int index, Post post){
    if(postList.isNotEmpty && postList[index].isHot){
      index = index + 1;
    }

    postList.insert(index, post);
  }

  // 관심목록 스크롤 컨트롤
  void setInterestListScroll(ItemScrollController itemScrollController){
    void scrollEvent(int index){
      if(itemScrollController.isAttached) {
        itemScrollController.scrollTo(
          index: index > 0 ? index - 1 : index,
          duration: const Duration(milliseconds: 300),
        );
      }
    }

    if (isJob) {
      if (selectedInterestForJob.isNotEmpty) scrollEvent(interestList.indexOf(selectedInterestForJob));
    } else {
      if (selectedInterestForTopic.isNotEmpty) scrollEvent(interestList.indexOf(selectedInterestForTopic));
    }
  }
}
