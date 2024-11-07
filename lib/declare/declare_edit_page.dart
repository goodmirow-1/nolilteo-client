import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/custom_text_field.dart';

import '../config/global_widgets/base_widget.dart';
import '../config/constants.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import 'controller/declare_edit_controller.dart';

class DeclareEditPage extends StatelessWidget {
  DeclareEditPage({Key? key, required this.declareType, required this.declaredID}) : super(key: key);

  final int declareType;
  final int declaredID;

  final DeclareEditController controller = Get.put(DeclareEditController());
  final TextEditingController textEditingController = TextEditingController();

  String getDeclareStr(int type){
    String res = '게시글';

    switch(type){
      case 0: break;
      case 1: res = '댓글'; break;
      case 2: res = '답글'; break;
      case 3: res = '사용자'; break;
    }

    return res;
  }

  @override
  Widget build(BuildContext context) {
    controller.set(declareType: declareType, id: declaredID);
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, 
          title: '${getDeclareStr(declareType)} 신고하기',
          actions: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => controller.send(),
                child: const Center(child: Text('보내기')),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () => GlobalFunction.unFocus(context),
          child: SingleChildScrollView(
            controller: controller.scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLine(),
                  SizedBox(height: 24 * sizeUnit),
                  buildTitle('신고 전 꼭! 확인해주세요.'),
                  SizedBox(height: 8 * sizeUnit),
                  Text(
                    '허위 또는 악의적 신고인 경우 서비스 이용에 제한이 있을 수 있습니다. 신고 후에는 철회 및 수정이 불가능합니다. 신고된 게시글은 검토 후 순차적으로 처리됩니다.',
                    style: STextStyle.body3().copyWith(height: 21 / 14),
                  ),
                  SizedBox(height: 32 * sizeUnit),
                  buildTitle('신고사유를 선택해주세요.'),
                  SizedBox(height: 8 * sizeUnit),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.selectedReportList.length,
                    itemBuilder: (context, index) => reportItem(controller.selectedReportList[index], index),
                  ),
                  SizedBox(height: 16 * sizeUnit),
                  reportContentsWidget(), // 신고 내용 위젯
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 24 * sizeUnit)),
                  Obx(() => nolBottomButton(
                        padding: EdgeInsets.zero,
                        text: '신고하기',
                        isOk: controller.isOk.value,
                        onTap: () => controller.send(),
                      )),
                  SizedBox(height: 16 * sizeUnit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text buildTitle(String text) {
    return Text(
      text,
      style: STextStyle.headline3().copyWith(color: nolColorOrange),
    );
  }

  Widget reportItem(String reportTitle, int index) {
    return InkWell(
      onTap: () {
        controller.head(reportTitle);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.scrollController.animateTo(controller.scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        });
      },
      child: SizedBox(
        height: 36 * sizeUnit,
        child: Row(
          children: [
            Obx(
              () => controller.head.value == reportTitle ? SvgPicture.asset(GlobalAssets.svgCheckCircle) : SvgPicture.asset(GlobalAssets.svgCheckCircleEmpty),
            ),
            SizedBox(width: 8 * sizeUnit),
            Text(
              reportTitle,
              style: STextStyle.body3(),
            )
          ],
        ),
      ),
    );
  }

  Widget reportContentsWidget() {
    return Obx(() => controller.head.value.isEmpty
        ? const SizedBox.shrink()
        : CustomTextField(
            hintText: '상세한 사유를 알려주세요',
            onChanged: (value) => controller.contents(value),
            maxLines: 4,
          ));
  }
}
