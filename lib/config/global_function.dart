import 'dart:async';
import 'dart:convert';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nolilteo/config/analytics.dart';
import 'package:nolilteo/config/global_page/controllers/search_controller.dart' as MySearchController;
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/login/controllers/login_controller.dart';
import 'package:nolilteo/my_page/controller/my_post_controller.dart';
import 'package:nolilteo/wbti/controller/wbti_controller.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../community/controllers/community_controller.dart';
import '../../data/global_data.dart';
import '../../data/user.dart' as model;

import '../community/controllers/board_controller.dart';
import '../community/models/post.dart';
import '../data/user.dart';
import '../home/main_page.dart';
import '../login/login_page.dart';
import '../login/otp_login_page.dart';
import '../network/ApiProvider.dart';
import '../network/firebaseNotification.dart';
import '../notification/controller/notification_controller.dart';
import '../repository/user_repository.dart';
import 'constants.dart';
import 'global_widgets/global_widget.dart';

class GlobalFunction {
  // 로그인 데이터 세팅
  static Future<void> setLoginData() async {
    if (GlobalData.loginUser.id != nullInt) return; // 이미 로그인한 상태면 리턴

    final prefs = await SharedPreferences.getInstance();
    final bool autoLoginKey = prefs.getBool('autoLoginKey') ?? false;
    final LoginController loginController = Get.find<LoginController>();

    if (autoLoginKey && await loginController.autoLogin()) {
      // 로그인
      var res = await UserRepository.login(
        email: loginController.email.value,
        loginType: loginController.loginType.value,
      );

      await GlobalFunction.globalLogin(res);
    }
  }

  // 포커스 해제 함수
  static void unFocus(BuildContext context) {
    FocusManager.instance.primaryFocus!.unfocus();
  }

  //닉네임 에러 규칙
  static String? validNickNameErrorText(String name) {
    if (name.isEmpty) return null;

    int utf8Length = utf8.encode(name).length;
    if (name.length < 2) {
      return "너무 짧아요. 2자 이상 작성해주세요.";
    }
    if (name.length > 12 || utf8Length > 24) {
      return "한글 8자 또는 영문 12자 이하로 작성해 주세요.";
    }

    bool pass = true;

    RegExp regExp = RegExp(r'[ㄱ-ㅎ|가-힣|a-z|A-Z|0-9]'); //한글, 영문, 숫자만 입력 가능

    List charList = name.split('');

    for (int i = 0; i < charList.length; i++) {
      if (regExp.hasMatch(charList[i])) {
      } else {
        pass = false;
        break;
      }
    }

    if (pass) {
      return null;
    } else {
      return "한글, 영문, 숫자만 사용해주세요.";
    }
  }

  //직업명 제한 규칙
  static String? validJobErrorText(String text) {
    if (text.isEmpty) return null;

    int utf8Length = utf8.encode(text).length;
    if (text.length < 2) {
      return "2자 이상 작성해주세요.";
    }
    if (text.length > 12 || utf8Length > 24) {
      return "한글 8자 또는 영문 12자 이하로 작성해 주세요.";
    }

    bool pass = true;

    RegExp regExp = RegExp(r'[가-힣|a-z|A-Z|\s]'); //한글, 영문, 띄어쓰기만 입력 가능

    List charList = text.split('');

    bool spaceFirstCheck = true;
    for (int i = 0; i < charList.length; i++) {
      if (regExp.hasMatch(charList[i])) {
      } else {
        pass = false;
        break;
      }
      if (charList[i] == ' ') {
        if (spaceFirstCheck) {
          //첫번째 공백을 제외한 공백이 있을 경우 알림
          spaceFirstCheck = false;
        } else {
          pass = false;
          break;
        }
      }
    }

    if (pass) {
      return null;
    } else {
      return "한글, 영문, 한개의 공백만 사용해주세요.";
    }
  }

