import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/user.dart';
import 'package:nolilteo/login/admin_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:nolilteo/home/main_page.dart';
import 'package:nolilteo/login/login_page.dart';
import 'package:nolilteo/login/nickname_page.dart';
import 'package:nolilteo/repository/user_repository.dart';
import '../../community/community_detail_page.dart';
import '../../community/community_reply_page.dart';
import '../../config/analytics.dart';
import '../../config/constants.dart';
import '../../config/global_assets.dart';
import '../../config/s_text_style.dart';
import '../../data/global_data.dart';
import '../../notification/notification_page.dart';
import '../kakao_login/kakao_login.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../wbti/wbti_test_page.dart';
import '../terms_page.dart';

class LoginController extends GetxController {
  static get to => Get.find<LoginController>();

  RxString email = ''.obs; // 이메일
  RxInt loginType = 0.obs; // 로그인 타입  0 : 카카오, 1 : apple, 2: 네이버, 3: 구글

  bool allAgree = false;
  bool termsOfUseAgree = false;
  bool privacyAgree = false;
  bool marketingAgree = false;
  bool activeNextForTerms = false;

  int nickPageIndex = 0;
  final Duration pageDuration = const Duration(milliseconds: 500);
  final Curve pageCurve = Curves.easeInOut;

  RxString nickname = ''.obs;
  String? nicknameErrorText;
  bool nickChecking = false;

  String job = '';
  String? jobErrorText;

  String wbti = '';

  bool beBack = false;

  @override
  onInit() {
    super.onInit();

    nicknameDuplicateCheck(); // 닉네임 중복 체크
  }

