import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/wbti/controller/wbti_controller.dart';
import 'package:nolilteo/wbti/wbti_test_page.dart';

import '../../community/board_page.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../wbti/model/wbti_type.dart';
import '../constants.dart';
import '../global_assets.dart';
import '../global_function.dart';
import '../s_text_style.dart';
import 'global_widget.dart';
import 'responsive.dart';

class NolDrawer extends StatelessWidget {
  NolDrawer({Key? key, this.selectedCategory}) : super(key: key);

  final String? selectedCategory;
  final MainPageController controller = Get.find<MainPageController>();

  @override
  Widget build(BuildContext context) {
    Widget dashboardDrawer() {
      return Drawer(
          width: Responsive.isMobile(context) ? null : double.infinity,
          backgroundColor: Colors.white,
          elevation: 0.0,
          child: Obx(
            () {
              final bool isJob = Get.isRegistered<CommunityController>() ? CommunityController.to.isJob : true;

              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context) ? 0 : 16 * sizeUnit),
                    child: Container(
                      width: double.infinity,
                      height: 48 * sizeUnit,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        isJob ? '일터 게시판' : '놀터 게시판',
                        style: STextStyle.highlight1().copyWith(height: 1.2),
                      ),
                    ),
                  ),
                  if (Responsive.isMobile(context)) buildLine(),
                  Expanded(
                    child: ListView(
                      children: List.generate(controller.categoryList.length, (index) {
                        final String category = controller.categoryList[index];

                        return InkWell(
                          onTap: () {
                            Get.toNamed('${BoardPage.route}/${GlobalFunction.encodeUrl(category)}?type=${isJob ? Post.postTypeJob : Post.postTypeTopic}');
                          },
                          child: Padding(
                            padding: Responsive.isDesktop(context)
                                ? EdgeInsets.fromLTRB(0, 0, 20 * sizeUnit, 0)
                                : EdgeInsets.fromLTRB(
                                    16 * sizeUnit,
                                    Responsive.isTablet(context)
                                        ? 0
                                        : index == 0
                                            ? 8 * sizeUnit
                                            : 0,
                                    16 * sizeUnit,
                                    0),
                            child: SizedBox(
                              width: double.infinity,
                              height: 48 * sizeUnit,
                              child: Row(
                                children: [
                                  Text(
                                    category,
                                    style: STextStyle.subTitle1().copyWith(
                                      color: selectedCategory == category ? nolColorOrange : nolColorBlack,
                                    ),
                                  ),
                                  const Spacer(),
                                  SvgPicture.asset(
                                    GlobalAssets.svgArrowRight,
                                    width: 24 * sizeUnit,
                                    color: selectedCategory == category ? nolColorOrange : nolColorBlack,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ));
    }

    Widget meetingPageDrawer() {
      return Drawer(
        width: Responsive.isMobile(context) ? null : double.infinity,
        backgroundColor: Colors.white,
        elevation: 0.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context) ? 0 : 16 * sizeUnit),
              child: SizedBox(
                width: double.infinity,
                height: 48 * sizeUnit,
                child: Row(
                  children: [
                    if (Responsive.isMobile(context)) ...[
                      InkWell(
                        onTap: () => Get.back(),
                        child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
                      ),
                      SizedBox(width: 8 * sizeUnit),
                    ],
                    Text(
                      '모여라 게시판',
                      style: STextStyle.highlight1().copyWith(height: 1.2),
                    ),
                  ],
                ),
              ),
            ),
            if (Responsive.isMobile(context)) buildLine(),
            Expanded(
              child: Padding(
                padding: Responsive.isDesktop(context) ? EdgeInsets.only(right: 20 * sizeUnit) : EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                child: ListView(
                  children: List.generate(topicCategoryList.length + jobCategoryList.length + 2, (index) {
                    late final String text;

                    Padding buildTitle(String text) {
                      return Padding(
                        padding: EdgeInsets.only(top: 16 * sizeUnit, bottom: 8 * sizeUnit),
                        child: Text(text, style: STextStyle.highlight1().copyWith(color: nolColorOrange)),
                      );
                    }

                    if (index == 0) {
                      text = '놀터';
                      return buildTitle(text);
                    } else if (index <= topicCategoryList.length) {
                      text = topicCategoryList[index - 1];
                    } else if (index == topicCategoryList.length + 1) {
                      text = '일터';
                      return buildTitle(text);
                    } else {
                      text = jobCategoryList[index - (topicCategoryList.length + 2)];
                    }

                    return InkWell(
                      onTap: () => Get.toNamed('${BoardPage.route}/${GlobalFunction.encodeUrl(text)}?type=${Post.postTypeMeeting}'),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48 * sizeUnit,
                        child: Row(
                          children: [
                            Text(
                              text,
                              style: STextStyle.subTitle1(),
                            ),
                            const Spacer(),
                            SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget wbtiDrawer() {
      return Drawer(
          width: Responsive.isMobile(context) ? null : double.infinity,
          backgroundColor: Colors.white,
          elevation: 0.0,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Responsive.isDesktop(context) ? 0 : 16 * sizeUnit),
                child: Container(
                  width: double.infinity,
                  height: 48 * sizeUnit,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WBTI 게시판',
                        style: STextStyle.highlight1().copyWith(height: 1.2),
                      ),
                      if(kIsWeb)...[
                        Padding(
                          padding: EdgeInsets.only(right: Responsive.isDesktop(context) ? 16 * sizeUnit : 0),
                          child: InkWell(
                            onTap: () => Get.to(() => const WbtiTestPage()),
                            child: Text(
                              '테스트 하러 가기',
                              style: STextStyle.body4().copyWith(color: nolColorOrange),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (Responsive.isMobile(context)) buildLine(),
              Expanded(
                child: ListView(
                  children: List.generate(GlobalData.customWbtiList.length, (index) {
                    final WbtiType wbtiType = GlobalData.customWbtiList[index];

                    return InkWell(
                      onTap: () {
                        final WbtiController wbtiController = Get.find<WbtiController>();

                        if (Responsive.isMobile(context)) Get.back(); // drawer 끄기
                        GlobalFunction.goToMainPage(); // 메인 페이지로 이동
                        wbtiController.changeWbti(wbtiType);
                      },
                      child: Padding(
                        padding: Responsive.isDesktop(context)
                            ? EdgeInsets.fromLTRB(0, 0, 20 * sizeUnit, 0)
                            : EdgeInsets.fromLTRB(
                                16 * sizeUnit,
                                Responsive.isTablet(context)
                                    ? 0
                                    : index == 0
                                        ? 8 * sizeUnit
                                        : 0,
                                16 * sizeUnit,
                                0,
                              ),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48 * sizeUnit,
                          child: Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(wbtiType.title, style: STextStyle.subTitle3().copyWith(color: nolColorOrange)),
                                  SizedBox(height: 2 * sizeUnit),
                                  Text(
                                    wbtiType.name,
                                    style: STextStyle.subTitle1().copyWith(
                                      color: selectedCategory == wbtiType.name ? nolColorOrange : nolColorBlack,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              SvgPicture.asset(
                                GlobalAssets.svgArrowRight,
                                width: 24 * sizeUnit,
                                color: selectedCategory == wbtiType.name ? nolColorOrange : nolColorBlack,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ));
    }

    if (controller.currentIndex == 0) {
      return dashboardDrawer();
    } else if (controller.currentIndex == 1) {
      return wbtiDrawer();
    }

    return dashboardDrawer();
  }
}
