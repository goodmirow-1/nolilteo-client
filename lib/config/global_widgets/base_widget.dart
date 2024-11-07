import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';

import '../constants.dart';
import '../web_components/web_right_section.dart';
import 'nol_drawer.dart';
import '../web_components/custom_web_app_bar.dart';
import 'global_widget.dart';

class BaseWidget extends StatelessWidget {
  BaseWidget({Key? key, required this.child, this.onWillPop, this.showSideSection = false, this.showWebAppBar = true, this.webActions, this.selectedCategory}) : super(key: key);

  final Widget child;
  final Future<bool> Function()? onWillPop;
  final bool showSideSection;
  final bool showWebAppBar;
  final String? selectedCategory;
  final List<Widget>? webActions;

  final MainPageController mainPageController = Get.find<MainPageController>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: onWillPop,
        child: Container(
          color: Colors.white,
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0), //사용자 스케일팩터 무시
            child: SafeArea(
              child: Responsive(
                desktop: Column(
                  children: [
                    if (showWebAppBar) CustomWebAppBar(actions: webActions),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Expanded(child: SizedBox.shrink()),
                          if (showSideSection) ...[
                            SizedBox(
                              width: 270 * sizeUnit,
                              child: GetBuilder<MainPageController>(builder: (_) => NolDrawer(selectedCategory: selectedCategory)),
                            ),
                          ],
                          verticalLine(),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: webMaxWidth * sizeUnit),
                            child: child,
                          ),
                          verticalLine(),
                          if (showSideSection) ...[
                            SizedBox(width: 262 * sizeUnit, child: WebRightSection()),
                          ],
                          const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ],
                ),
                tablet: Column(
                  children: [
                    if (showWebAppBar) CustomWebAppBar(actions: webActions),
                    Expanded(
                      child: Row(
                        children: [
                          if (showSideSection) ...[
                            SizedBox(
                              width: 270 * sizeUnit,
                              child: GetBuilder<MainPageController>(builder: (_) => NolDrawer(selectedCategory: selectedCategory)),
                            ),
                          ],
                          if (showWebAppBar) verticalLine(),
                          Expanded(child: child),
                        ],
                      ),
                    ),
                  ],
                ),
                mobile: child,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget verticalLine() {
    return Container(
      width: 1.5 * sizeUnit,
      decoration: const BoxDecoration(
        border: Border(right: BorderSide(color: nolColorLightGrey)),
      ),
    );
  }
}
