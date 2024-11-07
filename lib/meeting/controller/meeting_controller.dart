import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/models/post.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/global_function.dart';
import '../../data/global_data.dart';
import '../model/meeting_post.dart';

class MeetingController extends GetxController {
  static get to => Get.find<MeetingController>();

  final ScrollController scrollController = ScrollController();

  @override
  void onInit(){
    super.onInit();

    scrollController.addListener(() => maxScrollEvent());
  }

  @override
  void onClose() {
    super.onClose();

    scrollController.dispose();
  }

  List<MeetingPost> postList = []; // 포스트 리스트
  List<String> get interestList => <String>{...GlobalData.interestJobList, ...GlobalData.interestTopicList, ...GlobalData.interestJobTagList, ...GlobalData.interestTopicTagList}.toList(); // 관심사 리스트

  // 필터에 쓰이는 카테고리 리스트
  List<String> get filteredCategoryList => selectedInterest.isEmpty
      ? [...GlobalData.interestJobList, ...GlobalData.interestTopicList]
      : selectedInterest[0] == '#'
          ? []
          : [selectedInterest];

  // 필터에 쓰이는 태그 리스트
  List<String> get filteredTagList => selectedInterest.isEmpty
      ? [...GlobalData.interestJobTagList, ...GlobalData.interestTopicTagList]
      : selectedInterest[0] != '#'
          ? []
          : [selectedInterest];

  // 필터에 쓰이는 지역 리스트
  List<String> get filteredLocationList => selectedLocation.isEmpty ? GlobalData.interestLocationList : [selectedLocation];

  String selectedInterest = ''; // 선택한 관심분야
  String selectedLocation = ''; // 선택한 지역

  bool canScrollEvent = true; // 스크롤 이벤트 중복 호출 방지
  bool loading = false;

  RxBool isAllView = false.obs; // 전체 보기
  RxBool activeNewPost = false.obs; //새 게시글 버튼 활성화 여부

  // 데이터 세팅
  Future<void> fetchData() async {
    final prefs = await SharedPreferences.getInstance();
    isAllView(prefs.getBool('meetingAllView') ?? true); // ALL 세팅

    loading = true;
    update();

    await setPostList();
    GlobalData.hotListByHour(await PostRepository.getHotPostListByHour()); // 시간별 핫 리스트 세팅
    GlobalData.popularListByRealTime(await PostRepository.getPopularListByRealTime()); // 실시간 인기 리스트 세팅

    loading = false;
    update();
  }

  // 관심사 탭 했을 때
  void interestTapFunc(String interest) async {
    loading = true;
    update();

    if (interest == selectedInterest) {
      selectedInterest = '';
    } else {
      selectedInterest = interest;
    }

    await setPostList(); // 게시글 세팅

    loading = false;
    update();
  }

  // 지역 탭 했을 때
  void locationTapFunc(String location) async {
    loading = true;
    update();

    if (selectedLocation == location) {
      selectedLocation = '';
    } else {
      selectedLocation = location;
    }

    await setPostList(); // 게시글 세팅

    loading = false;
    update();
  }

  // 새로고침
  void onRefresh() async {
    await setPostList(); // 리스트 세팅
    canScrollEvent = true; // 스크롤 이벤트 허용
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
      if (this.postList.isEmpty) return; // 게시글 없으면 다시 호출 못하도록 리턴

      final String categoryText = isAllView.value ? '' : GlobalFunction.stringListToString(filteredCategoryList);
      final String tagText = isAllView.value ? '' : GlobalFunction.stringListToString(filteredTagList);
      final String locationText = GlobalFunction.stringListToString(locationListDeduplication(filteredLocationList));

      List<MeetingPost> postList = (await PostRepository.getPostList(
        type: Post.postTypeMeeting,
        needAll: isAllView.value,
        categoryText: categoryText,
        tagText: tagText,
        locationText: locationText,
        index: this.postList.length,
      ))
          .cast<MeetingPost>();

      if (postList.isEmpty) return; // 데이터가 더 이상 없을 경우 다시 호출 못하게 리턴

      this.postList.addAll(postList); // 게시글 세팅

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }

  // 전체 보기
  void allToggle() async {
    if (interestList.isEmpty) return;

    loading = true;
    update();

    final prefs = await SharedPreferences.getInstance();
    isAllView.toggle();
    await prefs.setBool('meetingAllView', isAllView.value);

    await setPostList();

    loading = false;
    update();
  }

  // 게시글 데이터 세팅
  Future<void> setPostList() async {
    activeNewPost(false);
    final String categoryText = isAllView.value ? '' : GlobalFunction.stringListToString(filteredCategoryList);
    final String tagText = isAllView.value ? '' : GlobalFunction.stringListToString(filteredTagList);
    final String locationText = GlobalFunction.stringListToString(locationListDeduplication(filteredLocationList));

    postList = (await PostRepository.getPostList(
      type: Post.postTypeMeeting,
      needAll: isAllView.value,
      categoryText: categoryText,
      tagText: tagText,
      locationText: locationText,
    ))
        .cast<MeetingPost>();

    await Future.delayed(const Duration(milliseconds: 500));
  }

  // 지역 리스트 중복 제거
  List<String> locationListDeduplication(List<String> list) {
    List<String> locationList = [...list];
    List<String> allLocations = []; // 전체 보기 지역

    for(String location in locationList) {
      if(location.contains('ALL')) {
        allLocations.add(location.replaceFirst(' ALL', ''));
      }
    }

    for(String allLocation in allLocations) {
      locationList.removeWhere((element) => element != '$allLocation ALL' && element.contains(allLocation));
    }

    return locationList;
  }

  // 지역등롱 후 바뀐사항 있는지 체크
  void afterLocationRegister(List<String> originLocationList) async {
    // 데이터 세팅 함수
    Future<void> setData() async {
      loading = true;
      update();
      await setPostList();
      loading = false;
      update();
    }

    // 필터 적용해놓은 장소 삭제 했으면 초기화
    if(selectedLocation.isNotEmpty && !GlobalData.interestLocationList.contains(selectedLocation)) {
      selectedLocation = '';
      return await setData();
    }

    // 관심목록 바뀐사항 있으면 데이터 세팅
    if (originLocationList.length != GlobalData.interestLocationList.length) {
      await setData();
    } else {
      for (int i = 0; i < originLocationList.length; i++) {
        if (originLocationList[i] != GlobalData.interestLocationList[i]) {
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
}
