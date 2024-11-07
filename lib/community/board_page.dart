import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/componets/post_card.dart';
import 'package:nolilteo/community/controllers/board_controller.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';

import '../data/global_data.dart';
import '../home/controllers/main_page_controller.dart';
import '../home/main_page.dart';
import '../wbti/model/wbti_type.dart';
import 'community_detail_page.dart';
import 'models/post.dart';
import '../config/s_text_style.dart';

class BoardPage extends StatelessWidget {
  BoardPage({Key? key}) : super(key: key);
  static const String route = '/board';

  final BoardController controller = Get.put(BoardController(tag: GlobalData.boardPageCount.toString()), tag: GlobalData.boardPageCount.toString());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BoardController>(
        initState: (_) => controller.fetchData(),
        tag: controller.tag,
        builder: (_) {
          if (controller.fetchLoading) return const Material(color: Colors.white, child: Center(child: CircularProgressIndicator(color: nolColorOrange)));
          final String selectedCategory = controller.type == Post.postTypeWbti && controller.category[0] != '#' && controller.category != '인기 게시글' ? WbtiType.getType(controller.category).name : controller.category;

          return BaseWidget(
            showSideSection: true,
            selectedCategory: selectedCategory,
            child: Scaffold(
              appBar: customAppBar(
                context,
                titleWidget: Row(
                  children: [
                    Text(
                      selectedCategory,
                      style: STextStyle.appBar().copyWith(height: 3 / 2),
                    ),
                    if (controller.tagInfo != null) ...[
                      SizedBox(width: 4 * sizeUnit),
                      Text(
                        controller.tagInfo!,
                        style: STextStyle.highlight2().copyWith(color: nolColorGrey, height: 1.9),
                      ),
                    ],
                    if (Responsive.isMobile(context) && GlobalData.boardPageCount > 1) ...[
                      const Spacer(),
                      Padding(
                        padding: EdgeInsets.only(right: 24 * sizeUnit),
                        child: Center(
                          child: InkWell(
                            onTap: () {
                              GlobalFunction.goToMainPage(); // 메인 페이지로 이동
                              MainPageController.to.changePage(0);
                            },
                            child: SvgPicture.asset(
                              GlobalAssets.svgHomeOutline,
                              width: 24 * sizeUnit,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                actions: controller.isShowInterest
                    ? [
                        Padding(
                          padding: EdgeInsets.only(right: 16 * sizeUnit),
                          child: Center(
                            child: InkWell(
                              onTap: () => controller.interestToggle(),
                              child: Obx(() => SvgPicture.asset(
                                    controller.isInterest.value ? GlobalAssets.svgAddActive : GlobalAssets.svgAdd,
                                    width: 24 * sizeUnit,
                                  )),
                            ),
                          ),
                        ),
                      ]
                    : null,
              ),
              body: Column(
                children: [
                  buildLine(),
                  if (controller.interestList != null) buildInterests(), // 관심 목록
                  SizedBox(height: 16 * sizeUnit),
                  Expanded(
                    child: controller.postList.isEmpty
                        ? noSearchResultWidget('검색 결과가 없어요')
                        : customRefreshIndicator(
                            onRefresh: controller.onRefresh,
                            child: ListView.builder(
                              controller: controller.scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.postList.length,
                              itemBuilder: (context, index) {
                                final Post post = controller.postList[index];
                                final MeetingPost? meetingPost = controller.isMeeting ? controller.postList[index] as MeetingPost : null;

                                return PostCard(
                                  post: post,
                                  meetingPost: meetingPost,
                                  onTap: () {
                                    Get.toNamed('${controller.isMeeting ? CommunityDetailPage.meetingRoute : CommunityDetailPage.route}/${post.id}')!
                                        .then((value) => GlobalFunction.syncPost()); // 게시글 동기화
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
          );
        });
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
              controller.interestList!.length,
              (index) {
                final String interest = controller.interestList![index];

                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
                  child: nolChips(
                    text: interest,
                  ),
                );
              },
            ),
          )),
    );
  }
}
