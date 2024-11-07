import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';

import '../../community/community_write_or_modify_page.dart';
import '../../community/models/post.dart';
import '../constants.dart';
import 'global_widget.dart';

class CustomNavigationBar extends StatelessWidget {
  CustomNavigationBar({Key? key}) : super(key: key);

  final MainPageController controller = Get.find<MainPageController>();

  final List<Map<String, dynamic>> navItemList = [
    {'title': 'HOME', 'iconPath': 'assets/images/global/home.svg', 'activeIconPath': 'assets/images/global/home_active.svg'},
    // {'title': 'GATHERING', 'iconPath': 'assets/images/global/gathering.svg', 'activeIconPath': 'assets/images/global/gathering_active.svg'},
    {'title': 'WBTI', 'iconPath': 'assets/images/global/wbti.svg', 'activeIconPath': 'assets/images/global/wbti_active.svg'},
    {'title': 'ACCOUNT', 'iconPath': 'assets/images/global/account.svg', 'activeIconPath': 'assets/images/global/account_active.svg'},
    {'title': 'WRITING', 'iconPath': 'assets/images/global/writing.svg', 'activeIconPath': 'assets/images/global/writing.svg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56 * sizeUnit,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: nolColorLightGrey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navItemList.length, (index) {
          final Map<String, dynamic> navData = navItemList[index];

          return navBarItem(
              isCurrentIndex: index == controller.currentIndex,
              title: navData['title'],
              iconPath: navData['iconPath'],
              activeIconPath: navData['activeIconPath'],
              onTap: () {
                if (index != 3) {
                  controller.setScrollAndTab(index); // 스크롤, 탭 세팅
                  controller.changePage(index);
                } else {
                  GlobalFunction.loginCheck(callback: () => showWriteBottomSheet(context));
                }
              });
        }),
      ),
    );
  }

  Widget navBarItem({
    required bool isCurrentIndex,
    required String title,
    required String iconPath,
    required String activeIconPath,
    required GestureTapCallback onTap,
  }) {
    final bool isWriting = title == 'WRITING';

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            isCurrentIndex ? activeIconPath : iconPath,
            width: isWriting ? 40 * sizeUnit : 24 * sizeUnit,
            height: isWriting ? 40 * sizeUnit : 24 * sizeUnit,
          ),
        ],
      ),
    );
  }

  // 글쓰기 바텀 시트
  void showWriteBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * sizeUnit),
          topRight: Radius.circular(20 * sizeUnit),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8 * sizeUnit),
            bottomSheetItem(
              text: '일터에 쓰기',
              onTap: () {
                Get.back(); // 바텀 시트 끄기
                Get.to(() => CommunityWriteOrModifyPage(isWrite: true, type: Post.postTypeJob));
              },
            ),
            bottomSheetItem(
              text: '놀터에 쓰기',
              onTap: () {
                Get.back(); // 바텀 시트 끄기
                Get.to(() => CommunityWriteOrModifyPage(isWrite: true, type: Post.postTypeTopic));
              },
            ),
            bottomSheetItem(
              text: 'WBTI에 쓰기',
              onTap: () {
                Get.back(); // 바텀 시트 끄기
                Get.to(() => CommunityWriteOrModifyPage(isWrite: true, type: Post.postTypeWbti));
              },
            ),
            // bottomSheetItem(
            //   text: '모여라 쓰기',
            //   onTap: () {
            //     Get.back(); // 바텀 시트 끄기
            //     Get.to(() => CommunityWriteOrModifyPage(isWrite: true, type: Post.postTypeMeeting));
            //   },
            // ),
            bottomSheetCancelButton(),
          ],
        );
      },
    );
  }
}
