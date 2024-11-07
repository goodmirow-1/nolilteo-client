import 'dart:convert';
import 'dart:ui';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:nolilteo/community/board_page.dart';
import 'package:nolilteo/community/controllers/community_controller.dart';
import 'package:nolilteo/config/analytics.dart';
import 'package:nolilteo/home/controllers/main_page_controller.dart';
import 'package:nolilteo/login/admin_page.dart';
import 'package:nolilteo/wbti/wbti_result_page.dart';
import 'package:nolilteo/wbti/wbti_test_page.dart';
import 'community/community_detail_page.dart';
import 'package:url_strategy/url_strategy.dart';
import 'community/community_reply_page.dart';
import 'community/models/post.dart';
import 'config/constants.dart';
import 'config/global_abstract_class.dart';
import 'config/global_function.dart';
import 'data/global_data.dart';
import 'home/main_page.dart';
import 'login/controllers/login_controller.dart';
import 'login/splash_screen.dart';

import 'config/global_widgets/global_widget.dart';
import 'firebase_options.dart';
import 'my_page/controller/my_page_controller.dart';
import 'network/ApiProvider.dart';
import 'notification/controller/local_notification_controller.dart';
import 'notification/model/notification.dart';
import 'share/share_link.dart';
import 'notification/controller/notification_controller.dart';
import 'wbti/controller/wbti_controller.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget child;

  LifeCycleManager({Key? key, required this.child}) : super(key: key);

  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver {
  final GlobalData globalData = Get.put(GlobalData());
  final NotificationController notificationController = Get.put(NotificationController());

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(kDebugMode) print('state = $state');

    List<StoppableService> services = [
      globalData,
    ];

    for (var service in services) {
      if (state == AppLifecycleState.resumed) {
        if (GlobalData.loginUser.id != nullInt) {
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
        }

        service.start();
      } else if (state == AppLifecycleState.paused) {
        service.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: widget.child,
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  if(kDebugMode) print('Handling a background message ${message.messageId}');

  bool bSupported = await FlutterAppBadger.isAppBadgeSupported();
  if (bSupported) {
    FlutterAppBadger.updateBadgeCount(1);
  }
}

void setupFCM() {
  FirebaseMessaging.instance.getToken().then((token) {
    if(kDebugMode) print('firebase getToken func call');
    if(kDebugMode) print(token);
  });

  FirebaseMessaging.instance.getAPNSToken().then((token) {
    if(kDebugMode) print('firebase getAPNSToken func call');
    if(kDebugMode) print(token);
  });

  FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
    if(kDebugMode) print('firebase onTokenRefresh func call');
  });

  FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
    if(kDebugMode) print("firebase onMessage Call ${message.data}");
    List<String> strList = (message.data['body'] as String).split('|');

    int type = int.parse(strList[0]);

    if(type == NOTI_EVENT_POST_NEW_UPDATE){
      if(kDebugMode) print(Get.currentRoute);
      int cType = int.parse(strList[1]);
      String category = strList[2];
      String tag = '#${strList[3]}';

      if(Get.currentRoute == '/main'){
        //놀터,일터 페이지
        CommunityController communityController = Get.find();
        //놀터
        if(communityController.barIndex == Post.postTypeTopic){
          //현재 페이지와 받은 데이터가 같을 때
          if(cType == Post.postTypeTopic){
            //ALL 선택
            if(communityController.isAllView){
              communityController.setActiveNewPost(true);
            }else{
              //관심목록 선택 되어있을 때
              if(communityController.selectedInterestForTopic != ''){
                //카테고리가 같거나, 태그가 같으면
                if(communityController.selectedInterestForTopic == category || communityController.selectedInterestForTopic == tag){
                  communityController.setActiveNewPost(true);
                }
              }else{
                //관심목록에 카테고리,태그 등록되어 있을 때
                if(GlobalData.interestTopicList.contains(category) || GlobalData.interestTopicTagList.contains(tag)){
                  communityController.setActiveNewPost(true);
                }
              }
            }
          }
        }else{
          //일터
          if(cType == Post.postTypeJob){
            //ALL 선택
            if(communityController.isAllView){
              communityController.setActiveNewPost(true);
            }else{
              //관심목록 선택 되어 있을 때
              if(communityController.selectedInterestForJob != ''){
                //카테고리가 같거나, 태그가 같으면
                if(communityController.selectedInterestForTopic == category || communityController.selectedInterestForTopic == tag){
                  communityController.setActiveNewPost(true);
                }
              }else{
                //관심목록에 카테고리,태그 등록되어 있을 때
                if(GlobalData.interestJobList.contains(category) || GlobalData.interestJobTagList.contains(tag)){
                  communityController.setActiveNewPost(true);
                }
              }
            }
          }
        }
      }
    }else{
      NotificationModel model = NotificationModel(
          type: type,
          id:  int.parse(strList[1]),
          from: int.parse(strList[2]),
          to: int.parse(strList[3]),
          title: strList[4],
          nickName: strList[5],
          tableIndex: int.parse(strList[6]),
          subTableIndex: int.parse(strList[7]),
          cType: int.parse(strList[8]),
          createdAt: strList[9],
          updatedAt: strList[9]
      );
      NotificationController notificationController = Get.put(NotificationController());
      await notificationController.addNotification(model);

      String payload = '${message.data['screen']}/${model.tableIndex}/${model.subTableIndex}';

      if(message.data['title'] != null && message.data['notibody'] != null){
        final LocalNotifcationController localNotifcationController = Get.put(LocalNotifcationController());
        localNotifcationController.showNoti(title: message.data['title'], des: message.data['notibody'], payload: payload);
      }
    }
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
    if(kDebugMode) print("firebase onMessageOpenedApp Call");
    FlutterAppBadger.removeBadge();
    await screenControllFunc(message.data);
  });

  Future.microtask(() async {

    final LocalNotifcationController localNotifcationController = Get.put(LocalNotifcationController());
    final NotificationAppLaunchDetails? notificationAppLaunchDetails = await localNotifcationController.getFlutterLocalNotificationsPlugin().getNotificationAppLaunchDetails();

    if(notificationAppLaunchDetails!.payload != null){
      GlobalData.payload = notificationAppLaunchDetails!.payload.toString();
    }
  });
}

