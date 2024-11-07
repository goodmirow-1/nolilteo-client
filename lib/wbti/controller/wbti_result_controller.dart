
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/login/login_page.dart';
import 'package:nolilteo/login/nickname_page.dart';
import 'package:nolilteo/my_page/controller/edit_profile_controller.dart';
import 'package:nolilteo/repository/user_repository.dart';
import 'package:nolilteo/wbti/wbti_result_page.dart';
import '../../config/analytics.dart';
import '../../login/controllers/login_controller.dart';
import '../../my_page/controller/my_page_controller.dart';
import '../../share/share_link.dart';
import '../../config/constants.dart';
import '../../data/global_data.dart';
import '../../home/main_page.dart';
import '../model/wbti_type.dart';
import '../wbti_test_page.dart';

class WbtiResultController extends GetxController {
  static get to => Get.find<WbtiResultController>();

  String job = '';
  late String type;
  late WbtiType wbtiType;
  late WbtiType matchType;

  String buttonText = '시작하기';

  int resultType = resultTypeTest;
  bool isEdit = false;
  bool isMyWbti = false;
  bool isFirstLogin = false;

  static const int resultTypeTest = 1; //로그인 없이 테스트만 한 경우
  static const int resultTypeLogin = 2; //로그인(가입)하고 테스트 한 경우
  static const int resultTypeEdit = 3; //내 정보 수정에서 테스트 한 경우
  static const int resultTypeLink = 4; //결과페이지에 링크로 접근한 경우
  static const int resultTypeMyWbti = 5; //내 WBTI 페이지인 경우

  // 데이터 세팅
  Future<void> fetchData() async {
    type = Get.parameters['type'] ?? 'estj';

    Map arguments = Get.arguments ?? {};
    isMyWbti = arguments['isMyWbti'] ?? false;

    wbtiType = WbtiType.getType(type);
    matchType = WbtiType.getType(wbtiType.perfectMatchType);

    if(isMyWbti){
      resultType = resultTypeMyWbti;
    } else if(GlobalData.pageRouteList.contains(NicknamePage.route)){
      isFirstLogin = true;
      resultType = resultTypeLogin;
    } else if(GlobalData.loginUser.id != nullInt){
      resultType = resultTypeEdit;
      isEdit = true;
    } else if(GlobalData.pageRouteList.contains(WbtiTestPage.route)){
      resultType = resultTypeTest;
    }else{
      resultType = resultTypeLink;
    }

    switch (resultType) {
      case resultTypeTest:
        if(kIsWeb){
          buttonText = '테스트 다시하기';
          resultType = resultTypeLink;
        }else{
          buttonText = '로그인하기';
        }
        break;
      case resultTypeLogin:
        buttonText = '시작하기';
        break;
      case resultTypeEdit:
        buttonText = '수정하기';
        break;
      case resultTypeLink:
        buttonText = '테스트 다시하기';
        break;
    }
  }

  void replayButtonFunc() {
    if(resultType == resultTypeMyWbti){
      Get.to(()=>const WbtiTestPage());
    } else{
      GlobalFunction.getBackTo(WbtiTestPage.route);
    }
  }

  void buttonFunc() {
    final LoginController controller = Get.find<LoginController>();
    switch (resultType) {
      case resultTypeTest:
        controller.wbti = type;
        controller.job = job;

        Get.to(LoginPage(noTest: true)); //로그인 화면 띄움.
        break;
      case resultTypeLogin:
        //결과 서버 전송. 로그인 유저 정보에 담음.
        Future.microtask(() async {
          var res = await UserRepository.insert(
            email: controller.email.value,
            nickName: controller.nickname.value,
            wbtiType: type,
            job: controller.job,
            loginType: controller.loginType.value,
            marketingAgree: controller.marketingAgree,
          );

          NolAnalytics.logSignUp(controller.loginType.value); // 애널리틱스 회원가입

          GlobalFunction.globalLogin(
            res,
            nullCallback: () => GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.'),
            falseCallback: () => GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.'),
            callback: (){
              GlobalData.pageRouteList.clear();
              Get.offAllNamed(MainPage.route);
            }, //메인페이지로 보냄
            isNewUser: true
          );
        });
        break;
      case resultTypeEdit:
        //결과 서버 전송. 로그인 유저 정보에 담음.
        GlobalData.loginUser.wbti = type;
        Future.microtask(() async {
          var res = await UserRepository.edit(
              id: GlobalData.loginUser.id,
              nickName: GlobalData.loginUser.nickName,
              wbtiType: GlobalData.loginUser.wbti,
              job: GlobalData.loginUser.job,
              gender: GlobalData.loginUser.gender == null ? null : GlobalData.loginUser.gender!,
              birthday: GlobalData.loginUser.birthday == null ? null : GlobalData.loginUser.birthday!);

          MyPageController myPageController = Get.put(MyPageController());
          myPageController.fetchData();

          EditProfileController editProfileController = Get.put(EditProfileController());
          editProfileController.initWbti();
          editProfileController.initJob();
          GlobalFunction.showToast(msg: 'WBTI 수정이 완료되었습니다.');
        });

        GlobalFunction.getBackTo('all');
        break;
      case resultTypeLink:
        Get.offAllNamed(WbtiTestPage.route);//모든 페이지 종료. 테스트 화면으로.
        break;
    }
  }

  void shareFunc() {
    //공유하기
    shareLink(routeInfo: '${WbtiResultPage.route}/$type', contents: 'WBTI 테스트 결과');
  }
}
