import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import '../data/global_data.dart';
import '../notification/controller/local_notification_controller.dart';
import '../notification/controller/notification_controller.dart';
import 'ApiProvider.dart';
import 'package:get/get.dart';

bool isFirebaseCheck = false;
bool isLoadFirebase = false;
//Firebase관련 class
class FirebaseNotifications {
  static String _fcmToken = '';

  static bool isPlay = false;
  static bool isWork = false;
  static bool isGather = false;
  static bool isSubscribe = false;
  static bool isRecommend = false;
  static bool isMarketing = false;

  String get getFcmToken => _fcmToken;

  final LocalNotifcationController localNotifcationController = Get.put(LocalNotifcationController());
  final NotificationController notificationController = Get.put(NotificationController());

  void setFcmToken (String token) {
    _fcmToken = token;
    isFirebaseCheck = false;
  }

  FirebaseNotifications();

  void setUpFirebase() {
    if(isFirebaseCheck == false){
      isFirebaseCheck = true;
    }else{
      return;
    }

    Future.microtask(() async {
      await FirebaseMessaging.instance.requestPermission(sound: true, badge: true, alert: true, provisional: false);
      return FirebaseMessaging.instance;
    }) .then((_) async{
      if(_fcmToken == ''){
        _fcmToken = (await _.getToken())!;
        var res = await ApiProvider().post('/Fcm/Token/Save', jsonEncode({
          "userID" : GlobalData.loginUser.id,
          "token" : _fcmToken,
        }));

        if(res != null){
          FirebaseNotifications.isPlay = res['item']['PlayAlarm'] ?? true;
          FirebaseNotifications.isWork = res['item']['WorkAlarm'] ?? true;
          FirebaseNotifications.isGather = res['item']['WorkAlarm'] ?? true;
          FirebaseNotifications.isSubscribe = res['item']['SubscribeAlarm'] ?? true;
          FirebaseNotifications.isRecommend = res['item']['RecommendAlarm'] ?? true;
          FirebaseNotifications.isMarketing = GlobalData.loginUser.marketingAgree!;
        }
      }
      return;
    });
  }

  bool calculateLocation(String pLocation, {String selectedLocation = ''}){
    bool bCheck = false;

    if(selectedLocation != ''){
      if(selectedLocation == pLocation){
        bCheck;
      }
    }else{
      if(GlobalData.interestLocationList.contains(pLocation)){
        bCheck = true;
      }
    }

    if(false == bCheck){
      List<String> pList = pLocation.split(' ');
      for(var i = 0 ; i < GlobalData.interestLocationList.length ; ++i){
        var location = GlobalData.interestLocationList[i];
        List<String> list = location.split(' ');

        //전체 인지 검색
        if(list[1] == 'ALL'){
          if(pList[0] == list[0]) {
            bCheck = true;
            break;
          }
        }
      }
    }

    return bCheck;
  }

  showNotification(Map<String, dynamic> msg){
  }

  void SetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  void SetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }

  static void setSubScriptionToTopicClear(){

  }

  static void globalSetSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.subscribeToTopic(topic);
  }

  static void globalSetUnSubScriptionToTopic(String topic){
    FirebaseMessaging.instance.unsubscribeFromTopic(topic);
  }
}