  // 글로벌 유저 리스트에서 id로 유저 가져오기
  static model.User getUserByUserID(int id) {
    model.User user = GlobalData.tempUser;

    if (id == GlobalData.loginUser.id) return GlobalData.loginUser; // 로그인 유저인 경우

    for (int i = 0; i < GlobalData.userList.length; i++) {
      if (id == GlobalData.userList[i].id) {
        user = GlobalData.userList[i];
        break;
      }
    }

    return user;
  }

  // 글로벌 유저 리스트에서 id로 유저 가져오기 없으면 서버에서
  static Future<model.User> getFutureUserByID(int id) async {
    model.User user = GlobalData.tempUser;

    if (id == GlobalData.loginUser.id) return GlobalData.loginUser; // 로그인 유저인 경우

    for (var element in GlobalData.userList) {
      if (id == element.id) user = element; // 유저 리스트에 있으면 리턴
    }

    if (user.id == nullInt) {
      var res = await ApiProvider().post('/User/Select', jsonEncode({'userID': id}));

      if (res != null) {
        user = model.User.fromJson(res);
        GlobalData.userList.add(user);
      } else {
        throw Exception();
      }
    }

    return Future.value(user);
  }

  // 게시글 동기화
  static void syncPost() {
    if (GlobalData.changedPost == null) return; // 바뀐게 없다면 리턴

    // 동기화 함수
    void sync(List<Post> postList) {
      for (int i = 0; i < postList.length; i++) {
        if (postList[i].id == GlobalData.changedPost!.id) {
          postList[i] = GlobalData.changedPost!;
          break;
        }
      }
    }

    // 커뮤니티 컨트롤러
    if (Get.isRegistered<CommunityController>()) {
      final CommunityController communityController = Get.find<CommunityController>();
      sync(communityController.postList);
      sync(communityController.popularPostList);
      sync(communityController.hotList);
      communityController.update();
    }
    // wbti 컨트롤러
    if (Get.isRegistered<WbtiController>()) {
      final WbtiController wbtiController = Get.find<WbtiController>();
      sync(wbtiController.postList);
      sync(wbtiController.popularPostList);
      sync(wbtiController.hotList);
      wbtiController.update();
    }
    // // 미팅 컨트롤러
    // if (Get.isRegistered<MeetingController>()) {
    //   final MeetingController meetingController = Get.find<MeetingController>();
    //   sync(meetingController.postList);
    //   meetingController.update();
    // }
    // 마이 포스트 컨트롤러
    if (Get.isRegistered<MyPostController>(tag: (GlobalData.myPostPageCount - 1).toString())) {
      final MyPostController myPostController = Get.find<MyPostController>(tag: (GlobalData.myPostPageCount - 1).toString());
      sync(myPostController.postList);
      myPostController.update();
    }
    // 보드 컨트롤러
    if (Get.isRegistered<BoardController>(tag: (GlobalData.boardPageCount - 1).toString())) {
      final BoardController boardController = Get.find<BoardController>(tag: (GlobalData.boardPageCount - 1).toString());
      sync(boardController.postList);
      boardController.update();
    }
    // 검색 컨트롤러
    if (Get.isRegistered<MySearchController.SearchController>()) {
      final MySearchController.SearchController searchController = Get.find<MySearchController.SearchController>();
      if (searchController.titleSearchList != null) sync(searchController.titleSearchList!);
      searchController.update();
    }

    GlobalData.changedPost = null;
  }

