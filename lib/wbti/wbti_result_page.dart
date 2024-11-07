import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/wbti/wbti_choose_page.dart';
import 'package:nolilteo/wbti/wbti_selection_page.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import 'controller/wbti_result_controller.dart';
import 'model/wbti_type.dart';
import 'wbti_just_result_page.dart';

class WbtiResultPage extends StatefulWidget {
  const WbtiResultPage({Key? key}) : super(key: key);

  static const String route = '/wbti_result';

  @override
  State<WbtiResultPage> createState() => _WbtiResultPageState();
}

class _WbtiResultPageState extends State<WbtiResultPage> {

  final WbtiResultController controller = Get.put(WbtiResultController());
  final PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    GlobalData.pageRouteList.add(WbtiResultPage.route);
  }

  @override
  void dispose() {
    if(GlobalData.pageRouteList.isNotEmpty && GlobalData.pageRouteList.last == WbtiResultPage.route){
      GlobalData.pageRouteList.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showWebAppBar: false,
      child: FutureBuilder(
        future: controller.fetchData(),
        builder: (context, snapshot) {
          return Scaffold(
            // appBar: customAppBar(context,
            //     leading: controller.isMyWbti || GlobalData.pageRouteList.contains(WbtiChoosePage.route) ? null : const SizedBox.shrink(),
            //     title: controller.isMyWbti ? '내 WBTI' : null,
            //     actions: [
            //       if (controller.resultType != WbtiResultController.resultTypeLink) ...[
            //         Padding(
            //           padding: EdgeInsets.only(right: 20 * sizeUnit),
            //           child: TextButton(
            //             onPressed: controller.replayButtonFunc,
            //             child: Text(
            //               '다시하기',
            //               style: STextStyle.body2().copyWith(color: nolColorGrey),
            //             ),
            //           ),
            //         ),
            //       ],
            //     ],
            //     centerTitle: false
            // ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 24 * sizeUnit),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 24 * sizeUnit),
                        child: Text('당 떨어지는 당신에겐 ...', style: STextStyle.body1()),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * sizeUnit),
                  characterBox(controller.wbtiType),
                  SizedBox(height: 16 * sizeUnit),
                  descriptionBox(),
                  SizedBox(height: 16 * sizeUnit),
                  if (!controller.isMyWbti) ...[
                    nolBottomButton(text: controller.buttonText, onTap: controller.buttonFunc),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget characterBox(WbtiType wbtiType) {
    return Container(
      width: 328 * sizeUnit,
      height: 318 * sizeUnit,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14 * sizeUnit),
        border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(wbtiType.title, style: STextStyle.subTitle3().copyWith(color: nolColorOrange)),
          Row(children: [SizedBox(height: 12 * sizeUnit)]),
          Text(wbtiType.name, style: STextStyle.headline2()),
          SizedBox(height: 40 * sizeUnit),
          SvgPicture.asset(
            wbtiType.src,
            height: 150 * sizeUnit,
          ),
        ],
      ),
    );
  }

  Widget descriptionBox() {
    return Container(
      width: 328 * sizeUnit,
      decoration: BoxDecoration(
        color: nolColorOrange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      ),
      padding: EdgeInsets.symmetric(vertical: 24 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text('성향과 업무 스타일', style: STextStyle.highlight3()),
          ),
          SizedBox(height: 8 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text(
              controller.wbtiType.workStyle,
              style: STextStyle.body3().copyWith(height: 1.8),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 24 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text('협업 방법', style: STextStyle.highlight3()),
          ),
          SizedBox(height: 8 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text(
              controller.wbtiType.howToCoWork,
              style: STextStyle.body3().copyWith(height: 1.8),
              textAlign: TextAlign.justify,
            ),
          ),
          SizedBox(height: 24 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text('찰떡궁합 초콜릿', style: STextStyle.highlight3()),
          ),
          SizedBox(height: 16 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: matchCharBox(controller.matchType),
          ),
          SizedBox(height: 24 * sizeUnit),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: Text('다른 초콜릿유형 보기', style: STextStyle.highlight3()),
          ),
          SizedBox(height: 16 * sizeUnit),
          otherCharBox(controller.wbtiType),
          SizedBox(height: 24 * sizeUnit),
          if(controller.resultType != WbtiResultController.resultTypeLogin)...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('내 결과 공유하기', style: STextStyle.highlight3()),
              ],
            ),
            SizedBox(height: 8 * sizeUnit),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: controller.shareFunc,
                  child: Container(
                    width: 56 * sizeUnit,
                    height: 56 * sizeUnit,
                    decoration: BoxDecoration(
                      color: nolColorOrange,
                      borderRadius: BorderRadius.circular(28 * sizeUnit),
                    ),
                    child: Center(
                      child: SvgPicture.asset(
                        GlobalAssets.svgShare,
                        width: 24 * sizeUnit,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget matchCharBox(WbtiType wbtiType) {
    return InkWell(
      onTap: (){
        Get.to(WbtiJustResultPage(wbti: wbtiType));
      },
      child: Container(
        width: 280 * sizeUnit,
        height: 280 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
        ),
        child: Column(
          children: [
            Row(children: [SizedBox(height: 24 * sizeUnit)]),
            Text(wbtiType.title, style: STextStyle.subTitle3().copyWith(color: nolColorOrange)),
            SizedBox(height: 8 * sizeUnit),
            Text(wbtiType.name, style: STextStyle.headline2()),
            Expanded(
              child: Center(
                child: SvgPicture.asset(
                  wbtiType.src,
                  height: 150 * sizeUnit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget otherCharBox(WbtiType wbtiType) {
    //목록에서 제외시킬 wbti 두개 본인, 찰떡궁합
    String wbti1 = WbtiType.getType(wbtiType.perfectMatchType).perfectMatchType;
    String wbti2 = wbtiType.perfectMatchType;
    List<WbtiType> wbtiList = [];
    for (int i = 0; i < WbtiType.wbtiTypeList.length; i++) {
      if (WbtiType.wbtiTypeList[i].perfectMatchType != wbti1 && WbtiType.wbtiTypeList[i].perfectMatchType != wbti2) {
        wbtiList.add(WbtiType.wbtiTypeList[i]);
      }
    }
    wbtiList.shuffle();
    List<Widget> charPageList = List.generate((wbtiList.length / 2).round(), (index) {
      return SizedBox(
        width: 272 * sizeUnit,
        height: 128 * sizeUnit,
        child: Row(
          children: [
            miniWbtiCharacterBox(wbtiList[2 * index]),
            SizedBox(width: 8 * sizeUnit),
            miniWbtiCharacterBox(wbtiList[2 * index + 1]),
          ],
        ),
      );
    });

    Duration duration = const Duration(milliseconds: 500);
    Curve curve = Curves.easeInOut;

    return SizedBox(
      height: 130 * sizeUnit,
      child: Row(
        children: [
          InkWell(
            onTap: (){
              pageController.previousPage(duration: duration, curve: curve);
            },
            child: SizedBox(
              width: 24 * sizeUnit,
              child: SvgPicture.asset(
                GlobalAssets.svgArrowLeft,
                width: 24 * sizeUnit,
              ),
            ),
          ),
          SizedBox(width: 4*sizeUnit),
          Expanded(
            child: PageView(
              controller: pageController,
              children: charPageList,
            ),
          ),
          SizedBox(width: 4*sizeUnit),
          InkWell(
            onTap: (){
              pageController.nextPage(duration: duration, curve: curve);
            },
            child: SizedBox(
              width: 24 * sizeUnit,
              child: SvgPicture.asset(
                GlobalAssets.svgArrowRight,
                width: 24 * sizeUnit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget miniWbtiCharacterBox(WbtiType wbtiType) {
    return InkWell(
      onTap: (){
        Get.to(WbtiJustResultPage(wbti: wbtiType));
      },
      child: Container(
        width: 132 * sizeUnit,
        height: 128 * sizeUnit,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(wbtiType.name, style: STextStyle.subTitle3()),
            SizedBox(height: 8 * sizeUnit),
            SvgPicture.asset(
              wbtiType.src,
              height: 74 * sizeUnit,
            ),
          ],
        ),
      ),
    );
  }
}