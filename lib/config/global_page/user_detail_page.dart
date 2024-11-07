import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_page/controllers/user_detail_controller.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../data/global_data.dart';
import '../../my_page/my_meeting_post.dart';
import '../../my_page/my_post_page.dart';
import '../global_assets.dart';
import '../s_text_style.dart';

class UserDetailPage extends StatelessWidget {
  UserDetailPage({Key? key, required this.userID}) : super(key: key);

  final int userID;

  final UserDetailController controller = Get.put(UserDetailController(tag: GlobalData.userPageCount.toString()), tag: GlobalData.userPageCount.toString());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '프로필 보기'),
        body: GetBuilder<UserDetailController>(
          tag: controller.tag,
          initState: (state) => controller.fetchData(userID),
          builder: (_) {
            if (controller.loading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

            return SingleChildScrollView(
              child: Column(
                children: [
                  buildLine(),
                  SizedBox(height: 8 * sizeUnit),
                  userInfoBox(), // 유저 정보
                  SizedBox(height: 16 * sizeUnit),
                  buildLine(),
                  myPageContainer(
                    text: '게시글 보기',
                    onTap: () => Get.to(() => MyPostPage(
                          isLike: false,
                          userID: controller.user.id,
                        )),
                  ),
                  // buildLine(),
                  // myPageContainer(
                  //   text: '모여라 활동 보기',
                  //   onTap: () => Get.to(() => MyMeetingPost(userID: userID)),
                  // ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget myPageContainer({required String text, Function()? onTap}) {
    return InkWell(

      onTap: onTap,
      child: SizedBox(
        width: double.infinity,
        height: 56 * sizeUnit,
        child: Row(
          children: [
            SizedBox(width: 24 * sizeUnit),
            Text(
              text,
              style: STextStyle.subTitle1(),
            ),
            const Spacer(),
            SvgPicture.asset(
              GlobalAssets.svgArrowRight,
              width: 24 * sizeUnit,
              color: nolColorGrey,
            ),
            SizedBox(width: 16 * sizeUnit),
          ],
        ),
      ),
    );
  }

  // 유저 정보
  Widget userInfoBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      width: 328 * sizeUnit,
      height: 318 * sizeUnit,
      decoration: BoxDecoration(
        border: Border.all(
          color: nolColorLightGrey,
          width: 1.5 * sizeUnit,
        ),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 18 * sizeUnit),
          Text(
            controller.user.nickName,
            style: STextStyle.appBar().copyWith(height: 20 / 16),
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10 * sizeUnit),
          Text(
            '${WbtiType.getType(controller.user.wbti).title} ${controller.user.job}',
            style: STextStyle.subTitle2().copyWith(color: nolColorOrange, height: 16 / 14),
          ),
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                WbtiType.getType(controller.user.wbti).src,
                height: 142 * sizeUnit,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
