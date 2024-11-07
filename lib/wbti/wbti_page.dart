import 'package:badges/badges.dart' as MyBadge;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/board_page.dart';
import 'package:nolilteo/config/global_page/search_page.dart';
import 'package:nolilteo/home/main_page.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';
import 'package:nolilteo/wbti/wbti_just_result_page.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../community/community_detail_page.dart';
import '../../community/models/post.dart';
import '../../config/global_function.dart';
import '../../config/global_widgets/base_widget.dart';
import '../../config/global_widgets/global_widget.dart';
import '../../data/global_data.dart';

import '../community/componets/post_card.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/responsive.dart';
import '../config/s_text_style.dart';
import '../notification/controller/notification_controller.dart';
import '../notification/notification_page.dart';
import 'controller/wbti_controller.dart';
import 'wbti_selection_page.dart';

class WbtiPage extends StatelessWidget {
  WbtiPage({Key? key}) : super(key: key);

  final WbtiController controller = Get.find<WbtiController>();
  final NotificationController notificationController = Get.find<NotificationController>();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WbtiController>(
        initState: (_) => controller.fetchData(),
        builder: (_) {
          if (controller.selectedWbti.type.isEmpty) return WbtiSelectionPage(); // 선택한 wbti 없으면 선택 페이지로

          return BaseWidget(
            showSideSection: true,
            webActions: actions(),
            selectedCategory: controller.selectedWbti.name,
            child: Scaffold(
              appBar: wbtiAppBar(context),
              body: Column(
                children: [
                  buildLine(),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        buildPostListView(context),
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

  Widget buildPostListView(BuildContext context) {
    final List<Post> postList = controller.isHot ? controller.hotList : controller.postList;

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
            expandedHeight: 86 * sizeUnit,
            flexibleSpace: buildWbtiCharacters(),
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
                        onTap: () => Get.toNamed('${BoardPage.route}/${GlobalFunction.encodeUrl('인기 게시글')}?type=${Post.postTypeWbti}'),
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
                      onTap: () => Get.toNamed('${CommunityDetailPage.route}/${post.id}')!.then((value) => GlobalFunction.syncPost()), // 게시글 동기화
                    );
                  },
                  childCount: postList.length + 3,
                ))
        ],
      ),
    );
  }

  // wbti 캐릭터 리스트
  Widget buildWbtiCharacters() {
    Widget wbtiCharacterWidget(WbtiType wbtiType) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8 * sizeUnit),
        child: InkWell(
          onTap: () => controller.changeWbti(wbtiType),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          child: Container(
            padding: wbtiType == WbtiType.esfj ? EdgeInsets.only(left: 4 * sizeUnit) : null,
            width: 76 * sizeUnit,
            height: 70 * sizeUnit,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: controller.selectedWbti == wbtiType ? nolColorOrange : Colors.white,
              border: Border.all(color: nolColorOrange, width: 2 * sizeUnit),
              borderRadius: BorderRadius.circular(14 * sizeUnit),
            ),
            child: SvgPicture.asset(wbtiType.src, height: 60 * sizeUnit),
          ),
        ),
      );
    }

    return ScrollablePositionedList.builder(
      physics: const ClampingScrollPhysics(),
      itemScrollController: controller.itemScrollController,
      scrollDirection: Axis.horizontal,
      itemCount: GlobalData.customWbtiList.length,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: index == GlobalData.customWbtiList.length - 1 ? 16 * sizeUnit : 8 * sizeUnit),
        child: wbtiCharacterWidget(GlobalData.customWbtiList[index]),
      ),
    );
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

  PreferredSize? wbtiAppBar(BuildContext context) {
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
      title: 'WBTI',
      centerTitle: true,
      actions: actions(),
    );
  }

  List<Widget> actions() {
    return [
      Center(
        child: InkWell(
          onTap: () => Get.to(() => SearchPage(postType: Post.postTypeWbti)),
          child: SvgPicture.asset(
            GlobalAssets.svgSearch,
            width: 24 * sizeUnit,
          ),
        ),
      ),
      SizedBox(width: 19 * sizeUnit),
      Center(
        child: InkWell(
          onTap: () => Get.to(() => WbtiJustResultPage(wbti: controller.selectedWbti)),
          child: Text(
            'Info',
            style: STextStyle.subTitle1().copyWith(color: nolColorOrange),
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
}
