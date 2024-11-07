import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../my_page/controller/setting_controller.dart';

class SettingPage extends StatelessWidget {
  SettingPage({Key? key}) : super(key: key);

  final SettingController controller = Get.put(SettingController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '설정',centerTitle: false),
        body: GetBuilder<SettingController>(
            initState: (_) => controller.fetchData(),
            builder: (_) {
              return ListView(
                children: [
                  nolDivider(),
                  if(!kIsWeb) ... [
                    settingBox(text: '푸시 알림', textColor: nolColorOrange, withArrow: false),
                    nolDivider(),
                    alarmSwitchBox(
                      text: '푸시 알림 설정',
                      value: controller.pushAlarmAll,
                      switchFunc: controller.changePushAlarmAllFunc,
                      haveFrontIcon: false,
                    ),
                    nolDivider(),
                    alarmSwitchBox(
                      text: '놀터 알림',
                      value: controller.pushAlarmNol,
                      switchFunc: controller.changePushAlarmNolFunc,
                    ),
                    nolDivider(),
                    alarmSwitchBox(
                      text: '일터 알림',
                      value: controller.pushAlarmIl,
                      switchFunc: controller.changePushAlarmIlFunc,
                    ),
                    // nolDivider(),
                    // alarmSwitchBox(
                    //   text: '모여라 알림',
                    //   value: controller.pushAlarmMeeting,
                    //   switchFunc: controller.changePushAlarmMeetingFunc,
                    // ),
                    nolDivider(),
                    alarmSwitchBox(
                      text: '댓글 단 게시글 알림',
                      value: controller.pushAlarmReplying,
                      switchFunc: controller.changePushAlarmReplyingFunc,
                    ),
                    nolDivider(),
                    alarmSwitchBox(
                      text: '추천 게시글 알림',
                      value: controller.pushAlarmRecommend,
                      switchFunc: controller.changePushAlarmRecommendFunc,
                    ),
                    nolDivider(),
                  ],
                  settingBox(text: '약관 및 정책', textColor: nolColorOrange, withArrow: false),
                  nolDivider(),
                  settingBox(text: '이용약관', onTap: controller.termsOfServiceLink),
                  nolDivider(),
                  settingBox(text: '개인정보 처리방침', onTap: controller.privacyPolicyLink),
                  nolDivider(),
                  SizedBox(height: 16 * sizeUnit),
                  nolDivider(),
                  settingBox(text: '인스타그램 보러가기', onTap: controller.instagramLink),
                  nolDivider(),
                  settingBox(text: '문의하기', onTap: controller.inquiryFunc),
                  nolDivider(),
                  if(!kIsWeb) ... [
                    settingBox(text: '버전 정보', subText: controller.version, onTap: controller.versionInfoFunc),
                    nolDivider(),
                  ],
                  SizedBox(height: 16 * sizeUnit),
                  nolDivider(),
                  settingBox(text: '로그아웃', onTap: controller.logoutButtonFunc),
                  nolDivider(),
                  if(!kIsWeb) ... [
                    settingBox(text: '탈퇴하기', textColor: nolColorGrey, onTap: controller.secessionFunc),
                    nolDivider(),
                  ],
                  SizedBox(height: 32 * sizeUnit),
                ],
              );
            }),
      ),
    );
  }

  Widget settingBox({required String text, Color textColor = nolColorBlack, bool withArrow = true, Function()? onTap, String subText = ''}) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 360 * sizeUnit,
        height: 56 * sizeUnit,
        child: Padding(
          padding: EdgeInsets.only(left: 24 * sizeUnit),
          child: Row(
            children: [
              Text(
                text,
                style: STextStyle.subTitle1().copyWith(
                  color: textColor,
                  fontWeight: withArrow ? FontWeight.w700 : FontWeight.w800,
                ),
              ),
              const Spacer(),
              subText.isEmpty
                  ? const SizedBox.shrink()
                  : Text(
                      subText,
                      style: STextStyle.subTitle1().copyWith(color: nolColorGrey),
                    ),
              SizedBox(width: 8 * sizeUnit),
              withArrow
                  ? SvgPicture.asset(
                      GlobalAssets.svgArrowRight,
                      width: 24 * sizeUnit,
                      height: 24 * sizeUnit,
                      color: nolColorGrey,
                    )
                  : const SizedBox.shrink(),
              SizedBox(width: 16 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }

  Widget alarmSwitchBox({required String text, required bool value, required Function(bool) switchFunc, bool haveFrontIcon = true}) {
    return SizedBox(
      width: 360 * sizeUnit,
      height: 56 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.only(left: 24 * sizeUnit, right: 12 * sizeUnit),
        child: Row(
          children: [
            haveFrontIcon
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        GlobalAssets.svgNieun,
                        width: 24 * sizeUnit,
                        height: 24 * sizeUnit,
                      ),
                      SizedBox(width: 4 * sizeUnit),
                    ],
                  )
                : const SizedBox.shrink(),
            Text(
              text,
              style: STextStyle.subTitle1().copyWith(color: nolColorBlack),
            ),
            const Spacer(),
            Switch(
              value: value,
              onChanged: switchFunc,
              activeColor: nolColorOrange,
              inactiveThumbColor: nolColorLightGrey,
              inactiveTrackColor: nolColorGrey,
            ),
          ],
        ),
      ),
    );
  }
}
