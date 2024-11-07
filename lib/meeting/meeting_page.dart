import 'package:badges/badges.dart' as MyBadge;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/models/post.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_page/location_selection_page.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/notification/controller/notification_controller.dart';

import '../community/community_detail_page.dart';
import '../community/componets/post_card.dart';
import '../config/constants.dart';
import '../config/global_function.dart';
import '../config/global_page/search_page.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import '../home/main_page.dart';
import '../notification/notification_page.dart';
import '../config/global_widgets/responsive.dart';
import 'controller/meeting_controller.dart';
import 'model/meeting_post.dart';

class MeetingPage extends StatelessWidget {
  MeetingPage({Key? key}) : super(key: key);

  final MeetingController controller = Get.put(MeetingController());
  final NotificationController notificationController = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      showSideSection: true,
      webActions: actions(),
      child: Scaffold(
        appBar: buildAppBar(context),
        body: GetBuilder<MeetingController>(
          initState: (_) => controller.fetchData(),
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildLine(),
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      buildListView(),
                      if (controller.activeNewPost.value) ...[newPostWidget()]
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // 새 글이 업데이트 되었어요
  Positioned newPostWidget() {
    return Positioned(
      top: 16 * sizeUnit,
      child: InkWell(
        onTap: () {
          controller.scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
          controller.onRefresh();
        },
        child: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(16 * sizeUnit), color: Colors.white),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * sizeUnit, vertical: 4 * sizeUnit),
            decoration: BoxDecoration(
              color: nolColorOrange,
              borderRadius: BorderRadius.circular(18 * sizeUnit),
            ),
            child: Text("새 게시물 ", style: STextStyle.body2().copyWith(color: Colors.white)),
          ),
        ),
      ),
    );
  }

  Widget buildListView() {
    return customRefreshIndicator(
      onRefresh: controller.onRefresh,
      child: CustomScrollView(
        controller: controller.scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: Colors.white,
            elevation: 0.0,
            expandedHeight: controller.isAllView.value || controller.interestList.isEmpty ? 48 * sizeUnit : 96 * sizeUnit,
            flexibleSpace: Column(
              children: [
                if (!controller.isAllView.value && controller.interestList.isNotEmpty) Flexible(child: buildInterests()), // 관심 목록
                buildLocationList(), // 관심 지역
              ],
            ),
          ),
          if (GlobalData.interestLocationList.isEmpty) ...[
            SliverToBoxAdapter(
                child: Column(children: [
              SizedBox(
                height: 160 * sizeUnit,
              ),
              noSearchResultWidget('지역을 등록해 주세요')
            ]))
          ] else ...[
            controller.loading
                ? SliverToBoxAdapter(
                    child: Column(
                      children: [
                        SizedBox(height: Get.height * 0.3),
                        const CircularProgressIndicator(color: nolColorOrange),
                      ],
                    ),
                  )
                : buildPostListView(),
          ]
        ],
      ),
    );
  }

  PreferredSize? buildAppBar(BuildContext context) {
    return customAppBar(
      context,
      controller: controller.scrollController,
      showAppBar: Responsive.isMobile(context),
      title: '모여라',
      centerTitle: true,
      leadingWidth: double.infinity,
      leading: Padding(
        padding: EdgeInsets.only(left: 16 * sizeUnit),
        child: Row(
          children: [
            if (Responsive.isMobile(context)) ...[
              InkWell(
                onTap: () => MainPage.mainPageScaffoldKey.currentState!.openDrawer(),
                child: SvgPicture.asset(
                  GlobalAssets.svgMenu,
                  width: 24 * sizeUnit,
                ),
              ),
              SizedBox(width: 24 * sizeUnit),
            ],
            InkWell(
                child: Obx(
                  () => MyBadge.Badge(
                    showBadge: notificationController.showRedDot.value,
                    position: MyBadge.BadgePosition.topEnd(top: -6 * sizeUnit, end: 2 * sizeUnit),
                    badgeColor: nolColorOrange,
                    elevation: 0,
                    toAnimate: false,
                    badgeContent: const Text(''),
                    child: SvgPicture.asset(
                      GlobalAssets.svgAlarm,
                      width: 24 * sizeUnit,
                      height: 24 * sizeUnit,
                    ),
                  ),
                ),
                onTap: () async {
                  await notificationController.setNotificationListByEvent();

                  Get.to(() => const TotalNotificationPage());
                }),
          ],
        ),
      ),
      actions: actions(),
    );
  }

  static List<Widget> actions() {
    final MeetingController controller = Get.find<MeetingController>();

    return [
      InkWell(
        onTap: () => Get.to(() => SearchPage(postType: Post.postTypeMeeting)),
        child: SvgPicture.asset(
          GlobalAssets.svgSearch,
          width: 24 * sizeUnit,
        ),
      ),
      SizedBox(width: 19 * sizeUnit),
      InkWell(
        onTap: () => controller.allToggle(),
        child: Center(
          child: Obx(() => Text(
                'ALL',
                style: STextStyle.subTitle1().copyWith(
                  color: controller.isAllView.value ? nolColorOrange : nolColorGrey,
                ),
              )),
        ),
      ),
      SizedBox(width: 16 * sizeUnit),
    ];
  }

  // 게시글 리스트뷰
  Widget buildPostListView() {
    if (controller.postList.isEmpty) {
      return SliverToBoxAdapter(
        child: Column(
          children: [
            SizedBox(
              height: 160 * sizeUnit,
            ),
            noSearchResultWidget('해당하는 글이 없어요')
          ],
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final MeetingPost post = controller.postList[index];

          // 차단한 사용자의 글인 경우
          if (GlobalData.blockedUserIDList.contains(post.userID)) {
            if (index == 0) {
              return SizedBox(height: 16 * sizeUnit);
            } else {
              return const SizedBox.shrink();
            }
          }

          return Padding(
            padding: EdgeInsets.only(top: index == 0 ? 16 * sizeUnit : 0),
            child: PostCard(
              post: post,
              meetingPost: post,
              onTap: () async => Get.toNamed('${CommunityDetailPage.meetingRoute}/${post.id}')!.then((value) => GlobalFunction.syncPost()), // 게시글 동기화
            ),
          );
        },
        childCount: controller.postList.length,
      ),
    );
  }

  // 관심 목록
  Widget buildInterests() {
    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: nolColorLightGrey))),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(
            controller.interestList.length,
            (index) {
              final String interest = controller.interestList[index];
              final bool isActive = interest == controller.selectedInterest;

              return Padding(
                padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
                child: nolChips(
                  text: interest,
                  bgColor: isActive ? nolColorOrange : Colors.white,
                  fontColor: isActive ? Colors.white : nolColorOrange,
                  onTap: () => controller.interestTapFunc(interest),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // 관심 지역
  Widget buildLocationList() {
    Widget plusButton() {
      if (GlobalData.interestLocationList.isEmpty) {
        return Padding(
          padding: EdgeInsets.only(right: 8 * sizeUnit),
          child: nolChips(
              text: '지역등록',
              bgColor: nolColorOrange,
              fontColor: Colors.white,
              onTap: () {
                List<String> originLocationList = [...GlobalData.interestLocationList];

                Get.to(() => LocationSelectionPage(showInterestList: true))!.then((value) {
                  controller.afterLocationRegister(originLocationList);
                });
              }),
        );
      }

      return Padding(
        padding: EdgeInsets.only(right: 16 * sizeUnit),
        child: InkWell(
          onTap: () {
            List<String> originLocationList = [...GlobalData.interestLocationList];

            Get.to(() => LocationSelectionPage(showInterestList: true))!.then((value) {
              if (value != null) {
                if (!GlobalData.interestLocationList.contains(value)) GlobalData.interestLocationList.add(value);
              }
              controller.afterLocationRegister(originLocationList);
              // controller.update();
            });
          },
          child: SvgPicture.asset(GlobalAssets.svgPlusInCircle, width: 24 * sizeUnit),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: nolColorLightGrey))),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              GlobalData.interestLocationList.length + 1,
              (index) {
                if (index == GlobalData.interestLocationList.length) {
                  return Padding(
                    padding: EdgeInsets.only(left: GlobalData.interestLocationList.isEmpty ? 16 * sizeUnit : 0),
                    child: plusButton(),
                  );
                }

                final String location = GlobalData.interestLocationList[index];
                final bool isActive = location == controller.selectedLocation;

                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
                  child: nolChips(
                    text: '@$location'.replaceFirst(' ALL', ''),
                    bgColor: isActive ? nolColorOrange : Colors.white,
                    fontColor: isActive ? Colors.white : nolColorOrange,
                    onTap: () => controller.locationTapFunc(location),
                  ),
                );
              },
            ),
          )),
    );
  }
}
