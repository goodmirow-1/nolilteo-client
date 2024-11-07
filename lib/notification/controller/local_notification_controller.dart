import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:rxdart/rxdart.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../community/community_detail_page.dart';
import '../../community/community_reply_page.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../config/global_function.dart';
import '../../data/global_data.dart';
import '../../home/controllers/main_page_controller.dart';
import '../notification_page.dart';
import 'notification_controller.dart';


class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

class LocalNotifcationController extends GetxController {
  static get to => Get.find<LocalNotifcationController>();
  final MainPageController controller = Get.put(MainPageController());

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject = BehaviorSubject<ReceivedNotification>();
  BehaviorSubject<String> selectNotificationSubject = BehaviorSubject<String>();
  late String selectedNotificationPayload;

  late NotificationDetails platformChannelSpecifics;
  bool hasCheck = false;

  FlutterLocalNotificationsPlugin getFlutterLocalNotificationsPlugin () { return flutterLocalNotificationsPlugin;}

  Future<bool> init() async {
    if (hasCheck == true) return hasCheck;

    var initializationSettingsAndroid = const AndroidInitializationSettings('@drawable/noti_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
        onDidReceiveLocalNotification: (int? id, String? title, String? body, String? payload) async {
          didReceiveLocalNotificationSubject.add(ReceivedNotification(id: id!, title: title!, body: body!, payload: payload!));
        });

    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      color: Color.fromRGBO(255, 139, 119, 1),
      colorized: true
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
      selectedNotificationPayload = payload!;
      selectNotificationSubject.add(payload);
    });

    _configureSelectNotificationSubject();

    hasCheck = true;
    return hasCheck;
  }

  void _configureSelectNotificationSubject() {
    selectNotificationSubject.stream.listen((String payload) async {
      List<String> strList = payload.split('/');
      if(kDebugMode) print("_configureSelectNotificationSubject call");

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
            Get.to(() => CommunityReplyPage(replyID: int.parse(strList[2])));
          }
          break;
      }
    });
  }

  Future<bool> showNoti({String title = "welcome", String des = "JamesFlutter", String payload = ''}) async {
    if (!hasCheck) await init();
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
    await flutterLocalNotificationsPlugin.show(0, title, des, platformChannelSpecifics, payload: payload);

    return true;
  }

  showTime() async {
    if (!hasCheck) await init();
    var scheduledNotificationDateTime = DateTime.now().add(const Duration(seconds: 5));
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'your other channel id',
      'your other channel name',
      channelDescription: 'your other channel description',
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(0, 'scheduled title', 'scheduled body', scheduledNotificationDateTime, platformChannelSpecifics);
  }

  showInterval() async {
    if (!hasCheck) await init();
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'repeating channel id',
      'repeating channel name',
      channelDescription: 'repeating description',
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title', 'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics);
  }

  everyDayTime() async {
    if (!hasCheck) await init();
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'repeatDailyAtTime channel id',
      'repeatDailyAtTime channel name',
      channelDescription: 'repeatDailyAtTime description',
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(0, 'show daily title', 'Daily notification shown at approximately ${time.hour}:${time.minute}:${time.second}', time, platformChannelSpecifics);
  }

  weeklyTargetDayTimeInterval() async {
    if (!hasCheck) await init();
    var time = const Time(10, 0, 0);
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'show weekly channel id',
      'show weekly channel name',
      channelDescription: 'show weekly description',
    );
    var iOSPlatformChannelSpecifics = const IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics, iOS: iOSPlatformChannelSpecifics);
  }

  Future<void> targetNotiCancel({required int targetIndex}) async => await flutterLocalNotificationsPlugin.cancel(targetIndex);

  Future<void> allNotiCancel() async => await flutterLocalNotificationsPlugin.cancelAll();
}
