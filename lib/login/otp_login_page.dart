import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:nolilteo/login/terms_page.dart';
import 'package:nolilteo/repository/user_repository.dart';
import 'package:timer_count_down/timer_controller.dart';
import 'package:timer_count_down/timer_count_down.dart';

import '../config/global_function.dart';
import '../home/main_page.dart';
import 'controllers/login_controller.dart';

class OtpLoginPage extends StatefulWidget {
  const OtpLoginPage({Key? key}) : super(key: key);

  @override
  State<OtpLoginPage> createState() => _OtpLoginPageState();
}

class _OtpLoginPageState extends State<OtpLoginPage> {

  var otp = '';
  final CountdownController _controller = CountdownController(autoStart: true);
  final LoginController loginController = Get.put(LoginController());

  @override
  void initState() {

    Future.microtask(() async {
      otp = await UserRepository.otpGenerate();
    }).then((value) {
      setState(() {

      });
    });

    super.initState();
  }

  String getTime(String time){
    int t = int.parse(time);
    int divide = (t/60).floor();

    String minute = '0${(divide)}';
    String second = (t - (divide * 60)).toString();

    if(second.length == 1) second = '0$second';

    return '$minute:$second';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 1060 * sizeUnit,
          child: Column(
            children: [
             Row(
               children: [
                 Text('WBTI OTP 안전 인증', style: STextStyle.body1().copyWith(fontWeight: FontWeight.w800),),
                 const Spacer(),
                 IconButton(onPressed: Get.back, icon: const Icon(Icons.close))
               ],
             ),
             SizedBox(height: 38 * sizeUnit,),
             Row(
               children: [
                 Text('현재 웹 로그인은 OTP 이용방식을 사용하고 있습니다.', style: STextStyle.body1().copyWith(fontWeight: FontWeight.w700),),
               ],
             ),
             Row(
               children: [
                 RichText(text: TextSpan(
                   children: [
                     TextSpan(text: 'WBTI 앱의 ', style: STextStyle.body1().copyWith(fontWeight: FontWeight.w700),),
                     TextSpan(text: '내 정보 > WBTI 웹 로그인 ', style: STextStyle.body1().copyWith(fontWeight: FontWeight.w800),),
                     TextSpan(text: '메뉴에서 아래 생성된 일회용 인증코드 8자리를 입력하시면 웹에서 로그인 됩니다.', style: STextStyle.body1().copyWith(fontWeight: FontWeight.w700),),
                   ]
                 )),
               ],
             ),
              SizedBox(height: 48 * sizeUnit,),
              Container(
                width: 1060 * sizeUnit,
                height: 134 * sizeUnit,
                color: nolColorOrange,
                child: Center(
                  child: Text(
                    otp == '' ? '' : '${otp[0]} - ${otp[1]}${otp[2]}${otp[3]} - ${otp[4]}${otp[5]}${otp[6]}${otp[7]}',
                    style: STextStyle.body1().copyWith(fontWeight: FontWeight.w800,fontSize: 36 * sizeUnit,color: Colors.white),),
                  ),
             ),
              SizedBox(height: 16 * sizeUnit,),
              Countdown(
                controller: _controller,
                seconds: 60 * 3,
                build: (BuildContext context, double time) => Text('남은 시간 ${getTime(time.toString())}',style: STextStyle.body2().copyWith(fontWeight: FontWeight.w700),),
                interval: const Duration(seconds: 1),
                onFinished: () async {
                  otp = await UserRepository.otpGenerate();
                  setState(() {
                    _controller.restart();
                  });
                },
              ),
              SizedBox(height: 24 * sizeUnit,),
              Container(
                width: 512 * sizeUnit,
                padding: EdgeInsets.only(left: 32 * sizeUnit, right: 32 * sizeUnit, bottom: 24 * sizeUnit),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24 * sizeUnit),
                  onTap: () async {
                    if(!kReleaseMode){
                      loginController.testLoginFunc();
                    }else{
                      var res = await UserRepository.otpLogin(otp: otp);

                      if(res != null && res != false){
                        Get.back();
                        //성공
                        GlobalFunction.globalLogin(
                          res,
                          nullCallback: () async {
                            await GlobalFunction.resetLoginPreference(); // 자동 로그인 끄기
                            if (Get.currentRoute == '/LoginPage') Get.back(); // 로딩 끝
                            return GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
                          },
                          falseCallback: () async {
                            await GlobalFunction.resetLoginPreference(); // 자동 로그인 끄기
                            if (Get.currentRoute == '/LoginPage') Get.back(); // 로딩 끝
                            return Get.to(() => TermsPage());
                          },
                          callback: () => Get.offAllNamed(MainPage.route), //메인페이지로 보냄
                        );
                      }else{
                        showCustomDialog(
                          title: '인증정보가 올바르지 않습니다\n확인 후 다시 시도해 주세요.',
                          okFunc: () {
                            Get.back();
                          },
                          okText: '네',
                        );
                      }
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48 * sizeUnit,
                    decoration: BoxDecoration(
                      color: nolColorOrange,
                      borderRadius: BorderRadius.circular(24 * sizeUnit),
                    ),
                    child: Center(
                      child: Text('완료', style: STextStyle.button()),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 32 * sizeUnit,),
              Text('현재 애플 회원가입은 앱을 통해서만 할 수 있습니다.',style: STextStyle.body2().copyWith(fontWeight: FontWeight.w700),),
              Text('WBTI 앱에서 더욱 편리하게 이용해 보세요.',style: STextStyle.body2().copyWith(fontWeight: FontWeight.w700),),
              SizedBox(height: 32 * sizeUnit,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8 * sizeUnit),
                      child: InkWell(
                        onTap: () {
                          GlobalFunction.launchWebUrl('https://apps.apple.com/kr/app/%EB%86%80%EC%9D%BC%ED%84%B0/id1635884478');
                        },
                        child: Container(
                          width: 176 * sizeUnit,
                          height: 48 * sizeUnit,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(24 * sizeUnit),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 8 * sizeUnit),
                              SvgPicture.asset(
                                'assets/images/login/logo_apple.svg',
                                color: Colors.black,
                                width: 48 * sizeUnit,
                                height: 48 * sizeUnit,
                              ),
                              SizedBox(width: 8 * sizeUnit),
                              Text(
                                'APP STORE',
                                style: STextStyle.body2().copyWith(color: Colors.black,fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  SizedBox(width: 24 * sizeUnit),
                    Padding(
                      padding: EdgeInsets.only(top: 8 * sizeUnit),
                      child: InkWell(
                        onTap: () {
                          GlobalFunction.launchWebUrl('https://play.google.com/store/apps/details?id=kr.sheeps.nolilteo');
                        },
                        child: Container(
                          width: 196 * sizeUnit,
                          height: 48 * sizeUnit,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            border: Border.all(color: Colors.transparent),
                            borderRadius: BorderRadius.circular(24 * sizeUnit),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 8 * sizeUnit),
                              SvgPicture.asset(
                                'assets/images/login/logo_google.svg',
                                width: 48 * sizeUnit,
                                height: 48 * sizeUnit,
                              ),
                              SizedBox(width: 8 * sizeUnit),
                              Text(
                                'GOOGLE PLAY',
                                style: STextStyle.body2().copyWith(color: Colors.black,fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              )
          ],
    ),
        ),
      ),
    );
  }
}
