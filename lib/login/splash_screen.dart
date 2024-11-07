import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/my_page/controller/my_page_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../login/controllers/login_controller.dart';
import '../login/login_page.dart';
import '../wbti/controller/wbti_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  static const String route = '/splash';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final LoginController loginController = Get.find<LoginController>();
  late Animation<double> animation;
  late AnimationController animationController;

  @override
  initState() {
    super.initState();

    animationController = AnimationController(duration: const Duration(seconds: 1), vsync: this);
    animation = CurvedAnimation(parent: animationController, curve: Curves.easeIn);
    animationController.forward();

    // 자동 로그인
    Future.microtask(() async {
      await Future.delayed(const Duration(seconds: 2));
      final prefs = await SharedPreferences.getInstance();
      final bool autoLoginKey = prefs.getBool('autoLoginKey') ?? false;

      if (autoLoginKey && await loginController.autoLogin()) {
        loginController.loginFunc();
      } else {
        if(GlobalData.dynamicLink != null) {
          // 다이나믹링크로 들어온 경우 로그인 없이 둘러보기로 들어가기
          loginController.goToMainPage();
        } else {
          Get.off(() => LoginPage());
        }
      }
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showWebAppBar: false,
      child: Scaffold(
        body: Center(
          child: AnimatedLogo(animation: animation),
        ),
      ),
    );
  }
}

class AnimatedLogo extends AnimatedWidget {
  static final _opacityTween = Tween<double>(begin: 0.1, end: 1);

  const AnimatedLogo({Key? key, required Animation<double> animation}) : super(key: key, listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Opacity(
      opacity: _opacityTween.evaluate(animation),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            GlobalAssets.svgLogo,
            width: 100 * sizeUnit,
            height: 100 * sizeUnit,
          ),
          Padding(
            padding: EdgeInsets.only(top: 16 * sizeUnit),
            child: Text(
              '직장인들의 놀이터',
              style: STextStyle.headline2().copyWith(color: nolColorOrange),
            ),
          )
        ],
      ),
    );
  }
}
