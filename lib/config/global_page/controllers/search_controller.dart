import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/data/tag_preview.dart';
import 'package:nolilteo/repository/post_repository.dart';

import '../../../community/models/post.dart';
import '../../global_widgets/animated_tap_bar.dart';

class SearchController extends GetxController {
  static get to => Get.find<SearchController>();

  static const int titleIndex = 0;
  static const int tagIndex = 1;

  final ScrollController scrollController = ScrollController();
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  final PageController pageController = PageController();

  final List<String> pageTitleList = ['제목', '#'];
  final List<double> pageTitleWidthList = [30 * sizeUnit, 11 * sizeUnit];

  RxString query = ''.obs;
  List<Post>? titleSearchList; // 제목 검색 결과
  List<TagPreview>? tagSearchList; // 태그 검색 결과
  RxBool hasFocus = false.obs; // 포커스 가지고 있는지 여부

  bool loading = false;
  bool canScrollEvent = true;
  late final int postType; // 커뮤니티인지
  int barIndex = titleIndex;

  bool get isTitle => barIndex == titleIndex;

  @override
  void onInit() {
    super.onInit();

    focusNode.addListener(() => hasFocus(focusNode.hasFocus));
    scrollController.addListener(() => maxScrollEvent());
  }

  @override
  void onClose() {
    super.onClose();

    scrollController.dispose();
    textEditingController.dispose();
    focusNode.dispose();
    pageController.dispose();
  }

  void clearQuery() {
    textEditingController.clear();
    query('');
  }

  void clearList() {
    if(titleSearchList != null && titleSearchList!.isNotEmpty) titleSearchList = null;
    if(tagSearchList != null && tagSearchList!.isNotEmpty) tagSearchList = null;
    update();
  }

  // 페이지 전환
  void pageChange(int index, {bool isSnapChange = false}) async {
    barIndex = index;
    canScrollEvent = true; // 스크롤 이벤트 허용

    if (!isSnapChange) {
      pageController.animateToPage(index, duration: AnimatedTapBar.duration, curve: AnimatedTapBar.curve);
    }

    final bool haveToSearch = isTitle ? titleSearchList == null : tagSearchList == null;

    // 검색이 필요한 경우
    if (haveToSearch) {
      loading = true;
      update();

      if (isTitle) {
        titleSearchList = await titleSearch(); // 제목 검색
      } else {
        tagSearchList = await tagSearch(); // 태그 검색
      }

      loading = false;
    }

    update();
  }

  // 검색 함수
  void searchFunc() async {
    if (GlobalFunction.removeSpace(query.value).isEmpty) {
      return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해 주세요.');
    }

    canScrollEvent = true; // 스크롤 이벤트 허용

    loading = true;
    update();

    if (isTitle) {
      titleSearchList = await titleSearch(); // 제목 검색
      tagSearchList = null;
    } else {
      tagSearchList = await tagSearch(); // 태그 검색
      titleSearchList = null;
    }

    loading = false;
    update();
  }

  // 제목 검색
  Future<List<Post>> titleSearch({int index = 0}) async {
    if (postType != Post.postTypeMeeting) {
      return await PostRepository.getTitleSearch(index: index, keywords: query.value);
    } else {
      return await PostRepository.getGatheringTitleSearch(index: index, keywords: query.value);
    }
  }

  // 태그 검색
  Future<List<TagPreview>> tagSearch({int index = 0}) async {
    return await PostRepository.getTagSearch(index: index, name: query.value);
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
    if(scrollController.position.pixels == 0) return;

    if (_isMaxScroll(scrollController)) {
      canScrollEvent = false;

      if (isTitle) {
        if (this.titleSearchList == null || this.titleSearchList!.isEmpty) return; // 리스트 비어있으면
        List<Post> titleSearchList = await titleSearch(index: this.titleSearchList!.length);
        if (titleSearchList.isEmpty) return; // 데이터가 더 이상 없을 경우 호출 못하게 리턴
        this.titleSearchList!.addAll(titleSearchList); // 게시글 세팅
      } else {
        if (this.tagSearchList == null || this.tagSearchList!.isEmpty) return; // 리스트 비어있으면
        List<TagPreview> tagSearchList = await tagSearch(index: this.tagSearchList!.length);
        if (tagSearchList.isEmpty) return; // 데이터가 더 이상 없을 경우 호출 못하게 리턴
        this.tagSearchList!.addAll(tagSearchList); // 게시글 세팅
      }

      update();
      canScrollEvent = true; // 스크롤 이벤트 허용
    }
  }
}
