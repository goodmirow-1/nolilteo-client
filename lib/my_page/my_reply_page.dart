import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/models/reply.dart';
import 'package:nolilteo/my_page/controller/my_reply_controller.dart';

import '../community/community_reply_page.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_widgets/animated_tap_bar.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';

class MyReplyPage extends StatefulWidget {
  const MyReplyPage({Key? key}) : super(key: key);

  @override
  State<MyReplyPage> createState() => _MyReplyPageState();
}

class _MyReplyPageState extends State<MyReplyPage> {
  final MyReplyController controller = Get.put(MyReplyController());
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // 페이지 세팅
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.pageController.hasClients) controller.pageController.jumpToPage(controller.barIndex);
    });
    scrollController.addListener(() => controller.maxScrollEvent(scrollController));
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GetBuilder<MyReplyController>(
          id: 'fetchData',
          initState: (_) => controller.fetchData(),
          builder: (_) {
            if (controller.fetchLoading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

            return Scaffold(
              appBar: customAppBar(context, title: '내 댓글',centerTitle: false),
              body: GetBuilder<MyReplyController>(builder: (_) {
                return Column(
                  children: [
                    buildLine(),
                    AnimatedTapBar(
                      barIndex: controller.barIndex,
                      listTabItemTitle: controller.titleList,
                      listTabItemWidth: controller.titleWidthList,
                      onPageChanged: (index) {
                        if (scrollController.hasClients) scrollController.jumpTo(0.1);
                        if (controller.pageController.hasClients) controller.pageController.animateToPage(index, duration: AnimatedTapBar.duration, curve: AnimatedTapBar.curve);
                      },
                    ),
                    buildLine(),
                    SizedBox(
                      height: 10 * sizeUnit,
                    ),
                    Expanded(child: buildPageView()),
                  ],
                );
              }),
            );
          }),
    );
  }

  PageView buildPageView() {
    return PageView.builder(
        controller: controller.pageController,
        itemCount: controller.titleList.length,
        onPageChanged: (index) => controller.pageChange(index),
        itemBuilder: (context, index) {
          return customRefreshIndicator(
            onRefresh: controller.onRefresh,
            child: ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: controller.barIndex == MyReplyController.replyIndex ? controller.replyList.length : controller.replyReplyList.length,
                itemBuilder: (context, index) {
                  if (controller.barIndex == MyReplyController.replyIndex) {
                    return myReplyItem(controller.replyList[index]);
                  } else {
                    return myReplyReplyItem(controller.replyReplyList[index]);
                  }
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(
                      thickness: 1,
                    )),
          );
        });
  }

  Widget myReplyItem(Reply item) {
    RxBool isLike = item.isLike.obs;

    return InkWell(
      onTap: () => Get.to(() => CommunityReplyPage(replyID: item.id)),
      child: Container(
        margin: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 16 * sizeUnit, 0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                nolTag("원문"),
                SizedBox(
                  width: 8 * sizeUnit,
                ),
                Expanded(
                  child: Text(
                    item.parentsTitle,
                    style: STextStyle.body4(),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    textAlign: TextAlign.start,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 8 * sizeUnit,
            ),
            Text(
              item.contents,
              style: STextStyle.body3(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
            SizedBox(
              height: 12 * sizeUnit,
            ),
            Row(
              children: [
                Obx(() => IconAndCount(
                      iconPath: isLike.value ? GlobalAssets.svgLikeActive : GlobalAssets.svgLike,
                      count: item.likesLength,
                    )),
                SizedBox(width: 16 * sizeUnit),
                if (item.replyReplyList.isNotEmpty) ...[Text('+답글 ${item.replyReplyList.length}개', style: STextStyle.body5().copyWith(color: nolColorOrange))]
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget myReplyReplyItem(ReplyReply item) {
    return InkWell(
      onTap: () => Get.to(() => CommunityReplyPage(replyID: item.parentsID)),
      child: Container(
        margin: EdgeInsets.fromLTRB(16 * sizeUnit, 8 * sizeUnit, 16 * sizeUnit, 0),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              nolTag('원댓글'),
              SizedBox(
                width: 8 * sizeUnit,
              ),
              Expanded(
                child: Text(
                  item.parentsTitle,
                  style: STextStyle.body4(),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.start,
                ),
              ),
            ]),
            SizedBox(
              height: 8 * sizeUnit,
            ),
            Text(
              item.contents,
              style: STextStyle.body3(),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
              textAlign: TextAlign.start,
            ),
          ],
        ),
      ),
    );
  }
}
