import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/login/terms_page.dart';

import '../config/global_assets.dart';
import 'package:get/get.dart';
import '../config/global_function.dart';
import '../config/s_text_style.dart';
import '../data/user.dart';
import '../home/main_page.dart';
import '../repository/user_repository.dart';
import 'login_page.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({Key? key}) : super(key: key);
  static const String route = '/admin_login_page/0720';

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(child: Scaffold(appBar: customAppBar(context), body: SingleChildScrollView(child: buildTextFields())));
  }

  // 텍스트 필드 영역
  Widget buildTextFields() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 200 * sizeUnit),
          TextField(
            controller: emailController,
            textInputAction: TextInputAction.done,
            buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
            decoration: InputDecoration(
              errorText: !emailController.text.contains('@') ? '올바르지 않은 이메일 형식입니다.' : null,
              hintText: '이메일',
            ),
            onChanged: (value){
              setState(() {

              });
            },
          ),
          SizedBox(height: 8 * sizeUnit),
          TextField(
            controller: pwController,
            textInputAction: TextInputAction.done,
            buildCounter: (BuildContext context, {int? currentLength, int? maxLength, bool? isFocused}) => null,
            decoration: const InputDecoration(
                hintText: '비밀번호'
            ),
          ),
          SizedBox(height: 64 * sizeUnit),
          loginBox(
            src: GlobalAssets.svgLogo,
            text: "로그인",
            color: Colors.black,
            textColor: Colors.white,
            func: () async {
              // 로그인
              var res = await UserRepository.adminLogin(
                email: emailController.text,
                pw: pwController.text,
              );

              //1 : 탈퇴한 회원
              if (res == false || res['user']['LoginState'] == 0) {
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
              } else {
                Get.back();

                int loginState = res['user']['LoginState'];
                String title = '탈퇴한 계정';
                String description = '다른 계정으로 로그인 해주세요.';

                if(loginState != 1){
                  title = loginState == 2 ? '신고가 누적된 계정' : '관리자에 의해 차단된 계정';
                  List<BlockTime> list = (res['user']['BlockTimes'] as List).map((e) => BlockTime.fromJson(e)).toList();
                  description = '${list[0].endTime}까지\n${list[0].contents}';
                }

                showCustomDialog(
                  title: title,
                  description: description,
                  okFunc: () {
                    Get.back();
                    Get.offAll(() => LoginPage());
                  },
                  okText: '확인',
                );
              }
            }
          )
        ],
      ),
    );
  }

  Widget loginBox({
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