  // 삭제된 게시글 동기화
  static void syncDeletedPost(int postID) {
    // 커뮤니티 컨트롤러
    if (Get.isRegistered<CommunityController>()) {
      final CommunityController communityController = Get.find<CommunityController>();
      communityController.postList.removeWhere((element) => element.id == postID);
      communityController.popularPostList.removeWhere((element) => element.id == postID);
      communityController.hotList.removeWhere((element) => element.id == postID);
      communityController.update();
    }
    // wbti 컨트롤러
    if (Get.isRegistered<WbtiController>()) {
      final WbtiController wbtiController = Get.find<WbtiController>();
      wbtiController.postList.removeWhere((element) => element.id == postID);
      wbtiController.popularPostList.removeWhere((element) => element.id == postID);
      wbtiController.hotList.removeWhere((element) => element.id == postID);
      wbtiController.update();
    }
    // // 미팅 컨트롤러
    // if (Get.isRegistered<MeetingController>()) {
    //   final MeetingController meetingController = Get.find<MeetingController>();
    //   meetingController.postList.removeWhere((element) => element.id == postID);
    //   meetingController.update();
    // }
    // 보드 컨트롤러
    if (Get.isRegistered<BoardController>()) {
      final BoardController boardController = Get.find<BoardController>();
      boardController.postList.removeWhere((element) => element.id == postID);
      boardController.update();
    }
    // 검색 컨트롤러
    if (Get.isRegistered<MySearchController.SearchController>()) {
      final MySearchController.SearchController searchController = Get.find<MySearchController.SearchController>();
      if (searchController.titleSearchList != null) searchController.titleSearchList!.removeWhere((element) => element.id == postID);
      searchController.update();
    }
  }

