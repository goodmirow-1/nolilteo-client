import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../config/global_assets.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../my_page/controller/setting_controller.dart';

class VersionInfoPage extends StatelessWidget {
  VersionInfoPage({Key? key}) : super(key: key);

  final SettingController controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '버전 정보',centerTitle: false),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                GlobalAssets.svgLogo,
                width: 100 * sizeUnit,
                height: 100 * sizeUnit,
              ),
              SizedBox(
                height: 24 * sizeUnit,
              ),
              Text(
                '현재 버전 ${controller.version}',
                style: STextStyle.subTitle1(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
