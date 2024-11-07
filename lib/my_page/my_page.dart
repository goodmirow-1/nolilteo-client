import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:nolilteo/wbti/wbti_just_result_page.dart';

import '../config/global_widgets/base_widget.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/global_widgets/responsive.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import '../my_page/controller/my_page_controller.dart';

class MyPage extends StatelessWidget {
  MyPage({Key? key}) : super(key: key);

  final MyPageController controller = Get.find<MyPageController>();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      webActions: GlobalData.loginUser.id == nullInt ? null : actions(),
      child: Scaffold(
        appBar: myPageAppBar(context),
        body: GetBuilder<MyPageController>(
          id: 'fetchData',
          initState: (_) => controller.fetchData(),
          builder: (_) {
            if (controller.user.id == nullInt) {
              return noLoginInduceWidget();
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  nicknameWbtiBox(),
                  nolDivider(),
                  myPageContainer(
                    text: '내 게시글',
                    onTap: controller.goMyPostPage,
                  ),
                  nolDivider(),
                  myPageContainer(
                    text: '좋아요한 글',
                    onTap: controller.goMyLikePage,
                  ),
                  nolDivider(),
                  myPageContainer(
                    text: '댓글단 글',
                    onTap: controller.goMyReplyPage,
                  ),
                  // nolDivider(),
                  // myPageContainer(
                  //   text: '모여라 활동',
                  //   onTap: controller.goMyGatheringPage,
                  // ),
                  nolDivider(),
                  if (controller.wbtiText.isNotEmpty) ...[
                    myPageContainer(
                      text: '내 WBTI',
                      onTap: controller.goMyWBTIPage,
                    ),
                    nolDivider(),
                  ],
                  myPageContainer(
                    text: '차단관리',
                    onTap: controller.goBlockManagementPage,
                  ),
                  if(!kIsWeb) ... [
                    nolDivider(),
                    myPageContainer(
                      text: 'WBTI 웹 로그인',
                      onTap: controller.goWebLoginPage,
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSize? myPageAppBar(BuildContext context) {
    return customAppBar(
      context,
      showAppBar: Responsive.isMobile(context),
      leading: const SizedBox.shrink(),
      titleWidget: Text('내 정보', style: STextStyle.appBar()),
      centerTitle: true,
      actions: GlobalData.loginUser.id != nullInt ? actions() : null,
    );
  }

  static List<Widget> actions(){
    final MyPageController controller = Get.find<MyPageController>();

    return [
        Center(
          child: InkWell(
            onTap: controller.settingButtonFunc,
            child: SvgPicture.asset(
              GlobalAssets.svgSetUp,
              width: 24 * sizeUnit,
            ),
          ),
        ),
        SizedBox(width: 16 * sizeUnit),
      ];
  }

  Widget nicknameWbtiBox() {
    return Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Container(
        width: 328 * sizeUnit,
        height: 318 * sizeUnit,
        decoration: BoxDecoration(
          border: Border.all(
            color: nolColorLightGrey,
            width: 2 * sizeUnit,
          ),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
        ),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 76 * sizeUnit,
              child: Row(
                children: [
                  SizedBox(
                    width: 270 * sizeUnit,
                    height: 76 * sizeUnit,
                    child: Padding(
                      padding: EdgeInsets.only(left: 16 * sizeUnit),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.nickname,
                            style: STextStyle.highlight1(),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (controller.wbtiText.isNotEmpty) ...[
                            SizedBox(height: 6 * sizeUnit),
                            Text(controller.wbtiText, style: STextStyle.subTitle2().copyWith(color: nolColorOrange)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(right: 16 * sizeUnit),
                    child: InkWell(
                      onTap: controller.editButtonFunction,
                      child: SizedBox(
                        width: 32 * sizeUnit,
                        height: 24 * sizeUnit,
                        child: Center(
                          child: Text('수정', style: STextStyle.body3().copyWith(color: nolColorGrey)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: InkWell(
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                onTap: () => Get.to(() => WbtiJustResultPage(wbti: WbtiType.getType(GlobalData.loginUser.wbti))),
                child: Center(
                  child: SvgPicture.asset(
                    controller.wbtiImg,
                    height: 150 * sizeUnit,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget myPageContainer({required String text, Function()? onTap}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 56 * sizeUnit,
        child: Row(
          children: [
            SizedBox(width: 24 * sizeUnit),
            Text(
              text,
              style: STextStyle.subTitle1(),
            ),
            const Spacer(),
            SvgPicture.asset(
              GlobalAssets.svgArrowRight,
              width: 24 * sizeUnit,
              color: nolColorGrey,
            ),
            SizedBox(width: 16 * sizeUnit),
          ],
        ),
      ),
    );
  }
}