  static String replaceDate(String date) {
    if (date == "") return "";

    DateTime dateTime = DateTime.parse(date);
    dateTime = dateTime.add(const Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

    String replaceStr = dateTime.toString();
    return replaceStr.replaceAll('T', ' ').replaceAll('-', '').replaceAll(':', '').replaceAll(' ', '');
  }

  static String replaceDateToDateTime(String date) {
    DateTime dateTime = DateTime.parse(date);
    //dateTime = dateTime.add(const Duration(hours: 9)); //zone 시간 더함(아마존 서버로 접근할 시 -필요)

    String months = dateTime.month < 10 ? '0${dateTime.month}' : dateTime.month.toString();
    String days = dateTime.day < 10 ? '0${dateTime.day}' : dateTime.day.toString();

    String hours = dateTime.hour < 10 ? '0${dateTime.hour}' : dateTime.hour.toString();
    String minutes = dateTime.minute < 10 ? '0${dateTime.minute}' : dateTime.minute.toString();
    String seconds = dateTime.second < 10 ? '0${dateTime.second}' : dateTime.second.toString();

    return '${dateTime.year}-$months-$days $hours:$minutes:$seconds';
  }

  // 시간 얼마나 지났는지 체크해서 string 반환
  static String timeCheck(String tmp) {
    int year = int.parse(tmp[0] + tmp[1] + tmp[2] + tmp[3]);
    int month = int.parse(tmp[4] + tmp[5]);
    int day = int.parse(tmp[6] + tmp[7]);
    int hour = int.parse(tmp[8] + tmp[9]);
    int minute = int.parse(tmp[10] + tmp[11]);
    int second = int.parse(tmp[12] + tmp[13]);

    final date1 = DateTime(year, month, day, hour, minute, second);
    var date2 = DateTime.now();
    final differenceDays = date2.difference(date1).inDays;
    final differenceHours = date2.difference(date1).inHours;
    final differenceMinutes = date2.difference(date1).inMinutes;
    final differenceSeconds = date2.difference(date1).inSeconds;

    if (differenceDays > 13) {
      return "$month월 $day일";
    } else if (differenceDays > 6) {
      return "일주일전";
    } else {
      if (differenceDays > 1) {
        return "$differenceDays일전";
      } else if (differenceDays == 1) {
        return "하루전";
      } else {
        if (differenceHours >= 1) {
          return "$differenceHours시간전";
        } else {
          if (differenceMinutes >= 1) {
            return "$differenceMinutes분전";
          } else {
            if (differenceSeconds >= 0) {
              return "$differenceSeconds초전";
            } else {
              return "방금";
            }
          }
        }
      }
    }
  }

  // 토스트
  static void showToast({required String msg}) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: nolColorOrange,
      textColor: Colors.white,
    );
  }

  // 파일크기 측정
  static Future<bool> isBigFile(XFile file) async {
    int fileSize = await file.length();

    //약 15mb
    if (fileSize >= 15882755) return Future.value(true);
    return Future.value(false);
  }

  // 블라인드 체크
  static bool blindCheck({required int declareLength, required int likeLength}) => declareLength >= blindCount && declareLength > likeLength;

  // 로딩 다이어로그
  static void loadingDialog() {
    Get.dialog(
      const Material(
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(color: nolColorOrange),
        ),
      ),
      barrierColor: Colors.black.withOpacity(0.3),
    );
  }

  // 간편 로컬 db 리셋
  static Future<void> resetLoginPreference() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('autoLoginKey');
    prefs.remove('email');
    prefs.remove('loginType');
  }

  //공백 제어 함수
  static String controlSpace(String text) {
    String result = text;
    while (result.contains('\t')) {
      result = result.replaceAll('\t', ' ');
    }
    while (result.contains('\n\n\n')) {
      result = result.replaceAll('\n\n\n', '\n\n');
    }
    while (result.contains('\n ')) {
      result = result.replaceAll('\n ', ' ');
    }
    while (result.contains('　')) {
      result = result.replaceAll('　', '  ');
    }
    while (result.contains('\u200B')) {
      result = result.replaceAll('\u200B', '');
    }
    while (result.contains('   ')) {
      result = result.replaceAll('   ', '  ');
    }
    return result;
  }

  //공백 제거 함수
  static String removeSpace(String text) {
    String result = text;
    result = result.replaceAll(' ', '');
    result = result.replaceAll('\n', '');
    result = result.replaceAll('　', '');
    result = result.replaceAll('\t', '');
    result = result.replaceAll('\u200B', '');

    return result;
  }

  //링크 런처 함수
  static void launchWebUrl(String url) async {
    if (url != '') {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri)) throw '링크 접근에 실패했습니다.';
    }
  }

  static String encodeUrl(String text) => base64.encode(utf8.encode(Uri.encodeFull(text)));

  static String decodeUrl(String text) => Uri.decodeFull(utf8.decode(base64.decode(text)));

  static String getCount(int count) {
    if (count < 10000) {
      return '$count개'; // 만개 미만
    } else if (count < 100000) {
      return '${(count / 10000).toString().substring(0, 3)}만개'; // 10만개 미만
    } else {
      return '${(count / 10000).floor()}만개'; // 10만개 이상
    }
  }

  //지명 약어화 함수
  static String abbreviateForLocation(String location) {
    switch (location) {
      case '서울특별시':
        return '서울';
      case '인천광역시':
        return '인천';
      case '경기도':
        return '경기';
      case '강원도':
        return '강원';
      case '충청남도':
        return '충남';
      case '충청북도':
        return '충북';
      case '세종시':
        return '세종';
      case '대전광역시':
        return '대전';
      case '경상북도':
        return '경북';
      case '경상남도':
        return '경남';
      case '대구광역시':
        return '대구';
      case '부산광역시':
        return '부산';
      case '전라북도':
        return '전북';
      case '전라남도':
        return '전남';
      case '광주광역시':
        return '광주';
      case '울산광역시':
        return '울산';
      case '제주특별자치도':
        return '제주';
    }
    return location;
  }

  //지명 약어화 해제 함수
  static String revertAbbreviateForLocation(String location) {
    switch (location) {
      case '서울':
        return '서울특별시';
      case '인천':
        return '인천광역시';
      case '경기':
        return '경기도';
      case '강원':
        return '강원도';
      case '충남':
        return '충청남도';
      case '충북':
        return '충청북도';
      case '세종':
        return '세종시';
      case '대전':
        return '대전광역시';
      case '경북':
        return '경상북도';
      case '경남':
        return '경상남도';
      case '대구':
        return '대구광역시';
      case '부산':
        return '부산광역시';
      case '전북':
        return '전라북도';
      case '전남':
        return '전라남도';
      case '광주':
        return '광주광역시';
      case '울산':
        return '울산광역시';
      case '제주':
        return '제주특별자치도';
    }
    return location;
  }

  // 요일 한글 변환 함수
  static String changeDayOfTheWeekToKorean(String dayOfTheWeek) {
    switch (dayOfTheWeek) {
      case 'Mon':
        return '월요일';
      case 'Tue':
        return '화요일';
      case 'Wed':
        return '수요일';
      case 'Thu':
        return '목요일';
      case 'Fri':
        return '금요일';
      case 'Sat':
        return '토요일';
      case 'Sun':
        return '일요일';
      default:
        return '월요일';
    }
  }

  // 로그인 했는지 체크 후 callback 함수 실행
  static void loginCheck({required GestureTapCallback callback}) {
    if (GlobalData.loginUser.id == nullInt) {
      showCustomDialog(
        title: '로그인이 필요한 서비스입니다.\n로그인 하시겠어요?',
        okText: '네',
        cancelText: '아니오',
        isCancelButton: true,
        okFunc: () {
          Get.back(); //다이얼로그 끄기
          if (kIsWeb) {
            final isWebMobile = kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android);
            if (isWebMobile) {
              mobileWebLoginDialog(); //다이얼로그 띄움
            } else {
              //pc웹
              Get.dialog(const OtpLoginPage());
            }
          } else {
            //모바일 일반로그인
            Get.to(LoginPage(noTest: true, beBack: true)); //테스트 없음, 로그인 성공시 페이지만 종료.
          }
        },
      );
    } else {
      callback();
    }
  }

  //모바일웹일때 앱으로 가시겠어요 다이얼로그
  static void mobileWebLoginDialog() {
    showCustomDialog(
      title: '앱으로 가기',
      description: '모바일은 앱에서 로그인 할 수 있어요!\n앱으로 이동하시겠어요?',
      okText: '네',
      okFunc: () async {
        Get.back(); //다이얼로그 끄기
        if (!await launchUrl(Uri.https('nolilteo.page.link', '/H7Mw'))) {
          throw '링크 접근에 실패했습니다.';
        }
      },
      isCancelButton: true,
      cancelText: '아니오',
    );
  }

  static Future<void> globalLogin(var res, {Function? callback, Function? falseCallback, Function? nullCallback, bool isNewUser = false}) async {
    if (res == null) {
      if (nullCallback != null) nullCallback();
    } else if (res == false) {
      if (falseCallback != null) falseCallback();
    } else {
      GlobalData.loginUser = model.User.fromJson(res['user']);

      NolAnalytics.logEvent(name: 'login', parameters: {'userID': GlobalData.loginUser.id}); // 애널리틱스 로그인

      // 로그인 데이터 로컬에 저장
      final prefs = await SharedPreferences.getInstance();
      final bool autoLoginKey = prefs.getBool('autoLoginKey') ?? false;
      if (!autoLoginKey) {
        prefs.setBool('autoLoginKey', true);
        prefs.setString('email', res['user']['Email']);
        prefs.setInt('loginType', res['user']['LoginType']);
      }

      bool apptrackingNoti = prefs.getBool("apptrackingNoti") ?? false;
      
      if(!kIsWeb && !apptrackingNoti){
        prefs.setBool("apptrackingNoti", true);
        AppTrackingTransparency.requestTrackingAuthorization();
      }

      //로그인 flow
      GlobalData.accessToken = res['AccessToken'];
      GlobalData.refreshToken = res['RefreshToken'];
      GlobalData.accessTokenExpiredAt = res['AccessTokenExpiredAt'];
      GlobalData.interestTopicList = prefs.getStringList('interestTopicList') ?? []; // 놀터 관심 카테고리
      GlobalData.interestTopicTagList = prefs.getStringList('interestTopicTagList') ?? []; // 놀터 관심 태그
      GlobalData.tmpInterestTopicTagList = prefs.getStringList('tmpInterestTopicTagList') ?? []; // 임시 놀터 관심 태그
      GlobalData.interestJobList = prefs.getStringList('interestJobList') ?? []; // 일터 관심 카테고리
      GlobalData.interestJobTagList = prefs.getStringList('interestJobTagList') ?? []; // 일터 관심 태그
      GlobalData.tmpInterestJobTagList = prefs.getStringList('tmpInterestJobTagList') ?? []; // 임시 일터 관심 태그
      GlobalData.interestLocationList = prefs.getStringList('interestLocationList') ?? []; // 관심 지역

      await setCustomWbtiList(); // 커스텀 wbti 리스트 세팅

      GlobalData.blockedUserIDList = await UserRepository.getBanList(); // 밴 리스트
      if (kReleaseMode) {
        GlobalFunction.accessTokenCheck();
      }

      if(!kIsWeb) {
        FirebaseNotifications().setFcmToken('');
        FirebaseNotifications().setUpFirebase();
      }

      final NotificationController notificationController = Get.put(NotificationController());

      if (isNewUser) {
        notificationController.makeNewUserWelcomeNoti();
        notificationController.showRedDot.value = true;
        notificationController.count = 0;
      } else {
        notificationController.count = res['alarmCount'] ?? 0;
        notificationController.showRedDot.value = notificationController.count == 0 ? false : true;
      }
      // 알림 관련
      if (!kIsWeb) {
        //notificationController.makeRealTempNotiList();
        bool bSupported = await FlutterAppBadger.isAppBadgeSupported();
        if (bSupported) {
          FlutterAppBadger.removeBadge();
        }
      }

      if (callback != null) callback();
    }
  }

  static Future<void> globalLogout({bool isSend = true}) async {
    if (kDebugMode) {
      print('로그아웃');
    }

    if (isSend) {
      UserRepository.logout(userID: GlobalData.loginUser.id);
      NolAnalytics.logEvent(name: 'logout', parameters: {'userID': GlobalData.loginUser.id}); // 애널리틱스 로그아웃
    }

    GlobalData.resetData();

    final NotificationController notificationController = Get.put(NotificationController());
    notificationController.resetData();
    CommunityController.to.resetData();

    // 로컬 데이터 삭제
    final prefs = await SharedPreferences.getInstance();
    final bool autoLoginKey = prefs.getBool('autoLoginKey') ?? false;
    if (autoLoginKey) {
      prefs.remove('autoLoginKey');
    }

    prefs.remove('email');
    prefs.remove('loginType');
    prefs.remove('interestTopicList');
    prefs.remove('interestTopicTagList');
    prefs.remove('tmpInterestTopicTagList');
    prefs.remove('interestJobList');
    prefs.remove('interestJobTagList');
    prefs.remove('tmpInterestJobTagList');
    prefs.remove('interestLocationList');
    prefs.remove('topicAllView');
    prefs.remove('jobAllView');
    prefs.remove('meetingAllView');

    if(kIsWeb){
      MainPageController m = Get.put(MainPageController());
      m.changePage(0);

      goToMainPage();
    }else{
      Get.offAll(() => LoginPage());
    }
  }

  // stringList -> string (|로 구분)
  static String stringListToString(List<String> stringList) {
    String result = '';
    for (int i = 0; i < stringList.length; i++) {
      final String text = stringList[i].replaceFirst('#', '');
      if (i == stringList.length - 1) {
        result += text;
      } else {
        result += '$text|';
      }
    }
    return result;
  }

  // 유저 full nickname
  static String getFullNickName(User user) => '${user.nickName} | ${WbtiType.getType(user.wbti).title} ${user.job}';

  static void accessTokenCheck() {
    GlobalData.tokenTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      try{
        if (int.parse(GlobalData.accessTokenExpiredAt) < int.parse(DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10))) {
          Future.microtask(() async {
            if(kDebugMode) print('refresh token call in func');

            var res = await ApiProvider().post('/User/Check/Token', jsonEncode({"userID": GlobalData.loginUser.id, "refreshToken": GlobalData.refreshToken}));

            if (res != null) {
              GlobalData.accessToken = res['AccessToken'] as String;
              GlobalData.accessTokenExpiredAt = (res['AccessTokenExpiredAt'] as int).toString();
            }
          });
        }
      } catch (err) {
        if(kDebugMode) print(err.toString());
        GlobalData.tokenTimer!.cancel();
        GlobalData.tokenTimer = null;
      }

    });
  }

  // 앱 종료 체크 함수
  static Future<bool> isEnd() async {
    final DateTime now = DateTime.now();

    if (GlobalData.currentBackPressTime == null || now.difference(GlobalData.currentBackPressTime!) > const Duration(seconds: 2)) {
      GlobalData.currentBackPressTime = now;
      GlobalFunction.showToast(msg: '뒤로 가기를 한 번 더 입력하시면 종료됩니다.');

      return Future.value(false);
    }
    return Future.value(true);
  }

  // 메인 페이지로 이동
  static void goToMainPage() {
    Get.until((route) => Get.currentRoute == MainPage.route);
    if (Get.currentRoute != MainPage.route) Get.toNamed(MainPage.route);
  }

  // 커스텀 wbti 리스트 세팅
  static Future<void> setCustomWbtiList() async {
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getStringList('wbtiList') == null) {
      if (GlobalData.loginUser.wbti.isNotEmpty) {
        final WbtiType userWbtiType = WbtiType.getType(GlobalData.loginUser.wbti);
        GlobalData.customWbtiList.remove(userWbtiType);
        GlobalData.customWbtiList.insert(0, userWbtiType);
        await prefs.setStringList('wbtiList', GlobalData.customWbtiList.map((e) => e.type).toList());
      }
    } else {
      GlobalData.customWbtiList = prefs.getStringList('wbtiList')!.map((e) => WbtiType.getType(e)).toList();
    }
  }

  //url 체크
  static String checkURL(String str) {
    late final List<String> list;
    String validURL = "";
    if (str.contains('http')) {
      const urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
      list = str.replaceAll('\n', ' ').split(' ').toList();
      for (String text in list) {
        final bool isValidURL = RegExp(urlPattern, caseSensitive: false).hasMatch(text);
        if (isValidURL) {
          validURL = text;
          break;
        }
      }
      return validURL;
    } else {
      return validURL;
    }
  }

  static List<String> checkURLList(String str) {
    List<String> list = [];

    if (str.contains('http')) {
      const urlPattern = r"(https?|http)://([-A-Z0-9.]+)(/[-A-Z0-9+&@#/%=~_|!:,.;]*)?(\?[A-Z0-9+&@#/%=~_|!:‌​,.;]*)?";
      List<String> tempList = str.replaceAll('\n', ' ').split(' ').toList();

      for (String text in tempList) {
        if (RegExp(urlPattern, caseSensitive: false).hasMatch(text)) {
          list.add(text);
        }
      }
    }

    return list;
  }

  static void getBackTo(String route){
    if(route == 'all'){
      int length = GlobalData.pageRouteList.length;
      GlobalData.pageRouteList.clear();
      for(int i = 0;i<length;i++){
        Get.back();
      }
    } else if(GlobalData.pageRouteList.contains(route)){
      while(GlobalData.pageRouteList.last != route){
        Get.back();
        GlobalData.pageRouteList.removeLast();
        print(GlobalData.pageRouteList);
      }
    } else{
      GlobalFunction.showToast(msg: '뒤로 갈 수 없습니다.');
    }
  }
}