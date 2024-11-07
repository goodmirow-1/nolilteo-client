import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:nolilteo/wbti/wbti_result_page.dart';

import '../config/constants.dart';
import '../config/global_widgets/responsive.dart';

class WbtiChoosePage extends StatefulWidget {
  const WbtiChoosePage({Key? key}) : super(key: key);

  static const String route = '/wbti_choose';

  @override
  State<WbtiChoosePage> createState() => _WbtiChoosePageState();
}

class _WbtiChoosePageState extends State<WbtiChoosePage> {
  final WbtiChooseController controller = Get.put(WbtiChooseController());

  final List<WbtiType> height74List = [WbtiType.estp, WbtiType.esfj, WbtiType.isfj, WbtiType.istj, WbtiType.infj];
  final List<WbtiType> height86List = [WbtiType.esfp, WbtiType.enfj];

  @override
  void initState() {
    super.initState();
    GlobalData.pageRouteList.add(WbtiChoosePage.route);
  }

  @override
  void dispose() {
    if(GlobalData.pageRouteList.isNotEmpty && GlobalData.pageRouteList.last == WbtiChoosePage.route){
      GlobalData.pageRouteList.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
          appBar: customAppBar(
            context,
            centerTitle: true,
            showAppBar: Responsive.isMobile(context),
            leading: const SizedBox.shrink(),
            title: 'WBTI 선택',
          ),
          body: SingleChildScrollView(
            child: GetBuilder<WbtiChooseController>(
                builder: (_) {
                  return Column(
                    children: [
                      SizedBox(height: 16 * sizeUnit),
                      Center(
                        child: wbtiGridView(),
                      ),
                      SizedBox(height: 16 * sizeUnit),
                      nolBottomButton(
                        text: '선택하기',
                        isOk: controller.wbtiTxt.isNotEmpty,
                        onTap: controller.buttonFunc,
                      ),
                    ],
                  );
                }
            ),
          )),
    );
  }

  Widget wbtiGridView() {
    return SizedBox(
      width: 312 * sizeUnit,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: WbtiType.wbtiTypeListByGanada.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16 * sizeUnit,
          mainAxisSpacing: 16 * sizeUnit,
          childAspectRatio: 148 / 146,
          mainAxisExtent: 146 * sizeUnit,
        ),
        itemBuilder: (context, index) => wbtiInfoWidget(WbtiType.wbtiTypeListByGanada[index]),
      ),
    );
  }

  Widget wbtiInfoWidget(WbtiType wbtiType) {
    double height = 82 * sizeUnit;

    if (height74List.contains(wbtiType)) {
      height = 74 * sizeUnit;
    } else if (height86List.contains(wbtiType)) {
      height = 86 * sizeUnit;
    }

    return InkWell(
      onTap: () {
        controller.wbtiTxt = wbtiType.type;
        controller.update();
      },
      borderRadius: BorderRadius.circular(14 * sizeUnit),
      child: Container(
        padding: EdgeInsets.only(top: 16 * sizeUnit),
        width: 148 * sizeUnit,
        height: 146 * sizeUnit,
        decoration: BoxDecoration(
          border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          color: controller.wbtiTxt == wbtiType.type ? nolColorOrange : Colors.white,
        ),
        child: Column(
          children: [
            Text(
              wbtiType.title,
              style: STextStyle.subTitle3().copyWith(color: controller.wbtiTxt == wbtiType.type ? Colors.white : nolColorOrange),
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
}

class WbtiChooseController extends GetxController{
  static get to => Get.find<WbtiChooseController>();

  String wbtiTxt = '';

  void buttonFunc(){
    Get.toNamed('${WbtiResultPage.route}/$wbtiTxt');
  }
}