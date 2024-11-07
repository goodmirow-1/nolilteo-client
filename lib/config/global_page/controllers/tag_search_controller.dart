import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/interest_register_page.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/tag_preview.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TagSearchController extends GetxController {
  static get to => Get.find<TagSearchController>();

  final TextEditingController textEditingController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  RxString query = ''.obs;
  List<TagPreview>? tagSearchList; // 태그 검색 결과
  RxBool hasFocus = false.obs; // 포커스 가지고 있는지 여부

  bool loading = false;
  late final int postType; // 커뮤니티인지

  @override
  void onInit(){
    super.onInit();

    focusNode.addListener(() => hasFocus(focusNode.hasFocus));
  }

  @override
  void onClose() {
    super.onClose();

    textEditingController.dispose();
    focusNode.dispose();
  }

  void clearQuery() {
    textEditingController.clear();
    query('');
  }

  // 검색 함수
  void searchFunc() async {
    if (GlobalFunction.removeSpace(query.value).isEmpty) {
      return GlobalFunction.showToast(msg: '공백 제외 1자 이상 입력해 주세요.');
    }

    loading = true;
    update();

    await tagSearch(); // 태그 검색

    loading = false;
    update();
  }

  // 태그 검색
  Future<void> tagSearch() async {
    tagSearchList = await PostRepository.getTagSearch(index: tagSearchList == null ? 0 : tagSearchList!.length, name: query.value, type: postType);
  }

  // 태그 관심등록
  void tagRegisterInterest(String tag, bool isContain) async{
    final InterestRegisterController interestRegisterController = Get.find<InterestRegisterController>();
    final prefs = await SharedPreferences.getInstance();

    if (isContain) {
      interestRegisterController.tagInterestList.removeWhere((element) => element == '#$tag');
      interestRegisterController.tmpTagInterestList.removeWhere((element) => element == '#$tag');
    } else {
      interestRegisterController.tmpTagInterestList.add('#$tag');
    }

    if(interestRegisterController.isJob) {
      await prefs.setStringList('tmpInterestJobTagList', interestRegisterController.tmpTagInterestList);
    } else {
      await prefs.setStringList('tmpInterestTopicTagList', interestRegisterController.tmpTagInterestList);
    }

    Get.back(result: isContain ? null : '#$tag'); // 관심등록 페이지로
  }
}
