import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/login/nickname_page.dart';

import '../../config/global_widgets/global_widget.dart';
import '../model/wbti_question.dart';
import '../wbti_result_page.dart';

class WbtiTestController extends GetxController {
  static get to => Get.find<WbtiTestController>();

  late PageController pageController;
  late PageController testPageController;

  bool isFirstLogin = false;
  bool isEdit = false;

  int pageIndex = 0;
  Duration pageDuration = const Duration(milliseconds: 500);
  Curve pageCurve = Curves.easeInOut;

  String buttonText = '다음';

  double pageRatio = 0.2;

  List<WbtiQuestion> questionList = WbtiQuestion.getRandomQuestionList();
  Map<int, int> answerMap = {};

  Future<void> fetchData(PageController tmpPageController, PageController tmpTestPageController) async {
    //첫로그인 체크
    if (GlobalData.pageRouteList.contains(NicknamePage.route)) {
      isFirstLogin = true;
    }
    //정보 수정 체크
    if (GlobalData.loginUser.id != nullInt) {
      isEdit = true;
    }

    pageController = tmpPageController;
    testPageController = tmpTestPageController;
  }

  void backFunc(PageController testPageController) {
    switch (pageIndex) {
      case 0:
        return;
      case 1:
        pageController.previousPage(duration: pageDuration, curve: pageCurve);
        break;
      case 2:
      case 3:
      case 4:
      case 5:
        pageRatio -= 0.2;
        testPageController.previousPage(duration: pageDuration, curve: pageCurve);
        break;
    }
    update(['bottom_button']);
  }

  bool isCanNext() {
    switch (pageIndex) {
      case 0:
      case 1:
      case 2:
      case 3:
      case 4:
      case 5:
        if (answerMap[pageIndex * 4 - 4] != null && answerMap[pageIndex * 4 - 3] != null && answerMap[pageIndex * 4 - 2] != null && answerMap[pageIndex * 4 - 1] != null) {
          return true;
        } else {
          return false;
        }
      default:
        return false;
    }
  }

  void bottomButtonFunc(PageController pageController, PageController testPageController) {
    switch (pageIndex) {
      case 0:
        pageController.nextPage(duration: pageDuration, curve: pageCurve);
        break;
      case 1:
      case 2:
      case 3:
      case 4:
        pageRatio += 0.2;
        testPageController.nextPage(duration: pageDuration, curve: pageCurve);
        break;
      case 5:
        resultFunc();
        break;
    }

    update(['bottom_button']);
  }

  void choseAnswer(int questionIndex, int answerIndex) {
    answerMap[questionIndex] = answerIndex;
    update(['test_page', 'bottom_button']);
  }

  void pageChangeFunc(int index) {
    pageIndex = index;
    update(['bottom_button']);
  }

  void testPageChangeFunc(int index) {
    pageIndex = index + 1;
    if (pageIndex == 5) {
      buttonText = '결과보기';
    } else {
      buttonText = '다음';
    }
    update(['progress_bar', 'bottom_button']);
  }

  void resultFunc() {
    int scoreEI = 0;
    int scoreSN = 0;
    int scoreTF = 0;
    int scoreJP = 0;

    for (int i = 0; i < questionList.length; i++) {
      int score = answerMap[i] ?? 0;
      score = score * -1 + 2;
      switch (questionList[i].type) {
        case WbtiQuestion.wbtiTypeE:
          scoreEI -= score;
          break;
        case WbtiQuestion.wbtiTypeI:
          scoreEI += score;
          break;
        case WbtiQuestion.wbtiTypeS:
          scoreSN -= score;
          break;
        case WbtiQuestion.wbtiTypeN:
          scoreSN += score;
          break;
        case WbtiQuestion.wbtiTypeT:
          scoreTF -= score;
          break;
        case WbtiQuestion.wbtiTypeF:
          scoreTF += score;
          break;
        case WbtiQuestion.wbtiTypeJ:
          scoreJP -= score;
          break;
        case WbtiQuestion.wbtiTypeP:
          scoreJP += score;
          break;
      }
    }

    String wbti = '';
    wbti += scoreEI > 0 ? 'e' : 'i';
    wbti += scoreSN > 0 ? 's' : 'n';
    wbti += scoreTF > 0 ? 't' : 'f';
    wbti += scoreJP > 0 ? 'j' : 'p';

    Get.toNamed('${WbtiResultPage.route}/$wbti')?.then((value) {
      //페이지 돌아오면 리셋
      reset();
    });
  }

  void reset() {
    answerMap.clear();

    pageController.jumpToPage(0);
    testPageController.jumpToPage(0);
    pageIndex = 0;
    pageRatio = 0.2;
    update(['test_page', 'progress_bar', 'bottom_button']);
  }
}
