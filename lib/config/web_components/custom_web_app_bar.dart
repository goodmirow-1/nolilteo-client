import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/controllers/community_controller.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/home/main_page.dart';

import '../constants.dart';
import '../global_widgets/global_widget.dart';

class CustomWebAppBar extends StatelessWidget {
  CustomWebAppBar({Key? key, this.actions}) : super(key: key);

  final List<Widget>? actions;

  final MainPageController controller = Get.find<MainPageController>();
  final List<Map<String, dynamic>> navItemList = [
    {'iconPath': 'assets/images/global/home.svg', 'activeIconPath': 'assets/images/global/home_active.svg'},
    // {'iconPath': 'assets/images/global/gathering.svg', 'activeIconPath': 'assets/images/global/gathering_active.svg'},
    {'iconPath': 'assets/images/global/wbti.svg', 'activeIconPath': 'assets/images/global/wbti_active.svg'},
    {'iconPath': 'assets/images/global/alarm.svg', 'activeIconPath': 'assets/images/global/alarm_active.svg'},
    {'iconPath': 'assets/images/global/account.svg', 'activeIconPath': 'assets/images/global/account_active.svg'},
    {'iconPath': 'assets/images/global/writing.svg', 'activeIconPath': 'assets/images/global/writing.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        width: double.infinity,
        height: 56 * sizeUnit,
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: nolColorLightGrey))),
        alignment: Alignment.center,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 1060 * sizeUnit),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    webLogo(),
                    if (actions != null) ...[
                      const Spacer(),
                      Row(children: List.generate(actions!.length, (index) => actions![index])),
                      SizedBox(width: 24 * sizeUnit),
                    ],
                  ],
                ),
              ),
              Row(
                children: List.generate(navItemList.length, (index) {
                  return navBarItem(
                      index: index,
                      onTap: () {
                        if (index == 2) {
                          controller.showWebAlarmFunc(); // 알림 띄우기
                        } else if (index == navItemList.length - 1) {
                          controller.showWriteOption(context); // 글쓰기 옵션
                        } else {
                          // 그 외 네비게이션
                          final int idx = index == 3 ? index - 1 : index;

                          // 메인 페이지가 아니라면 메인 페이지로 가기
                          if (Get.currentRoute != MainPage.route) {
                            GlobalFunction.goToMainPage(); // 메인 페이지로 이동
                          } else {
                            controller.setScrollAndTab(idx); // 스크롤, 탭 세팅
                          }

                          controller.changePage(idx);
                        }
                      });
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navBarItem({
    required int index,
    required GestureTapCallback onTap,
  }) {
    final Map<String, dynamic> navData = navItemList[index];
    final bool isCurrentIndex = index == (controller.currentIndex == 2 ? 3 : controller.currentIndex);
    final bool isWriting = index == navItemList.length - 1;
    final String iconPath = navData['iconPath'];
    final String activeIconPath = navData['activeIconPath'];

    return Padding(
      padding: EdgeInsets.only(right: index == navItemList.length - 1 ? 0 : 24 * sizeUnit),
      child: InkWell(
        borderRadius: isWriting ? BorderRadius.circular(20 * sizeUnit) : null,
        onTap: onTap,
        child: SvgPicture.asset(
          isCurrentIndex ? activeIconPath : iconPath,
          width: isWriting ? 40 * sizeUnit : 24 * sizeUnit,
          height: isWriting ? 40 * sizeUnit : 24 * sizeUnit,
          color: index == 2 && !isCurrentIndex ? nolColorGrey : null,
        ),
      ),
    );
  }

  Widget webLogo() {
    return InkWell(
      onTap: () {
        GlobalFunction.goToMainPage(); // 메인 페이지로 이동
        controller.changePage(0);

        CommunityController communityController = Get.find<CommunityController>();
        communityController.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
        communityController.onRefresh();
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'WBTI',
            style: STextStyle.headline2().copyWith(
              color: nolColorOrange,
              fontSize: 28 * sizeUnit,
            ),
          ),
          SizedBox(width: 8 * sizeUnit),
          Text('직장인들의 놀이터', style: STextStyle.subTitle1()),
        ],
      ),
    );
  }
}
