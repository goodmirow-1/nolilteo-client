import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:get/get.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:reorderables/reorderables.dart';

import '../config/constants.dart';
import '../config/global_widgets/responsive.dart';
import 'controller/wbti_controller.dart';

class WbtiSelectionPage extends StatelessWidget {
  WbtiSelectionPage({Key? key}) : super(key: key);

  final WbtiController controller = Get.find<WbtiController>();
  final List<WbtiType> height74List = [WbtiType.estp, WbtiType.esfj, WbtiType.isfj, WbtiType.istj, WbtiType.infj];
  final List<WbtiType> height86List = [WbtiType.esfp, WbtiType.enfj];

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showSideSection: true,
      webActions: actions(),
      child: GetBuilder<WbtiController>(
        builder: (_) => Scaffold(
            appBar: customAppBar(
              context,
              centerTitle: true,
              showAppBar: Responsive.isMobile(context),
              leading: const SizedBox.shrink(),
              title: 'WBTI 게시판',
              actions: actions(),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 16 * sizeUnit),
                  Center(
                    child: controller.isWbtiEditMode ? wbtiEditListView() : wbtiGridView(),
                  ),
                  SizedBox(height: 16 * sizeUnit),
                ],
              ),
            )),
      ),
    );
  }

  Widget wbtiGridView() {
    return SizedBox(
      width: 312 * sizeUnit,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: GlobalData.customWbtiList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16 * sizeUnit,
          mainAxisSpacing: 16 * sizeUnit,
          childAspectRatio: 148 / 146,
          mainAxisExtent: 146 * sizeUnit,
        ),
        itemBuilder: (context, index) => wbtiInfoWidget(GlobalData.customWbtiList[index]),
      ),
    );
  }

  Widget wbtiEditListView() {
    return Obx(() {
      List<Widget> list = List.generate(
          controller.editWbtiList.length,
          (index) => Stack(
                clipBehavior: Clip.none,
                children: [
                  wbtiInfoWidget(controller.editWbtiList[index]),
                  Positioned(
                    right: -6,
                    top: -6,
                    child: SvgPicture.asset(GlobalAssets.svgHandle, width: 24 * sizeUnit),
                  ),
                ],
              ));

      return ReorderableWrap(
        spacing: 16 * sizeUnit,
        runSpacing: 16 * sizeUnit,
        maxMainAxisCount: 2,
        buildDraggableFeedback: (context, boxConstraints, widget) {
          return Material(type: MaterialType.transparency, child: widget);
        },
        onReorder: (int oldIndex, int newIndex) {
          final element = controller.editWbtiList.removeAt(oldIndex);
          controller.editWbtiList.insert(newIndex, element);
        },
        needsLongPressDraggable: false,
        children: list,
      );
    });
  }

  Widget wbtiInfoWidget(WbtiType wbtiType) {
    double height = 82 * sizeUnit;

    if (height74List.contains(wbtiType)) {
      height = 74 * sizeUnit;
    } else if (height86List.contains(wbtiType)) {
      height = 86 * sizeUnit;
    }

    return InkWell(
      onTap: () => controller.selectWbti(wbtiType),
      borderRadius: BorderRadius.circular(14 * sizeUnit),
      child: Container(
        padding: EdgeInsets.only(top: 16 * sizeUnit),
        width: 148 * sizeUnit,
        height: 146 * sizeUnit,
        decoration: BoxDecoration(
          border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
        ),
        child: Column(
          children: [
            Text(
              wbtiType.title,
              style: STextStyle.subTitle3().copyWith(color: nolColorOrange),
            ),
            SizedBox(height: 4 * sizeUnit),
            Text(
              wbtiType.name,
              style: STextStyle.subTitle2().copyWith(),
            ),
            SizedBox(height: 8 * sizeUnit),
            SvgPicture.asset(wbtiType.src, height: height),
          ],
        ),
      ),
    );
  }

  List<Widget> actions() {
    return [
      Center(
        child: InkWell(
          onTap: () => controller.toggleWbtiEdit(),
          child: Text(
            controller.isWbtiEditMode ? '완료' : '편집',
            style: STextStyle.subTitle1().copyWith(color: controller.isWbtiEditMode ? nolColorOrange : nolColorGrey),
          ),
        ),
      ),
      SizedBox(width: 16 * sizeUnit),
    ];
  }
}
