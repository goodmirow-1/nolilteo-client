import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/controllers/community_write_or_modify_controller.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/web_components/web_alarm.dart';
import 'package:nolilteo/config/web_components/web_option_box.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/notification/controller/notification_controller.dart';
import 'package:nolilteo/wbti/controller/wbti_controller.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../community/community_write_or_modify_page.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../config/global_widgets/animated_tap_bar.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../config/global_widgets/responsive.dart';

class MainPageController extends GetxController {
  static get to => Get.find<MainPageController>();

  final Duration duration = const Duration(milliseconds: 300);
  final Curve curve = Curves.fastOutSlowIn;

  RxList<String> categoryList = jobCategoryList.obs; // endDrawer 카테고리 리스트
  int currentIndex = 0;
  RxBool showWebAlarm = false.obs; // 웹에서 알림 보여주기 여부

  void changePage(int index) {
    currentIndex = index;
    update();
  }

  // 스크롤, 탭 세팅
  void setScrollAndTab(int index) {
    final CommunityController communityController = Get.find<CommunityController>();

    if (currentIndex != 0 && index == 0) {
      // 다른 페이지에서 대시보드 들어왔을 때 탭 세팅
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (communityController.pageController.hasClients) communityController.pageController.jumpToPage(communityController.showIndex);
      });
    } else if (currentIndex == 0 && index == 0) {
      // 홈탭 한 번 더 눌렀을 때
      if (communityController.scrollController.offset <= 0.1) {
        // 대시보드 스크롤이 상단인 경우
        if (communityController.pageController.hasClients) {
          communityController.pageController.animateToPage(
            communityController.showIndex == Post.postTypeTopic ? Post.postTypeJob : Post.postTypeTopic,
            duration: AnimatedTapBar.duration,
            curve: AnimatedTapBar.curve,
          );
        }
      } else {
        // 대시보드 스크롤이 상단이 아닌 경우
        if (communityController.scrollController.hasClients) {
          communityController.scrollController.animateTo(0.1, duration: duration, curve: curve);
        }
      }
    } else if (currentIndex == 1 && index == 1) {
      // wbti탭 한 번 더 눌렀을 때
      final WbtiController wbtiController = Get.find<WbtiController>();

      // wbti 스크롤이 상단이 아닌 경우
      if (wbtiController.scrollController.offset > 0.1) {
        if (wbtiController.scrollController.hasClients) {
          wbtiController.scrollController.animateTo(0.1, duration: duration, curve: curve);
        }
      } else {
        // 상단인 경우 자기 캐릭터로 이동
        if(wbtiController.selectedWbti.type != GlobalData.loginUser.wbti && GlobalData.loginUser.wbti.isNotEmpty) {
          wbtiController.changeWbti(WbtiType.getType(GlobalData.loginUser.wbti));
        }
      }
    }
  }

  // endDrawer 카테고리 리스트 변경
  void changeCategoryList(bool isJob) {
    if (isJob) {
      categoryList(jobCategoryList);
    } else {
      categoryList(topicCategoryList);
    }
  }

  Future<bool> onWillPop() {
    if (currentIndex != 0) {
      changePage(0);
      return Future.value(false);
    } else {
      return GlobalFunction.isEnd();
    }
  }

  // web 알림 토글
  void showWebAlarmFunc() async {
    NotificationController notificationController = Get.find<NotificationController>();

    await notificationController.setNotificationListByEvent();
    // 알림창 띄우기
    Get.dialog(
      const Center(
        child: WebAlarm(),
      ),
      barrierColor: Colors.transparent,
    );
  }

  // 글쓰기 옵션 박스
  void showWriteOption(BuildContext context) {
    // 글쓰기 페이지 위젯
    Center writePageWidget(int type) {
      return Center(
        child: SizedBox(
          width: 560 * sizeUnit,
          height: 711 * sizeUnit,
          child: CommunityWriteOrModifyPage(isWrite: true, type: type),
        ),
      );
    }

    GlobalFunction.loginCheck(callback: () {
      Get.dialog(
        Stack(
          children: [
            Positioned(
              top: 56 * sizeUnit,
              right: Responsive.isDesktop(context) ? MediaQuery.of(context).size.width * 0.15 : 0,
              child: Container(
                width: 194 * sizeUnit,
                alignment: Alignment.center,
                child: WebOptionBox(
                  children: [
                    WebOptionBoxItem(
                      text: '일터에 쓰기',
                      onTap: () {
                        Get.back(); // 다이어로그 끄기
                        Get.dialog(writePageWidget(Post.postTypeJob)).then((value) => Get.delete<CommunityWriteOrModifyController>());
                      },
                    ),
                    WebOptionBoxItem(
                      text: '놀터에 쓰기',
                      onTap: () {
                        Get.back(); // 다이어로그 끄기
                        Get.dialog(
                          writePageWidget(Post.postTypeTopic),
                        ).then((value) => Get.delete<CommunityWriteOrModifyController>());
                      },
                    ),
                    WebOptionBoxItem(
                      text: 'WBTI에 쓰기',
                      onTap: () {
                        Get.back(); // 다이어로그 끄기
                        Get.dialog(
                          writePageWidget(Post.postTypeWbti),
                        ).then((value) => Get.delete<CommunityWriteOrModifyController>());
                      },
                    ),
                    // WebOptionBoxItem(
                    //   text: '모여라 쓰기',
                    //   onTap: () {
                    //     Get.back(); // 다이어로그 끄기
                    //     Get.dialog(
                    //       writePageWidget(Post.postTypeMeeting),
                    //     ).then((value) => Get.delete<CommunityWriteOrModifyController>());
                    //   },
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
        barrierColor: Colors.transparent,
      );
    });
  }
}
