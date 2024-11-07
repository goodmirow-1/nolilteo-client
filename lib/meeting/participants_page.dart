import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_page/controllers/user_detail_controller.dart';
import 'package:nolilteo/config/global_page/user_detail_page.dart';

import '../community/controllers/community_detail_controller.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import '../data/user.dart';
import '../declare/declare_edit_page.dart';
import '../declare/model/declare.dart';
import '../wbti/model/wbti_type.dart';

// ignore: must_be_immutable
class ParticipantsPage extends StatelessWidget {
  ParticipantsPage({Key? key, required this.controller}) : super(key: key);

  final CommunityDetailController controller;
  bool initialize = false;

  @override
  Widget build(BuildContext context) {
    if (!initialize) {
      initialize = true;
      controller.participantsLoading = true;
    }

    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, 
          title:
              '참가 인원(${controller.meetingPost.meetingMembers.length > 99 ? '99+' : controller.meetingPost.meetingMembers.length}${controller.meetingPost.personnel != null ? '/${controller.meetingPost.personnel}' : ''})',
          actions: GlobalData.loginUser.id == controller.meetingPost.userID
              ? null
              : [
                  Padding(
                    padding: EdgeInsets.only(right: 16 * sizeUnit),
                    child: Center(
                      child: InkWell(
                        onTap: () => showCustomDialog(
                          title: '참가중인 모여라를 나가시겠어요?',
                          okFunc: controller.exitMeeting,
                          isCancelButton: true,
                          okText: '네',
                          cancelText: '아니오',
                        ),
                        child: Text('나가기', style: STextStyle.body2().copyWith(color: nolColorGrey)),
                      ),
                    ),
                  ),
                ],
        ),
        body: GetBuilder<CommunityDetailController>(
          id: 'participants',
          tag: controller.tag,
          initState: (state) => controller.initParticipants(),
          builder: (controller) => controller.participantsLoading
              ? const Center(child: CircularProgressIndicator(color: nolColorOrange))
              : ListView.builder(
                  itemCount: controller.meetingPost.meetingMembers.length,
                  itemBuilder: (context, index) => userItem(
                    context,
                    user: GlobalFunction.getUserByUserID(controller.meetingPost.meetingMembers[index]),
                  ),
                ),
        ),
      ),
    );
  }

  Widget userItem(BuildContext context, {required User user}) {
    return Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.to(() => UserDetailPage(userID: user.id)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.nickName, style: STextStyle.subTitle1()),
                    if (user.id == controller.post.userID) ...[
                      SizedBox(width: 4 * sizeUnit),
                      SvgPicture.asset(GlobalAssets.svgCrown, width: 20 * sizeUnit),
                    ],
                  ],
                ),
                SizedBox(height: 10 * sizeUnit),
                Text(
                  '${WbtiType.getType(user.wbti).title} ${user.job}',
                  style: STextStyle.subTitle3().copyWith(color: nolColorOrange),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (GlobalData.loginUser.id != user.id) ...[
            InkWell(
              onTap: () => showUserBottomSheet(context, user: user),
              child: SvgPicture.asset(GlobalAssets.svgVerticalThreeDotSmall, width: 24 * sizeUnit),
            ),
          ],
        ],
      ),
    );
  }

  // 바텀 시트
  void showUserBottomSheet(BuildContext context, {required User user}) {
    showModalBottomSheet<void>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20 * sizeUnit),
          topRight: Radius.circular(20 * sizeUnit),
        ),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 8 * sizeUnit),
            bottomSheetItem(
              text: '프로필 보기',
              onTap: () => Get.to(() => UserDetailPage(userID: user.id)),
            ),
            bottomSheetItem(
              text: '사용자 신고하기',
              onTap: () => Get.to(() => DeclareEditPage(declareType: Declare.declareTypeUser, declaredID: user.id)),
            ),
            bottomSheetItem(text: '사용자 차단하기', onTap: () => controller.userBan(user.id)),
            bottomSheetCancelButton(),
          ],
        );
      },
    );
  }
}
