import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/meeting/controller/meeting_controller.dart';
import 'package:nolilteo/repository/notification_repository.dart';

import '../../community/community_detail_page.dart';
import '../../community/community_reply_page.dart';
import '../../community/componets/post_card.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../config/constants.dart';
import '../../data/global_data.dart';
import '../../data/user.dart';
import '../../home/controllers/main_page_controller.dart';
import '../../meeting/model/meeting_post.dart';
import '../../network/ApiProvider.dart';
import '../../repository/post_repository.dart';
import '../model/notification.dart';
import '../notification_page.dart';


enum SPLIT_ALARM_ENUM{ NEW, TODAY, WEEK, PREV}

const int NOTI_EVENT_TEMP = 0;
const int NOTI_EVENT_POST_LIKE = 1;
const int NOTI_EVENT_POST_REPLY = 2;
const int NOTI_EVENT_POST_REPLY_LIKE = 3;
const int NOTI_EVENT_POST_REPLY_REPLY = 4;
const int NOTI_EVENT_POST_GATHERING_JOIN = 5;
const int NOTI_EVENT_POST_NEW_UPDATE = 6;
const int NOTI_EVENT_POST_DAILY_POPULAR = 7;
const int NOTI_EVENT_POST_WEEKLY_BEST = 8;
const int NOTI_EVENT_NEW_USER_WELCOME = 99;

class NotificationController extends GetxController{
  static get to => Get.find<NotificationController>();

  static RxList<NotificationModel> notiList = <NotificationModel>[].obs;
  RxBool showRedDot = false.obs;

  final GlobalData globalData = Get.put(GlobalData());
  final MainPageController controller = Get.put(MainPageController());
  final CommunityController communityController = Get.put(CommunityController());
  final MeetingController meetingController = Get.put(MeetingController());
  final ScrollController scrollController = ScrollController();
  int id = 0;
  int count = 0;


  @override
  void onClose() {
    super.onClose();

    scrollController.dispose();
  }

  resetData() {
    notiList.clear();
    showRedDot.value = false;
    id = 0;
    count = 0;
  }

  addNotification(NotificationModel model) async {
    notiList.insert(0, model);

    showRedDot.value = true;
  }

  getNotification(int id){
    return notiList.singleWhere((element) => element.id == id);
  }

  removeNotification(NotificationModel model){
    notiList.remove(model);
  }

