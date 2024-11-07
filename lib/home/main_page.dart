import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/community_page.dart';
import 'package:nolilteo/config/global_widgets/custom_navigation_bar.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/wbti/wbti_page.dart';

import '../config/global_widgets/nol_drawer.dart';
import '../my_page/my_page.dart';

class MainPage extends StatelessWidget {
  MainPage({Key? key}) : super(key: key);
  static const String route = '/main';
  static GlobalKey<ScaffoldState> mainPageScaffoldKey = GlobalKey<ScaffoldState>();

  final MainPageController controller = Get.find<MainPageController>();
  final List<Widget> widgetOptions = [
    CommunityPage(),
    // MeetingPage(),
    WbtiPage(),
    MyPage(),
    const SizedBox.shrink(),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: controller.onWillPop,
        child: Container(
          color: Colors.white,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: SafeArea(
              child: mainView(context),
            ),
          ),
        ),
      ),
    );
  }

  Widget mainView(BuildContext context) {
    return GetBuilder<MainPageController>(builder: (_) {
      return Scaffold(
        key: MainPage.mainPageScaffoldKey,
        body: widgetOptions[controller.currentIndex],
        drawer: NolDrawer(),
        bottomNavigationBar: Responsive.isMobile(context) ? CustomNavigationBar() : null,
        drawerEnableOpenDragGesture: Responsive.isMobile(context) && controller.currentIndex != 2, // mobile 경우에만 제스쳐로 열리게 && dashboard 에서만
      );
    });
  }
}