Future screenControllFunc(Map<String, dynamic> message) async {
  List<String> strList = (message['body'] as String).split('|');

  NotificationModel model = NotificationModel(
      type: int.parse(strList[0]),
      id:  int.parse(strList[1]),
      from: int.parse(strList[2]),
      to: int.parse(strList[3]),
      title: strList[4],
      nickName: strList[5],
      tableIndex: int.parse(strList[6]),
      subTableIndex: int.parse(strList[7]),
      cType: int.parse(strList[8]),
      createdAt: strList[9],
      updatedAt: strList[9]
  );

  if(kDebugMode) print("_configureSelectNotificationSubject call");

  switch(model.type){
    case NOTI_EVENT_POST_LIKE :
    case NOTI_EVENT_POST_REPLY :
    case NOTI_EVENT_POST_REPLY_LIKE:
      {
        Get.toNamed('${CommunityDetailPage.route}/${model.tableIndex}')!.then((value) => GlobalFunction.syncPost());
      }
      break;
    case NOTI_EVENT_POST_REPLY_REPLY:
      {
        Get.to(() => CommunityReplyPage(replyID: model.subTableIndex));
      }
      break;
    case NOTI_EVENT_POST_GATHERING_JOIN:
      {
        Get.toNamed('${CommunityDetailPage.meetingRoute}/${model.tableIndex}')!.then((value) => GlobalFunction.syncPost());
      }
      break;
    default :
      {

      }
      break;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if(!kIsWeb){
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  NolAnalytics.logAppOpen(); // 애널리틱스 앱 시작

  setPathUrlStrategy(); //url # 제거

  //다이나믹링크 받는 함수
  initDynamicLinks();

  WidgetsFlutterBinding.ensureInitialized(); //패키지 정보 패키지 사용을 위해

  //카카오 로그인
  // final String key = await rootBundle.loadString('assets/text/key');
  // final aesKey = encrypt.Key.fromBase64(key);
  // const value = 'PX2RnL+4SS4s9Q44AdS/eXOR5oqnwiyLFDX9k/Jh3STrNcTNX2KUeAVa6tWkcl+f'; //암호화된 카카오키
  //
  // final encrypted = encrypt.Encrypted(base64.decode(value));
  //
  // final iv = encrypt.IV.fromLength(16);
  //
  // final decrypted = encrypt.AES(aesKey).decrypt(encrypted, iv: iv);
  // final kakaoKey = utf8.decode(decrypted);
  //
  // KakaoSdk.init(nativeAppKey: kakaoKey);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  @override
  void initState() {
    if(!kIsWeb){
      setupFCM();
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    sizeUnit = kIsWeb ? 1.0 : WidgetsBinding.instance.window.physicalSize.width / WidgetsBinding.instance.window.devicePixelRatio / 360;
    if(kDebugMode) print("size unit is $sizeUnit");
    return LifeCycleManager(
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'WBTI, 일할 때 나의 성격유형',
          theme: ThemeData(
            fontFamily: 'NanumSquareNeo',
            scaffoldBackgroundColor: Colors.white,
            colorSchemeSeed: nolColorOrange,
          ),
          navigatorObservers: [observer], // 애널리틱스 옵져버 세팅
          scrollBehavior: AppScrollBehavior(),
          localizationsDelegates: const [GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate],
          supportedLocales: const [
            Locale('ko', 'KR'),
          ],
          initialRoute: kIsWeb ? WbtiTestPage.route : SplashScreen.route,
          getPages: [
            // GetPage(name: SplashScreen.route, page: () => const SplashScreen()),
            // GetPage(name: '/LoginPage', page: () => MainPage()),
            GetPage(name: WbtiTestPage.route, page: () => const WbtiTestPage()),
            // GetPage(name: MainPage.route, page: () => MainPage()),
            // GetPage(name: '${CommunityDetailPage.route}/:id', page: () => CommunityDetailPage(isMeeting: false)),
            // GetPage(name: '${CommunityDetailPage.meetingRoute}/:id', page: () => CommunityDetailPage(isMeeting: true)),
            // GetPage(name: '${BoardPage.route}/:category', page: () => BoardPage()),
            // GetPage(name: '/CommunityPage', page: () => MainPage()),
            // GetPage(name: '/CommunityWriteOrModifyPage', page: () => MainPage()),
            // GetPage(name: '/DeclareEditPage', page: () => MainPage()),
            // GetPage(name: '/AccountManagementPage', page: () => MainPage()),
            // GetPage(name: '/BlockedUserPage', page: () => MainPage()),
            // GetPage(name: '/FindPasswordPage', page: () => MainPage()),
            // GetPage(name: '/CreateAccountPage', page: () => MainPage()),
            // GetPage(name: '/TermsPage', page: () => MainPage()),
            // GetPage(name: '/NicknamePage', page: () => MainPage()),
            // GetPage(name: '/WbtiTestPage', page: () => MainPage()),
            GetPage(name: '${WbtiResultPage.route}/:type', page: () => const WbtiResultPage()),
            // GetPage(name: '/CategoryPage', page: () => MainPage()),
            // GetPage(name: '/SearchPage', page: () => MainPage()),
            // GetPage(name: '/CommunityReplyPage', page: () => MainPage()),
            // GetPage(name: '/minified:id', page: () => MainPage()),  // release 용
            // GetPage(name: AdminLoginPage.route, page: ()=> const AdminLoginPage()),//admin login page
          ],
          initialBinding: InitialBinding()),
    );
  }
}

// 스크롤 터치로 가능하도록
class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<LoginController>(LoginController());
    Get.put(MainPageController());
    Get.put(CommunityController());
    Get.put(WbtiController());
    Get.put(MyPageController());
  }
}