  Future<void> loginFunc() async {
    if (Get.currentRoute == '/LoginPage') GlobalFunction.loadingDialog(); // 로딩 시작

    // 로그인
    var res = await UserRepository.login(
      email: email.value,
      loginType: loginType.value,
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
          return Get.to(() => const TermsPage());
        },
        callback: () {
          Get.offAllNamed(MainPage.route);
          if(GlobalData.payload == ''){
            // 다이나믹 링크 처리
            if (GlobalData.dynamicLink != null) {
              Get.toNamed(GlobalData.dynamicLink!);
              GlobalData.dynamicLink = null;
            }
          } else {
            List<String> strList = GlobalData.payload.split('/');
            GlobalData.payload = '';

            switch (strList[0]) {
              case "NOTIFICATION":
                {
                  Get.to(() => const TotalNotificationPage());
                }
                break;
              case "COMMUNITY":
                {
                  Get.toNamed('${CommunityDetailPage.route}/${strList[1]}')!.then((value) => GlobalFunction.syncPost());
                }
                break;
              case "COMMUNITY_REPLY_REPLY":
                {
                  Get.toNamed('${CommunityDetailPage.meetingRoute}/${strList[1]}')!.then((value) => GlobalFunction.syncPost());
                }
                break;
              default:
                {
                  Get.to(() => CommunityReplyPage(replyID: int.parse(strList[2])));
                }
                break;
            }
          }
        }, //메인페이지로 보냄
      );
    } else {
      Get.back();

      int loginState = res['user']['LoginState'];
      String title = '탈퇴한 계정';
      String description = '다른 계정으로 로그인 해주세요.';

      if (loginState != 1) {
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

  void goWbtiTestPage() {
    Get.toNamed(WbtiTestPage.route);
  }

  //테스트 로그인용
  void testLoginFunc() async {
    if (kDebugMode) print('테스트 로그인');
    email.value = 'goodmirow@gmail.com';
    if (kDebugMode) print(email.value);
    loginType(0);
    loginFunc();
  }

  void kakaoLoginButtonFunc() async {
    if (await kakaoLoginFunc()) {
      loginFunc();
    }
  }

  Future<bool> kakaoLoginFunc() async {
    email.value = await kakaoLogin();
    if (email.value.isEmpty) {
      return false;
    }
    //email.value = 'goodmirow@gmail.com';
    loginType(0);
    return true;
  }

  Future<void> appleLogin() async {
    if (kDebugMode) print('애플 로그인');

    if (kIsWeb) {
      // final credential = await SignInWithApple.getAppleIDCredential(
      //   scopes: [
      //     AppleIDAuthorizationScopes.email,
      //     AppleIDAuthorizationScopes.fullName,
      //   ],
      //   webAuthenticationOptions: WebAuthenticationOptions(
      //     clientId: 'kr.sheeps.nolilteo.NolilteoLogin',
      //     redirectUri: Uri.parse('https://fog-keen-arch.glitch.me/callbacks/sign_in_with_apple',)
      //   ),
      // );
      //
      // final signInWithAppleEndpoint = Uri(
      //   scheme: 'https',
      //   host: 'fog-keen-arch.glitch.me',
      //   path: '/sign_in_with_apple',
      //   queryParameters: <String, String>{
      //     'code': credential.authorizationCode,
      //     if (credential.givenName != null)
      //       'firstName': credential.givenName!,
      //     if (credential.familyName != null)
      //       'lastName': credential.familyName!,
      //     'useBundleId':
      //     !kIsWeb && (IO.Platform.isIOS || IO.Platform.isMacOS)
      //         ? 'true'
      //         : 'false',
      //     if (credential.state != null) 'state': credential.state!,
      //   },
      // );
      //
      // if (kDebugMode) {
      //   print(signInWithAppleEndpoint);
      // }
    } else {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = firebase.OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      firebase.UserCredential userCredential = await firebase.FirebaseAuth.instance.signInWithCredential(oauthCredential);
      email.value = userCredential.user!.email!;

      loginType(1);
    }
  }

  void naverLoginButtonFunc() async {
    if (await naverLoginFunc()) {
      loginFunc();
    }
  }

  Future<bool> naverLoginFunc() async {
    if (kDebugMode) {
      print('네이버 로그인');
      GlobalFunction.showToast(msg: '신규가입 테스트입니다.');
      //신규가입인척 테스트. 네이버 로그인 구현시 삭제
      int tmp = (Random().nextDouble() * 10000).toInt();
      email.value = 'test$tmp@naver.com';
      loginType(2);
      return true;
    }
    showCustomDialog(
      title: '서비스 준비 중',
      description: '네이버 로그인 서비스는 준비 중이에요!\n다른 로그인을 사용해주세요.',
    );
    return false;
  }

  //자동 로그인
  Future<bool> autoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    loginType(prefs.getInt('loginType') ?? 0);
    email(prefs.getString('email') ?? '');
    if (email.value.isEmpty) {
      //자동로그인 실패
      return false;
    }
    return true;
  }

  //비로그인 둘러보기
  void goToMainPage() async {
    final prefs = await SharedPreferences.getInstance();
    final bool authAgree = prefs.getBool('auth_agree') ?? false;
    if (!authAgree) {
      bool isAgree = false;
      await showCustomWidgetDialog(
        title: '이용약관 동의',
        descriptionWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 20 * sizeUnit),
            Text(
              'WBTI 서비스를 사용하기 위해\n이용약관에 동의해주세요!',
              style: STextStyle.body4().copyWith(height: 18 / 12),
            ),
            SizedBox(height: 12 * sizeUnit),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  GlobalFunction.launchWebUrl(urlTermsOfService); //이용약관 웹페이지 연결
                },
                child: SizedBox(
                  height: 40 * sizeUnit,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '이용약관 보기',
                        style: STextStyle.subTitle4(),
                      ),
                      SizedBox(width: 4 * sizeUnit),
                      SvgPicture.asset(
                        GlobalAssets.svgArrowRight,
                        width: 20 * sizeUnit,
                        height: 20 * sizeUnit,
                        color: nolColorGrey,
                      ),
                      // SizedBox(width: 16 * sizeUnit),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        okText: '동의',
        okFunc: () {
          isAgree = true;
          prefs.setBool('auth_agree', true);
          Get.back();
        },
        isCancelButton: true,
      );
      //동의 안했으면 이후 과정x
      if (!isAgree) {
        return;
      }
    }

    await GlobalFunction.setCustomWbtiList(); // 커스텀 wbti 리스트 세팅
    if (beBack) {
      Get.back();
    } else {
      Get.offNamed(MainPage.route); // 메인 페이지로 이동

      // 다이나믹 링크 처리
      if (GlobalData.dynamicLink != null) {
        Get.toNamed(GlobalData.dynamicLink!);
        GlobalData.dynamicLink = null;
      }
    }
  }

  void goToAdminPage() async {
    Get.to(() => const AdminLoginPage());
  }

  //전체 동의 버튼 클릭시
  void termAllCheckBoxFunc() {
    allAgree = !allAgree;
    termsOfUseAgree = allAgree;
    privacyAgree = allAgree;
    marketingAgree = allAgree;

    // 다음 버튼 활성화 여부
    if (termsOfUseAgree && privacyAgree) {
      activeNextForTerms = true;
    } else {
      activeNextForTerms = false;
    }

    update(['terms_page']);
  }

  //개별 동의 버튼 클릭
  void termCheckBoxFunc(int variety) {
    switch (variety) {
      case 1:
        termsOfUseAgree = !termsOfUseAgree;
        break;
      case 2:
        privacyAgree = !privacyAgree;
        break;
      case 3:
        marketingAgree = !marketingAgree;
        break;
    }

    // 전체 버튼 활성화 여부
    if (termsOfUseAgree && privacyAgree && marketingAgree) {
      allAgree = true;
    } else {
      allAgree = false;
    }

    // 다음 버튼 활성화 여부
    if (termsOfUseAgree && privacyAgree) {
      activeNextForTerms = true;
    } else {
      activeNextForTerms = false;
    }

    update(['terms_page']);
  }

  void goToNickNamePage() {
    Get.to(() => const NicknamePage());
  }

  void nickPageInit() {
    nickname('');
    job = '';
    nickPageIndex = 0;
  }

  void nickPageBackFunc(PageController pageController) {
    switch (nickPageIndex) {
      case 0:
        Get.back();
        break;
      case 1:
        pageController.previousPage(duration: pageDuration, curve: pageCurve);
        break;
    }
    update(['nickname_page']);
  }

  void changeNicknameFunc(String val) async {
    nickname(val);

    //닉네임 규칙 체크
    nicknameErrorText = GlobalFunction.validNickNameErrorText(nickname.value);

    update(['nickname_page']);
  }

  // 닉네임 중복 체크
  void nicknameDuplicateCheck() async {
    debounce(
      nickname,
      time: const Duration(milliseconds: 500),
      (callback) async {
        if (nicknameErrorText == null && nickname.value.length >= 2) {
          nickChecking = true;

          var result = await UserRepository.checkNickName(nickName: nickname.value);
          if (result == false) nicknameErrorText = '이미 존재하는 닉네임이에요!';

          nickChecking = false;

          update(['nickname_page']);
        }
      },
    );
  }

  void nickPageChanged(int index) {
    nickPageIndex = index;
  }

  bool isCanNextForNick() {
    switch (nickPageIndex) {
      case 0:
        if (nicknameErrorText == null && nickname.isNotEmpty && !nickChecking) {
          return true;
        } else {
          return false;
        }
      case 1:
        if (job.isNotEmpty && jobErrorText == null) {
          return true;
        } else {
          return false;
        }
    }
    return true;
  }

  void nickPageNextFunc(PageController pageController) {
    if (nickPageIndex == 0) {
      pageController.nextPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);

      update(['nickname_page']);
    } else if (nickPageIndex == 1) {
      createAccountDone();
    }
  }

  void changeJobFunc(String val) {
    job = val;
    //직업명 규칙 체크
    jobErrorText = GlobalFunction.validJobErrorText(job);

    update(['nickname_page']);
  }

  void createAccountDone() {
    if (wbti.isNotEmpty) {
      //wbti결과를 이미 가지고 있으면.

      //결과 서버 전송. 로그인 유저 정보에 담음.
      Future.microtask(() async {
        var res = await UserRepository.insert(
          email: email.value,
          nickName: nickname.value,
          wbtiType: wbti,
          job: job,
          loginType: loginType.value,
          marketingAgree: marketingAgree,
        );

        NolAnalytics.logSignUp(loginType.value); // 애널리틱스 회원가입

        GlobalFunction.globalLogin(
          res,
          nullCallback: () => GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.'),
          falseCallback: () => GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.'),
          callback: (){
            GlobalData.pageRouteList.clear();
            Get.offAllNamed(MainPage.route);
          }, //메인페이지로 보냄
          isNewUser: true,
        );
      }).then((value) => {reset()});
    } else {
      //검사 결과가 없으면
      Get.to(() => const WbtiTestPage());
    }
  }

  void reset() {
    allAgree = false;
    termsOfUseAgree = false;
    privacyAgree = false;
    marketingAgree = false;
    activeNextForTerms = false;

    nickname('');
    nicknameErrorText = null;
    job = '';
    jobErrorText = null;
    wbti = '';
  }
}
