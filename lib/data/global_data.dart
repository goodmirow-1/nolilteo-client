import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_abstract_class.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/notification/controller/notification_controller.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../data/user.dart';
import '../community/controllers/community_controller.dart';
import '../community/models/post.dart';
import '../home/controllers/main_page_controller.dart';
import '../meeting/controller/meeting_controller.dart';
import '../network/ApiProvider.dart';
import '../notification/model/notification.dart';

class GlobalData extends StoppableService{
  static User tempUser = User(id: nullInt, nickName: '', createdAt: '', updatedAt: ''); // 임시용
  static User loginUser = tempUser; // 로그인한 유저
  static String accessToken = '';
  static String refreshToken = '';
  static String accessTokenExpiredAt = '';
  static Timer? tokenTimer;
  static String payload = '';


  static List<User> userList = []; // 유저 리스트
  static List<int> blockedUserIDList = []; // 차단한 사용자 id 리스트
  static List<String> interestJobList = []; // 관심사 리스트
  static List<String> interestTopicList = []; // 관심사 리스트
  static List<String> interestJobTagList = []; // 관심 태그 리스트
  static List<String> interestTopicTagList = []; // 관심 태그 리스트
  static List<String> tmpInterestTopicTagList = []; // 임시 관심 태그 리스트
  static List<String> tmpInterestJobTagList = []; // 임시 관심 태그 리스트
  static List<String> interestLocationList = []; // 등록한 지역 리스트
  static RxList<Post> hotListByHour = <Post>[].obs; // 시간별 핫 리스트
  static RxList<Post> popularListByRealTime = <Post>[].obs; // 실시간 인기 리스트
  static List<WbtiType> customWbtiList = WbtiType.wbtiTypeListByGanada; // 커스텀 wbti 리스트
  static List<String> pageRouteList = [];//페이지 경로 리스트

  static Post? changedPost; // 변경된 게시글
  static int detailPageCount = 0; // 디테일 페이지 몇 개 열렸는지
  static int userPageCount = 0; // 유저 페이지 몇 개 열렸는지
  static int myPostPageCount = 0; // 게시글 보기 페이지 몇 개 열렸는지
  static int myMeetingPageCount = 0; // 모여라 활동 페이지 몇 개 열렸는지
  static int boardPageCount = 0; //보드 페이지 몇 개 열렸는지
  static String? dynamicLink; // 다이나믹링크

  static DateTime? currentBackPressTime; // 앱 종료 체크용

  // 글로벌 데이터 초기화
  static void resetData(){
    loginUser = tempUser;
    accessToken = '';
    refreshToken = '';
    accessTokenExpiredAt = '';

    userList.clear();
    blockedUserIDList.clear();
    interestJobList.clear();
    interestTopicList.clear();
    interestJobTagList.clear();
    interestTopicTagList.clear();
    tmpInterestTopicTagList.clear();
    tmpInterestJobTagList.clear();
    interestLocationList.clear();

    detailPageCount = 0;
    userPageCount = 0;
    myPostPageCount = 0;
    myMeetingPageCount = 0;
    boardPageCount = 0;

    if(tokenTimer != null){
      tokenTimer!.cancel();
      tokenTimer = null;
    }

    payload = "";
  }

  User? getUser(int userID){
    if(userID == nullInt) return null;

    return userList.singleWhere((element) => element.id == userID);
  }

  @override
  void start() {
    super.start();
    if(loginUser.id != nullInt && !kIsWeb){
      if(Get.currentRoute == '/main'){

        MainPageController mainPageController = Get.find();
        //모여라 페이지
        if(mainPageController.currentIndex == 1){
          Future.microtask(() async {
            MeetingController meetingController = Get.find();

            final String categoryText = meetingController.isAllView.value ? '' : GlobalFunction.stringListToString(meetingController.filteredCategoryList);
            final String tagText = meetingController.isAllView.value ? '' : GlobalFunction.stringListToString(meetingController.filteredTagList);
            final String locationText = GlobalFunction.stringListToString(meetingController.locationListDeduplication(meetingController.filteredLocationList));
            int lastID = meetingController.postList.isEmpty ? 0 : meetingController.postList.first.id;

            var res = await ApiProvider().post('/OnResume', jsonEncode({
              "userID" : loginUser.id,
              "type" : Post.postTypeMeeting,
              "needAll" : meetingController.isAllView.value == false ? 0 : 1,
              "categoryList": categoryText,
              "tagList": tagText,
              "locationList": locationText,
              "lastID" : lastID
            }));

            if(res){
              NotificationController notificationController = Get.find();
              notificationController.showRedDot.value = true;
            }
          });
        }else{
          Future.microtask(() async {
            //놀터,일터 페이지
            CommunityController communityController = Get.find();

            final String categoryText = communityController.isAllView ? '' : GlobalFunction.stringListToString(communityController.filteredCategoryList);
            final String tagText = communityController.isAllView ? '' : GlobalFunction.stringListToString(communityController.filteredTagList);
            int lastID = 0;

            if(communityController.postList.isNotEmpty){
              for(var i = 0 ; i < communityController.postList.length ; ++i){
                if(!communityController.postList[i].isHot) {
                  lastID = communityController.postList[i].id;
                  break;
                }
              }
            }

            var res = await ApiProvider().post('/OnResume', jsonEncode({
              "userID" : loginUser.id,
              "type" : communityController.isJob == true ? 1 : 0,
              "needAll" : communityController.isAllView == false ? 0 : 1,
              "categoryList": categoryText,
              "tagList": tagText,
              "lastID" : lastID
            }));

            if(res){
              NotificationController notificationController = Get.find();
              notificationController.showRedDot.value = true;
            }
          });
        }
      }

      GlobalFunction.accessTokenCheck();
    }
  }

  @override
  void stop() {
    super.stop();

    if(loginUser.id != nullInt && !kIsWeb){
      ApiProvider().post('/OnPause', jsonEncode({
        "userID" : loginUser.id
      }));

      if(GlobalData.tokenTimer != null){
        GlobalData.tokenTimer!.cancel();
      }
    }
  }
}