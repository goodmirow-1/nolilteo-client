import 'package:firebase_analytics/firebase_analytics.dart';

class NolAnalytics {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  // 앱 시작
  static Future<void> logAppOpen() async {
    await analytics.logAppOpen();
  }

  // 회원가입
  static Future<void> logSignUp(int type) async {
    String loginType = 'kakao';

    switch(type) {
      case 0:
        loginType = 'kakao';
        break;
      case 1:
        loginType = 'apple';
        break;
      case 2:
        loginType = 'naver';
        break;
    }

    await analytics.logSignUp(signUpMethod: loginType);
  }

  // 스크린 체크
  static Future<void> logSetScreen(String screenName) async {
    await analytics.setCurrentScreen(screenName: screenName);
  }

  // 그 외 로그 이벤트
  static Future<void> logEvent({required String name, Map<String, dynamic>? parameters}) async {
    await analytics.logEvent(name: name, parameters: parameters);
  }
}