import 'package:flutter/foundation.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/login/exitMember_page.dart';
import 'package:nolilteo/my_page/version_info_page.dart';
import 'package:nolilteo/repository/user_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/constants.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../network/firebaseNotification.dart';

class SettingController extends GetxController{
  static get to => Get.find<SettingController>();

  bool pushAlarmAll = FirebaseNotifications.isPlay && FirebaseNotifications.isWork && FirebaseNotifications.isGather && FirebaseNotifications.isSubscribe;
  bool pushAlarmNol = FirebaseNotifications.isPlay;
  bool pushAlarmIl = FirebaseNotifications.isWork;
  bool pushAlarmMeeting = FirebaseNotifications.isGather;
  bool pushAlarmReplying = FirebaseNotifications.isSubscribe;
  bool pushAlarmRecommend = FirebaseNotifications.isRecommend;

  String version = '';

  void fetchData() async {
    //버전정보 가져오기
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;

    //알람 정보 세팅
  }

  void changePushAlarmAllFunc(bool value){
    pushAlarmAll = value;
    FirebaseNotifications.isPlay = pushAlarmNol = pushAlarmAll;
    FirebaseNotifications.isWork = pushAlarmIl = pushAlarmAll;
    FirebaseNotifications.isGather = pushAlarmMeeting = pushAlarmAll;
    FirebaseNotifications.isSubscribe = pushAlarmReplying = pushAlarmAll;
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );

    update();
  }

  void changePushAlarmNolFunc(bool value){
    FirebaseNotifications.isPlay = pushAlarmNol = value;
    checkAllSwitch();
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );
    update();
  }

  void changePushAlarmIlFunc(bool value){
    FirebaseNotifications.isWork = pushAlarmIl = value;
    checkAllSwitch();
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );
    update();
  }

  void changePushAlarmMeetingFunc(bool value){
    FirebaseNotifications.isGather = pushAlarmMeeting = value;
    checkAllSwitch();
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );
    update();
  }

  void changePushAlarmReplyingFunc(bool value){
    FirebaseNotifications.isSubscribe = pushAlarmReplying = value;
    checkAllSwitch();
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );
    update();
  }

  void changePushAlarmRecommendFunc(bool value){
    FirebaseNotifications.isRecommend = pushAlarmRecommend = value;
    checkAllSwitch();
    UserRepository.editAlarm(
        id: GlobalData.loginUser.id,
        playAlarm: FirebaseNotifications.isPlay,
        workAlarm: FirebaseNotifications.isWork,
        gatherAlarm: FirebaseNotifications.isGather,
        subscribeAlarm: FirebaseNotifications.isSubscribe,
        recommendAlarm: FirebaseNotifications.isRecommend
    );
    update();
  }

  void checkAllSwitch(){
    if(pushAlarmIl && pushAlarmNol && pushAlarmMeeting && pushAlarmReplying && pushAlarmRecommend){
      pushAlarmAll = true;
    } else{
      pushAlarmAll = false;
    }
  }

  void termsOfServiceLink() async {
    if (kDebugMode) {
      print('이용약관');
    }
    GlobalFunction.launchWebUrl(urlTermsOfService);  //이용약관 웹페이지 연결
  }

  void privacyPolicyLink() async {
    if (kDebugMode) {
      print('개인정보 처리방침');
    }
    GlobalFunction.launchWebUrl(urlPrivacyPolicy);  //개인정보 처리방침 웹페이지 연결
  }

  void instagramLink() async {
    GlobalFunction.launchWebUrl(urlInstagram);  //개인정보 처리방침 웹페이지 연결
  }

  void versionInfoFunc() {
    Get.to(VersionInfoPage());
  }

  //탈퇴하기
  void secessionFunc(){
    if (kDebugMode) {
      print('탈퇴하기');
    }

    Get.to(() => ExitMemberPage());
  }

  //로그아웃 버튼
  void logoutButtonFunc(){
    showCustomDialog(
      title: '로그아웃 하시겠어요?',
      okFunc: () async {
        Get.back();
        await GlobalFunction.globalLogout();
      },
      isCancelButton: true,
      okText: '네',
      cancelText: '아니오',
    );
  }

  // 문의하기
  void inquiryFunc() async{
    const String receiveEmail = 'company@noteasy.kr';

    if(kIsWeb) {
      showCustomDialog(title: '문의 안내', description: "아래 메일로 연락주시면 친절하게 답변해드릴게요 :)\n$receiveEmail");
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final String userEmail = prefs.getString('email') ?? '';
    final int loginType = prefs.getInt('loginType') ?? 0; // 로그인 타입  0 : 카카오, 1 : apple, 2: 네이버, 3: 구글
    late final String loginTypeText;

    switch(loginType){
      case 0:
        loginTypeText = '카카오';
        break;
      case 1:
        loginTypeText = '애플';
        break;
      case 2:
        loginTypeText = '네이버';
        break;
      case 3:
        loginTypeText = '구글';
        break;
      default:
        loginTypeText = '카카오';
        break;
    }

    // 이메일, 로그인 유형
    final Email email = Email(
      body: '------------------------------------\n이메일: $userEmail\n로그인 타입: $loginTypeText\n------------------------------------\n',
      subject: 'WBTI 문의',
      recipients: [receiveEmail],
      cc: [],
      bcc: [],
      attachmentPaths: [],
      isHTML: false,
    );

    try {
      await FlutterEmailSender.send(email);
    } catch (error) {
      const String title = "문의 오류";
      const String message = "연결 가능한 메일 앱을 찾을 수 없습니다.\n아래로 연락주시면 친절하게 답변해드릴게요 :)\n$receiveEmail";
      showCustomDialog(title: title, description: message);
    }
  }
}