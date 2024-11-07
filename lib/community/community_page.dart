import 'dart:convert';

import 'package:badges/badges.dart' as MyBadge;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/board_page.dart';
import 'package:nolilteo/community/interest_register_page.dart';
import 'package:nolilteo/config/global_page/search_page.dart';
import 'package:nolilteo/config/global_widgets/animated_tap_bar.dart';
import 'package:nolilteo/home/main_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../community/community_detail_page.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/models/post.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/base_widget.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/responsive.dart';
import '../config/s_text_style.dart';
import '../network/ApiProvider.dart';
import '../notification/controller/notification_controller.dart';
import '../notification/notification_page.dart';
import 'componets/post_card.dart';

class CommunityPage extends StatelessWidget {
  CommunityPage({Key? key}) : super(key: key);

  final CommunityController controller = Get.find<CommunityController>();
  final NotificationController notificationController = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommunityController>(
        initState: (_) => controller.fetchData(),
        builder: (_) {
          if (controller.fetchLoading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

          return BaseWidget(
            showSideSection: true,
            webActions: actions(),
            child: Scaffold(
              appBar: dashboardAppBar(context),
              body: Column(
                children: [
                  AnimatedTapBar(
                    barIndex: controller.showIndex,
                    listTabItemTitle: controller.titleList,
                    listTabItemWidth: controller.titleWidthList,
                    onPageChanged: (index) {
                      if (controller.pageController.hasClients) controller.pageController.animateToPage(index, duration: AnimatedTapBar.duration, curve: AnimatedTapBar.curve);
                      if (controller.scrollController.hasClients && controller.scrollController.offset > 0.1) controller.scrollController.jumpTo(0.1);
                    },
                  ),
                  buildLine(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        buildPageView(context),
                        if (controller.activeNewPost.value) ...[newPostWidget()]
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
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
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16 * sizeUnit),
            color: Colors.white,
          ),
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

  Widget buildPageView(BuildContext context) {
    final List<Post> postList = controller.isHot ? controller.hotList : controller.postList;

    return PageView.builder(
        controller: controller.pageController,
        itemCount: controller.titleList.length,
        onPageChanged: (index) => controller.pageChange(context, index),
        itemBuilder: (context, index) {
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
                  expandedHeight: 48 * sizeUnit,
                  flexibleSpace: buildInterests(context),
                ),
                controller.loading
                    ? SliverToBoxAdapter(
                        child: Column(
                          children: [
                            SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                            const CircularProgressIndicator(color: nolColorOrange),
                          ],
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == 0) {
                            return titleBar(
                              title: '인기 게시글',
                              trailingWidget: SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
                              onTap: () => Get.toNamed('${BoardPage.route}/${GlobalFunction.encodeUrl('인기 게시글')}?type=${controller.barIndex}'),
                            );
                          }
                          if (index == 1) return buildPopularPosts(); // 인기 게시글
                          if (index == 2) {
                            return titleBar(
                              title: '최신 게시글',
                              trailingWidget: switchWidget(),
                            );
                          }

                          final Post post = postList[index - 3];

                          if (GlobalData.blockedUserIDList.contains(post.userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우

                          return PostCard(
                            post: post,
                            onTap: () => Get.toNamed('${CommunityDetailPage.route}/${post.id}')!.then((value) {
                              GlobalFunction.syncPost();
                              if (!kIsWeb) {
                                final String categoryText = controller.isAllView ? '' : GlobalFunction.stringListToString(controller.filteredCategoryList);
                                final String tagText = controller.isAllView ? '' : GlobalFunction.stringListToString(controller.filteredTagList);
                                int lastID = 0;

                                if (controller.postList.isNotEmpty) {
                                  for (var i = 0; i < controller.postList.length; ++i) {
                                    if (!controller.postList[i].isHot) {
                                      lastID = controller.postList[i].id;
                                      break;
                                    }
                                  }
                                }

                                ApiProvider().post(
                                    '/Community/Check/NeedNewPost',
                                    jsonEncode({
                                      "userID": GlobalData.loginUser.id,
                                      "type": controller.isJob == true ? 1 : 0,
                                      "needAll": controller.isAllView == false ? 0 : 1,
                                      "categoryList": categoryText,
                                      "tagList": tagText,
                                      "lastID": lastID
                                    }));
                              }
                            }), // 게시글 동기화
                          );
                        },
                        childCount: postList.length + 3,
                      ))
              ],
            ),
          );
        });
  }

  Container titleBar({required String title, Widget? trailingWidget, GestureTapCallback? onTap}) {
    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: STextStyle.subTitle1(),
            ),
            if (trailingWidget != null) trailingWidget,
          ],
        ),
      ),
    );
  }

  Widget switchWidget() {
    return InkWell(
      onTap: () => controller.hotSwitch(),
      child: Stack(
        children: [
          AnimatedPositioned(
            right: controller.isHot ? 0 : 32 * sizeUnit,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: controller.isHot ? 34 * sizeUnit : 36 * sizeUnit,
              height: 20 * sizeUnit,
              decoration: BoxDecoration(
                color: nolColorOrange,
                borderRadius: BorderRadius.circular(18 * sizeUnit),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4 * sizeUnit),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18 * sizeUnit),
              border: Border.all(color: nolColorOrange),
            ),
            width: 68 * sizeUnit,
            height: 20 * sizeUnit,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('NEW', style: STextStyle.subTitle4().copyWith(color: controller.isHot ? nolColorOrange : Colors.white, height: 1.2)),
                Text('HOT', style: STextStyle.subTitle4().copyWith(color: controller.isHot ? Colors.white : nolColorOrange, height: 1.2)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSize? dashboardAppBar(BuildContext context) {
    return customAppBar(
      context,
      controller: controller.scrollController,
      showAppBar: Responsive.isMobile(context),
      leadingWidth: double.infinity,
      leading: Row(
        children: [
          SizedBox(width: 16 * sizeUnit),
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
      titleWidget: SvgPicture.asset(
        GlobalAssets.svgLogo,
        width: 34 * sizeUnit,
      ),
      centerTitle: true,
      actions: actions(),
    );
  }

  static List<Widget> actions() {
    final CommunityController controller = Get.find<CommunityController>();

    return [
      Center(
        child: InkWell(
          onTap: () {
            final List<String> originInterestList = [...controller.interestList]; // 관심목록 리스트 저장
            Get.to(() => SearchPage(postType: controller.isJob ? Post.postTypeJob : Post.postTypeTopic))!.then((value) => controller.afterInterestRegister(originInterestList));
          },
          child: SvgPicture.asset(
            GlobalAssets.svgSearch,
            width: 24 * sizeUnit,
          ),
        ),
      ),
      SizedBox(width: 19 * sizeUnit),
      Center(
        child: InkWell(
          onTap: () => controller.allToggle(),
          child: Text(
            'ALL',
            style: STextStyle.subTitle1().copyWith(color: controller.isAllView ? nolColorOrange : nolColorGrey),
          ),
        ),
      ),
      SizedBox(width: 16 * sizeUnit),
    ];
  }

  // 인기 게시글
  Widget buildPopularPosts() {
    return Padding(
      padding: EdgeInsets.only(bottom: controller.popularPostList.isEmpty ? 0 : 16 * sizeUnit),
      child: Column(
        children: List.generate(controller.popularPostList.length, (index) {
          final Post post = controller.popularPostList[index];

          if (GlobalData.blockedUserIDList.contains(post.userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우
          return simplePostCard(post);
        }),
      ),
    );
  }

  Widget simplePostCard(Post post) {
    return InkWell(
      onTap: () => Get.toNamed('${CommunityDetailPage.route}/${post.id}')!.then((value) => GlobalFunction.syncPost()), // 게시글 동기화,
      child: Container(
        height: 32 * sizeUnit,
        padding: EdgeInsets.only(left: 32 * sizeUnit, right: 24 * sizeUnit),
        child: Row(
          children: [
            Expanded(
              child: Text(
                post.title,
                style: STextStyle.body3(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconAndCount(
              iconPath: post.isLike ? GlobalAssets.svgBigLikeActive : GlobalAssets.svgBigLike,
              count: post.likesLength,
            ),
            SizedBox(width: 10 * sizeUnit),
            IconAndCount(
              iconPath: post.isWriteReply ? GlobalAssets.svgReplyActive : GlobalAssets.svgReply,
              count: post.repliesLength,
            ),
          ],
        ),
      ),
    );
  }

  // 관심 목록
  Widget buildInterests(BuildContext context) {
    final ItemScrollController itemScrollController = ItemScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) => controller.setInterestListScroll(itemScrollController)); // 관심목록 스크롤 컨트롤

    Widget plusButton() {
      if (controller.interestList.isEmpty) {
        return nolChips(
          text: '관심등록',
          bgColor: nolColorOrange,
          fontColor: Colors.white,
          onTap: () => GlobalFunction.loginCheck(
            callback: () {
              final List<String> originInterestList = [...controller.interestList]; // 관심목록 리스트 저장
              Get.to(() => InterestRegisterPage(isJob: controller.isJob))!.then((value) => controller.afterInterestRegister(originInterestList));
            },
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.only(right: 16 * sizeUnit),
        child: InkWell(
          onTap: () {
            final List<String> originInterestList = [...controller.interestList]; // 관심목록 리스트 저장
            Get.to(() => InterestRegisterPage(isJob: controller.isJob))!.then((value) => controller.afterInterestRegister(originInterestList));
          },
          child: SvgPicture.asset(GlobalAssets.svgPlusInCircle, width: 24 * sizeUnit),
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: nolColorLightGrey))),
      padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
      child: ScrollablePositionedList.builder(
        physics: const ClampingScrollPhysics(),
        itemScrollController: itemScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: controller.interestList.length + 1,
        itemBuilder: (context, index) {
          if (index == controller.interestList.length) {
            return Padding(
              padding: EdgeInsets.only(left: controller.interestList.isEmpty ? 16 * sizeUnit : 0),
              child: plusButton(),
            );
          }

          final String interest = controller.interestList[index];
          final bool isActive = controller.isJob ? interest == controller.selectedInterestForJob : interest == controller.selectedInterestForTopic;

          return Padding(
            padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
            child: nolChips(
              text: interest,
              bgColor: controller.isAllView
                  ? Colors.white
                  : isActive
                      ? nolColorOrange
                      : Colors.white,
              fontColor: controller.isAllView
                  ? nolColorGrey
                  : isActive
                      ? Colors.white
                      : nolColorOrange,
              borderColor: controller.isAllView ? nolColorGrey : nolColorOrange,
              onTap: controller.isAllView ? () {} : () => controller.interestTapFunc(interest),
            ),
          );
        },
      ),
    );
  }
}