  Future<void> notiClickEvent(NotificationModel model) async {

    switch(model.type){
      case NOTI_EVENT_POST_LIKE :
      case NOTI_EVENT_POST_REPLY :
      case NOTI_EVENT_POST_REPLY_LIKE:
      case NOTI_EVENT_POST_DAILY_POPULAR:
      case NOTI_EVENT_POST_WEEKLY_BEST:
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

  readNoti(){
    for (var element in notiList) {
      if(element.isSend == false){
        element.isSend = true;
      }
    }

    showRedDot.value = false;
  }

  Future setNotificationListByEvent() async {
    if(notiList.isEmpty){
      var notiListGet = await NotificationRepository.select();

      if (null != notiListGet) {
        bool check = false;
        int id = 0;
        for (int i = 0; i < notiListGet.length; ++i) {
          NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
          if(noti.id != 0){
            notiList.add(noti);
            if(check == false){
              if(noti.isSend == false) {
                id = noti.id;
                check = true;
              }
            }
          }
        }

        await NotificationRepository.update(id: id);
      }

    }else{
      var notiListGet = await NotificationRepository.unSendSelect();

      if (null != notiListGet) {
        for (int i = 0; i < notiListGet.length; ++i) {
          NotificationModel noti = NotificationModel.fromJson(notiListGet[i]);
          if(noti.id != 0){
            notiList.insert(0, noti);
          }
        }
      }
    }
  }

  void setShowRedDot() {
    for (var element in notiList) {
      if(element.isRead == false){
        showRedDot.value = true;
        continue;
      }
    }
  }

  //로컬에서 알림 추가할 때
  addLocalNotification(int type, String createTime) {
    NotificationModel notification = NotificationModel(
      id: id++,
      type: type,
      from: nullInt,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: createTime,
    );
    notification.isRead = false;
    notification.isSend = false;
    notification.isLoad = true;

    notiList.add(notification);
  }

  makeRealTempNotiList(){
    NotificationModel notification1 = NotificationModel(
      id: id++,
      from: 11,
      to: 1,
      title: "좋아요 테스트 타이틀",
      type: NOTI_EVENT_POST_LIKE,
      tableIndex: 3,
      subTableIndex: 9,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );
    notification1.isRead = false;
    notification1.isSend = false;
    notification1.isLoad = false;

    notiList.add(notification1);

    NotificationModel notification2 = NotificationModel(
      id: id++,
      from: 11,
      to: 1,
      title: "댓글 테스트 타이틀",
      type: NOTI_EVENT_POST_REPLY,
      tableIndex: 3,
      subTableIndex: 18,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );
    notification1.isRead = false;
    notification1.isSend = false;
    notification1.isLoad = false;

    notiList.add(notification2);

    NotificationModel notification3 = NotificationModel(
      id: id++,
      from: 11,
      to: 1,
      title: "댓글 좋아요 테스트 타이틀",
      type: NOTI_EVENT_POST_REPLY_LIKE,
      tableIndex: 3,
      subTableIndex: 18,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );
    notification1.isRead = false;
    notification1.isSend = false;
    notification1.isLoad = false;

    notiList.add(notification3);

    NotificationModel notification4 = NotificationModel(
      id: id++,
      from: 11,
      to: 1,
      title: "대댓글 테스트 타이틀",
      type: NOTI_EVENT_POST_REPLY_REPLY,
      tableIndex: 3,
      subTableIndex: 18,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );
    notification1.isRead = false;
    notification1.isSend = false;
    notification1.isLoad = false;

    notiList.add(notification4);

    NotificationModel notification5 = NotificationModel(
      id: id++,
      from: 11,
      to: 1,
      title: "모여라 참가 테스트 타이틀",
      type: NOTI_EVENT_POST_GATHERING_JOIN,
      tableIndex: 3,
      subTableIndex: 18,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );
    notification1.isRead = false;
    notification1.isSend = false;
    notification1.isLoad = false;

    notiList.add(notification5);
  }

  makeNewUserWelcomeNoti(){
    NotificationModel noti = NotificationModel(
      id: id++,
      from: 0,
      to: 0,
      title: "",
      type: NOTI_EVENT_NEW_USER_WELCOME,
      tableIndex: 0,
      subTableIndex: 0,
      updatedAt: GlobalFunction.replaceDate(DateTime.now().toString()),
      createdAt: DateTime.now().toString(),
    );

    notiList.add(noti);
  }

  List<NotificationModel> splitNotiList(SPLIT_ALARM_ENUM alarmEnum){
    return notiList.where((e) {
      bool check = false;
      DateTime createTime = DateTime.parse(e.createdAt);
      switch(alarmEnum){
        case SPLIT_ALARM_ENUM.NEW :
          {
            if(e.isSend == false) check = true;
          }
        break;
        case  SPLIT_ALARM_ENUM.TODAY : //오늘
          {
            if(e.isSend == false) {
              check = false;
            } else if(createTime.month == DateTime.now().month && createTime.day == DateTime.now().day) {
              check = true;
            }
          }
          break;
        case SPLIT_ALARM_ENUM.WEEK : //이번주
          {
            if(e.isSend == false) {
              check = false;
              break;
            }

            int diffDays = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day).difference(
                DateTime(
                    createTime.year,
                    createTime.month,
                    createTime.day)
            ).inDays;

            if(createTime.day != DateTime.now().day && diffDays <= 7) check = true;
          }
          break;
        case SPLIT_ALARM_ENUM.PREV : //이전알림
          {
            if(e.isSend == false) {
              check = false;
              break;
            }

            int diffDays = DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day).difference(
                DateTime(
                    createTime.year,
                    createTime.month,
                    createTime.day)
            ).inDays;

            if(createTime.day != DateTime.now().day &&
                diffDays > 7
            ) {
              check = true;
            }
          }
          break;
      }

      return check;
    }).toList();
  }
}