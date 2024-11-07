import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/wbti/wbti_choose_page.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/global_widgets/responsive.dart';
import '../config/s_text_style.dart';
import 'controller/wbti_test_controller.dart';
import 'model/wbti_question.dart';

class WbtiTestPage extends StatefulWidget {
  const WbtiTestPage({Key? key}) : super(key: key);

  static const String route = '/wbtiTest';

  @override
  State<WbtiTestPage> createState() => _WbtiTestPageState();
}

class _WbtiTestPageState extends State<WbtiTestPage> {
  final PageController pageController = PageController();
  final PageController testPageController = PageController();
  final WbtiTestController controller = Get.put(WbtiTestController());
  final TextEditingController jobTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GlobalData.pageRouteList.add(WbtiTestPage.route);
  }

  @override
  void dispose() {
    pageController.dispose();
    testPageController.dispose();
    if (GlobalData.pageRouteList.isNotEmpty && GlobalData.pageRouteList.last == WbtiTestPage.route) {
      GlobalData.pageRouteList.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showWebAppBar: false,
      onWillPop: () {
        controller.backFunc(testPageController);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => GlobalFunction.unFocus(context),
        child: FutureBuilder(
            future: controller.fetchData(pageController, testPageController),
            builder: (context, snapshot) {
              return Scaffold(
                appBar: customAppBar(
                  context,
                  leadingWidth: Responsive.isMobile(context) ? null : 48 * sizeUnit,
                  leading: GetBuilder<WbtiTestController>(
                    id: 'bottom_button',
                    builder: (_) => controller.pageIndex == 0
                        ? const SizedBox.shrink()
                        : InkWell(
                            onTap: () {
                              controller.backFunc(testPageController);
                            },
                            child: Center(
                              child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
                            ),
                          ),
                  ),
                ),
                body: Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: controller.pageChangeFunc,
                        children: [
                          chooseTestPage(),
                          testPage(),
                        ],
                      ),
                    ),
                    GetBuilder<WbtiTestController>(
                        id: 'bottom_button',
                        builder: (_) {
                          if (controller.pageIndex == 0) {
                            return Padding(
                              padding: EdgeInsets.only(left: 32 * sizeUnit, right: 32 * sizeUnit, bottom: 24 * sizeUnit),
                              child: SizedBox(
                                height: 48 * sizeUnit,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // if (controller.isFirstLogin || controller.isEdit) ...[
                                    //   SizedBox(
                                    //     width: 144 * sizeUnit,
                                    //     height: 48 * sizeUnit,
                                    //     child: nolRoundFitButton(
                                    //       text: '직접선택',
                                    //       color: nolColorGrey,
                                    //       onTap: () {
                                    //         Get.to(() => const WbtiChoosePage());
                                    //       },
                                    //     ),
                                    //   ),
                                    //   const Spacer(),
                                    // ],
                                    SizedBox(
                                      width: (controller.isFirstLogin || controller.isEdit) ? 144 * sizeUnit : 296 * sizeUnit,
                                      height: 48 * sizeUnit,
                                      child: nolRoundFitButton(
                                        text: '검사하기',
                                        onTap: () {
                                          controller.bottomButtonFunc(pageController, testPageController);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return nolBottomButton(
                              text: controller.buttonText,
                              isOk: controller.isCanNext(),
                              onTap: () {
                                GlobalFunction.unFocus(context);
                                if (controller.isCanNext()) {
                                  controller.bottomButtonFunc(pageController, testPageController);
                                }
                              });
                        })
                  ],
                ),
              );
            }),
      ),
    );
  }

  Widget chooseTestPage() {
    const String svgWbtiTest = 'assets/images/login/wbti_test.svg';
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 24 * sizeUnit),
          SizedBox(
            height: 30 * sizeUnit,
            child: Text(
              '직장에서 나는 어떤 스타일일까?',
              style: STextStyle.headline3().copyWith(color: nolColorOrange),
            ),
          ),
          SizedBox(height: 8 * sizeUnit),
          Text(
            'WBTI 테스트',
            style: STextStyle.headline1(),
          ),
          SizedBox(height: 2 * sizeUnit),
          Text(
            '(Work Business Type Indicator)',
            style: STextStyle.body4(),
          ),
          SizedBox(height: 16 * sizeUnit),
          SvgPicture.asset(svgWbtiTest, width: 200 * sizeUnit),
          SizedBox(height: 24 * sizeUnit),
          Text(
            '평소 내 MBTI는 알겠는데..\n일할 때 나는 정반대의 사람이 되더라구요\n직장에서 나는 어떤스타일일까?\n\nWBTI검사하면 알 수 있어요!\n내 캐릭터도 얻고 나만의 타이틀을 만들어봐요',
            style: STextStyle.body3().copyWith(height: 1.5, color: nolColorOrange),
          ),
        ],
      ),
    );
  }

  Widget testPage() {
    return Column(
      children: [
        SizedBox(height: 24 * sizeUnit),
        Row(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 24 * sizeUnit),
              child: SizedBox(
                height: 30 * sizeUnit,
                child: Text(
                  '답변을 체크해주세요',
                  style: STextStyle.headline3(),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 24 * sizeUnit),
        GetBuilder<WbtiTestController>(
          id: 'progress_bar',
          builder: (context) {
            return progressBar(controller.pageRatio);
          },
        ),
        Expanded(
          child: GetBuilder<WbtiTestController>(
            id: 'test_page',
            builder: (_) {
              return PageView(
                controller: testPageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: controller.testPageChangeFunc,
                children: [
                  questionPage(0),
                  questionPage(1),
                  questionPage(2),
                  questionPage(3),
                  questionPage(4),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget progressBar(double ratio) {
    return Container(
      width: 240 * sizeUnit,
      height: 4 * sizeUnit,
      color: nolColorOrange.withOpacity(0.4),
      child: Row(
        children: [
          Container(
            width: 240 * ratio * sizeUnit,
            height: 4 * sizeUnit,
            color: nolColorOrange,
          ),
        ],
      ),
    );
  }

  Widget questionPage(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        questionBox(4 * index),
        questionBox(4 * index + 1),
        questionBox(4 * index + 2),
        questionBox(4 * index + 3),
      ],
    );
  }

  Widget questionBox(int index) {
    WbtiQuestion question = controller.questionList[index];

    List answerList = [false, false, false, false, false];

    if (controller.answerMap[index] != null) {
      answerList[controller.answerMap[index]!] = true;
    }

    return SizedBox(
      width: 340 * sizeUnit,
      height: 85 * sizeUnit,
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              text: '${index + 1}. ${question.question1}\n',
              children: [TextSpan(text: question.question2)],
            ),
            style: STextStyle.body3().copyWith(height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8 * sizeUnit),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('비동의', style: STextStyle.body4().copyWith(color: nolColorOrange)),
              SizedBox(width: 16 * sizeUnit),
              checkableCircle(index, 0, answerList[0]),
              SizedBox(width: 16 * sizeUnit),
              checkableCircle(index, 1, answerList[1]),
              SizedBox(width: 16 * sizeUnit),
              checkableCircle(index, 2, answerList[2]),
              SizedBox(width: 16 * sizeUnit),
              checkableCircle(index, 3, answerList[3]),
              SizedBox(width: 16 * sizeUnit),
              checkableCircle(index, 4, answerList[4]),
              SizedBox(width: 16 * sizeUnit),
              Text('동의', style: STextStyle.body4().copyWith(color: nolColorOrange)),
            ],
          ),
        ],
      ),
    );
  }

  Widget checkableCircle(int questionIndex, int index, bool isCheck) {
    double size = 0;
    switch (index) {
      case 0:
      case 4:
        size = 34 * sizeUnit;
        break;
      case 1:
      case 3:
        size = 26 * sizeUnit;
        break;
      case 2:
        size = 16 * sizeUnit;
        break;
    }
    return InkWell(
      onTap: () {
        controller.choseAnswer(questionIndex, index);
      },
      borderRadius: BorderRadius.circular(index == 2 ? 13 * sizeUnit : size / 2),
      child: SizedBox(
        width: index == 2 ? 26 * sizeUnit : null,
        height: index == 2 ? 26 * sizeUnit : null,
        child: Center(
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isCheck ? nolColorOrange : Colors.transparent,
              borderRadius: BorderRadius.circular(size / 2),
              border: isCheck ? null : Border.all(color: nolColorGrey, width: 2 * sizeUnit),
            ),
          ),
        ),
      ),
    );
  }
}
