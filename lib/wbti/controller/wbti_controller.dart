import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../community/models/post.dart';
import '../../config/constants.dart';
import '../../config/global_function.dart';
import '../../data/global_data.dart';

import '../../network/ApiProvider.dart';

class WbtiController extends GetxController {
  static get to => Get.find<WbtiController>();

  final List<String> titleList = ['일터', '놀터'];
  final List<double> titleWidthList = [30 * sizeUnit, 30 * sizeUnit];
  final PageController pageController = PageController();
  final ScrollController scrollController = ScrollController();
  final ItemScrollController itemScrollController = ItemScrollController();

  List<Post> postList = []; // 포스트 리스트
  List<Post> hotList = []; //  핫 리스트
  List<Post> popularPostList = []; // 인기글 리스트

  WbtiType selectedWbti = WbtiType(type: '', title: '', src: '', name: '', workStyle: '', howToCoWork: '', perfectMatchType: '');
  bool isWbtiEditMode = false; // 편집 모드

  RxList<WbtiType> editWbtiList = GlobalData.customWbtiList.obs; // 순서 변경할 때 쓰이는 리스트

  bool isHot = false; // 핫 게시글 탭인지
  RxBool activeNewPost = false.obs; //새 게시글 버튼 활성화 여부
  bool canScrollEvent = true; // 스크롤 이벤트 중복 호출 방지
  bool loading = false; // 게시글 불러올 때

  @override
  void onInit() {
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
    if (selectedWbti.title.isEmpty) return; // 선택한 wbti 없으면 리턴 (처음에 들어왔을 때)

    loading = true;
    update();

    await setPostList(); // 게시글 세팅
    GlobalData.hotListByHour(await PostRepository.getHotPostListByHour()); // 시간별 핫 리스트 세팅
    GlobalData.popularListByRealTime(await PostRepository.getPopularListByRealTime()); // 실시간 인기 리스트 세팅

    characterScrollEvent(GlobalData.customWbtiList.indexOf(selectedWbti)); // 스크롤 이동

    loading = false;
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

  void hotSwitch() {
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

      List<Post> postList = await PostRepository.getPostList(
        type: Post.postTypeWbti,
        needAll: false,
        categoryText: selectedWbti.type,
        index: this.postList.length,
      );

      List<Post> hotList = await PostRepository.getHotPostList(
        type: Post.postTypeWbti,
        index: this.hotList.length,
        categoryText: selectedWbti.type,
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

  // 게시글 데이터 세팅
  Future<void> setPostList() async {
    activeNewPost(false);

    // 게시글
    postList = await PostRepository.getPostList(
      type: Post.postTypeWbti,
      needAll: false,
      categoryText: selectedWbti.type,
    );

    // 핫 게시글
    hotList = await PostRepository.getHotPostList(
      type: Post.postTypeWbti,
      categoryText: selectedWbti.type,
    );

    generatePostList(postList, hotList);

    // 인기 게시글
    popularPostList = await PostRepository.getPopularPostList(
      type: Post.postTypeWbti,
      categoryText: selectedWbti.type,
      limit: popularLimit,
    );
  }

  void generatePostList(List<Post> post, List<Post> hot) {
    if (hot.isEmpty) return;
    if (post.isEmpty) return;

    for (var i = 0; i < post.length; ++i) {
      if (post[i].id == hot.first.id) {
        post.removeAt(i--);
        break;
      }
    }

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

  void setActiveNewPost(bool bCheck) {
    activeNewPost(bCheck);
    update();
  }

  void addPost(int index, Post post) {
    if (postList.isNotEmpty && postList[index].isHot) {
      index = index + 1;
    }

    postList.insert(index, post);
  }

  // 편집 모드 토글
  void toggleWbtiEdit() async {
    if (isWbtiEditMode) {
      GlobalData.customWbtiList = [...editWbtiList];
      final prefs = await SharedPreferences.getInstance();
      prefs.setStringList('wbtiList', GlobalData.customWbtiList.map((e) => e.type).toList());
    } else {
      editWbtiList.value = [...GlobalData.customWbtiList]; // 순서 변경 리스트 초기화
    }

    isWbtiEditMode = !isWbtiEditMode;
    update();
  }

  // wbti 선택
  void selectWbti(WbtiType wbtiType) async{
    selectedWbti = wbtiType;
    update();
    await fetchData();
  }

  // wbti type 바꾸는 함수
  void changeWbti(WbtiType wbtiType) async {
    selectedWbti = wbtiType;

    loading = true;
    update();

    await setPostList();
    characterScrollEvent(GlobalData.customWbtiList.indexOf(wbtiType)); // 스크롤 이동

    loading = false;
    update();
  }

  // 스크롤 이동
  void characterScrollEvent(int index){
    itemScrollController.scrollTo(
      index: index > 0 ? index - 1 : index,
      duration: const Duration(milliseconds: 300),
    );
  }
}
