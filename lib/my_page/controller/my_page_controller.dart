import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/data/user.dart';
import 'package:nolilteo/my_page/block_management_page.dart';
import 'package:nolilteo/my_page/edit_profile_page.dart';
import 'package:nolilteo/my_page/my_post_page.dart';
import 'package:nolilteo/my_page/my_reply_page.dart';
import 'package:nolilteo/my_page/setting_page.dart';
import 'package:nolilteo/my_page/web_login_page.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../wbti/wbti_result_page.dart';
import '../../wbti/wbti_test_page.dart';
import '../my_meeting_post.dart';

class MyPageController extends GetxController {
  static get to => Get.find<MyPageController>();

  late User user;

  String nickname = '닉네임';
  String wbtiText = '';
  String wbtiImg = '';

  void fetchData() {
    user = GlobalData.loginUser;

    nickname = user.nickName;
    WbtiType wbti = WbtiType.getType(user.wbti);
    wbtiText = '${wbti.title} ${user.job}';
    wbtiImg = wbti.src;

    WidgetsBinding.instance.addPostFrameCallback((_) => update(['fetchData']));
  }

  void settingButtonFunc(){
    Get.to(()=> SettingPage());
  }

  void editButtonFunction() {
    Get.to(() => EditProfilePage())?.then((value) => fetchData());
  }

  void goMyPostPage() {
    Get.to(() => MyPostPage(isLike: false, userID: GlobalData.loginUser.id))?.then((value) => fetchData());
  }

  void goMyLikePage() {
    Get.to(() => MyPostPage(isLike: true, userID: GlobalData.loginUser.id))?.then((value) => fetchData());
  }

  void goMyReplyPage() {
    Get.to(() => const MyReplyPage())?.then((value) => fetchData());
  }

  void goMyGatheringPage() {
    Get.to(() => MyMeetingPost(userID: GlobalData.loginUser.id))?.then((value) => fetchData());
  }

  void goMyWBTIPage() {
    Map arguments = {};
    arguments['isMyWbti'] = true;
    Get.toNamed('${WbtiResultPage.route}/${user.wbti}', arguments: arguments)?.then((value){
      if(value != null){
        if(value['reTest'] ?? false){
          Get.to(()=>const WbtiTestPage())?.then((value){
            fetchData();
          });
        }
      }
    });
  }

  void goBlockManagementPage() {
    Get.to(() => BlockManagementPage());
  }

  void goWebLoginPage() {
    Get.to(() => const WebLoginPage());
  }
}
