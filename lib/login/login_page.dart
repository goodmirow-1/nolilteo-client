import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../login/controllers/login_controller.dart';
import 'otp_login_page.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key, this.noTest = false, this.beBack = false}) : super(key: key);

  final bool noTest;
  final bool beBack;

  final LoginController controller = Get.put(LoginController());

  static const String svgLogoKakao = 'assets/images/login/logo_kakao.svg';
  static const String svgLogoApple = 'assets/images/login/logo_apple.svg';
  static const String svgLogoNaver = 'assets/images/login/logo_naver.svg';
  static const String svgLogoGoogle = 'assets/images/login/logo_google.svg';

  @override
  Widget build(BuildContext context) {
    controller.beBack = beBack;
    return BaseWidget(
      showWebAppBar: false,
      onWillPop: beBack ? null : () => GlobalFunction.isEnd(),
      child: Scaffold(
        body: GetBuilder<LoginController>(
            id: 'login_page',
            builder: (_) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if(!noTest) ... [
                    Row(children: [SizedBox(height: 56 * sizeUnit)]),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(onLongPress: controller.goToAdminPage, child: Text('직장인들을 위한 당 충전 공간', style: STextStyle.body1().copyWith(color: nolColorOrange))),
                          Row(children: [SizedBox(height: 8 * sizeUnit)]),
                          Text('WBTI에서\n시작해보세요.', style: STextStyle.headline1().copyWith(color: nolColorOrange, height: 40/32)),
                        ],
                      ),
                    ),
                    SizedBox(height: 16 * sizeUnit),
                    wbtiBox(),
                    const Spacer(),
                  ] else ... [
                    SvgPicture.asset(
                      GlobalAssets.svgLogo,
                      width: 100 * sizeUnit,
                      height: 100 * sizeUnit,
                    ),
                    Row(children: [SizedBox(height: 40 * sizeUnit)]),
                  ],
                  if(!kIsWeb) ... [
                    if(!kReleaseMode) ... [
                      TextButton(
                        onPressed: controller.testLoginFunc,
                        child: const Text('Test Login'),
                      ),
                    ],
                    socialLoginBox(
                      src: svgLogoKakao,
                      text: '카카오로 로그인',
                      color: const Color(0xFFFFE812),
                      func: controller.kakaoLoginButtonFunc,
                    ),
                    if (kIsWeb || Platform.isIOS) ...[
                      socialLoginBox(
                        src: svgLogoApple,
                        text: 'Apple로 로그인',
                        color: Colors.black,
                        textColor: Colors.white,
                        func: () async {
                          if(kIsWeb){
                            Get.dialog(
                                const OtpLoginPage()
                            );
                          }else{
                            await controller.appleLogin();
                            controller.loginFunc();
                          }
                        },
                      ),
                    ],
                    if(kDebugMode)...[
                      socialLoginBox(
                        src: svgLogoNaver,
                        text: '네이버로 로그인',
                        color: const Color(0xFF06BE34),
                        textColor: Colors.white,
                        func: controller.naverLoginButtonFunc,
                      ),
                    ],
                  ],
                  SizedBox(height: 24 * sizeUnit),
                  TextButton(
                      onPressed: controller.goToMainPage,
                      child: Text(
                        '로그인 없이 둘러보기',
                        style: STextStyle.subTitle3().copyWith(color: nolColorGrey, decoration: TextDecoration.underline),
                      )),
                  SizedBox(height: 24 * sizeUnit),
                ],
              );
            }),
      ),
    );
  }

  Widget wbtiBox() {
    return InkWell(
      onTap: controller.goWbtiTestPage,
      child: Container(
        width: 328 * sizeUnit,
        height: 70 * sizeUnit,
        decoration: BoxDecoration(
          color: nolColorOrange,
          borderRadius: BorderRadius.circular(14 * sizeUnit),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('직장에서 나는 어떤 스타일일까?', style: STextStyle.body4().copyWith(color: Colors.white)),
            SizedBox(height: 6*sizeUnit),
            Text('WBTI 테스트 하러가기 >', style: STextStyle.headline3().copyWith(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget socialLoginBox({
    required String src,
    required String text,
    Color color = Colors.white,
    Color borderColor = Colors.transparent,
    Color textColor = Colors.black,
    required Function() func,
  }) {
    return Padding(
      padding: EdgeInsets.only(top: 8 * sizeUnit),
      child: InkWell(
        onTap: func,
        child: Container(
          width: 296 * sizeUnit,
          height: 48 * sizeUnit,
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(24 * sizeUnit),
          ),
          child: Row(
            children: [
              SizedBox(width: 8 * sizeUnit),
              SvgPicture.asset(
                src,
                width: 48 * sizeUnit,
                height: 48 * sizeUnit,
              ),
              const Spacer(),
              Text(
                text,
                style: STextStyle.body2().copyWith(color: textColor),
              ),
              const Spacer(),
              SizedBox(width: 48 * sizeUnit),
              SizedBox(width: 8 * sizeUnit), //중앙정렬 간격 맞추느라
            ],
          ),
        ),
      ),
    );
  }
}
