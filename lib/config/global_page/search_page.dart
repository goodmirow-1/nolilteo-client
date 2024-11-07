import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/board_page.dart';
import 'package:nolilteo/community/interest_register_page.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_page/controllers/search_controller.dart' as MySearchController;
import 'package:nolilteo/config/global_widgets/animated_tap_bar.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/global_widgets/search_text_field.dart';
import 'package:nolilteo/config/s_text_style.dart';
import 'package:nolilteo/data/tag_preview.dart';
import 'package:nolilteo/meeting/model/meeting_post.dart';

import '../../community/community_detail_page.dart';
import '../../community/componets/post_card.dart';
import '../../community/models/post.dart';
import '../../data/global_data.dart';

// ignore: must_be_immutable
class SearchPage extends StatelessWidget {
  SearchPage({Key? key, required this.postType}) : super(key: key);

  final int postType;

  final MySearchController.SearchController controller = Get.put(MySearchController.SearchController());
  bool initialize = false;

  List<Widget> recommendKeywordList = [];
  final int maxHotListCnt = 10;

  @override
  Widget build(BuildContext context) {
    if (!initialize) {
      initialize = true;
      
      if(GlobalData.hotListByHour.isNotEmpty){
        for(var i = 0 ; i < GlobalData.hotListByHour.length ; ++i){
          if(i == maxHotListCnt) break;
          if(GlobalData.hotListByHour[i].tag.isNotEmpty){
            recommendKeywordList.add(
              nolChips(
                text: GlobalData.hotListByHour[i].tag,
                onTap: () {
                  var tag = GlobalData.hotListByHour[i].tag;
                  controller.textEditingController.text = tag;
                  controller.query(tag);
                  controller.searchFunc();
                },
              ),
            );
          }
        }
      }
      controller.postType = postType;
    }

    return BaseWidget(
      child: Scaffold(
        body: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => GlobalFunction.unFocus(context),
          child: Column(
            children: [
              buildAppBarAndTextFiled(), // 앱바, 텍스트필드
              buildLine(),
              Expanded(
                child: GetBuilder<MySearchController.SearchController>(
                  builder: (_) {
                    if (!controller.loading && controller.titleSearchList == null && controller.tagSearchList == null) {
                      if (recommendKeywordList.isEmpty) {
                        return noSearchResultWidget('검색어를 입력해 주세요');
                      } else {
                        return buildRecommendKeywordList();
                      }
                    }

                    return Column(
                      children: [
                        AnimatedTapBar(
                          barIndex: controller.barIndex,
                          listTabItemTitle: controller.pageTitleList,
                          listTabItemWidth: controller.pageTitleWidthList,
                          onPageChanged: (index) {
                            if (controller.scrollController.hasClients) controller.scrollController.jumpTo(0.1);
                            controller.pageChange(index);
                          },
                        ),
                        buildLine(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: controller.isTitle ? 16 * sizeUnit : 0),
                            child: PageView(
                              controller: controller.pageController,
                              onPageChanged: (index) => controller.pageChange(index, isSnapChange: true),
                              children: [
                                titleListView(), // 제목 검색 결과 리스트
                                tagListView(), // 태그 검색 결과 리스트
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRecommendKeywordList() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16 * sizeUnit, 24 * sizeUnit, 16 * sizeUnit, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추천 검색어',
            style: STextStyle.subTitle1(),
          ),
          SizedBox(
            height: 16 * sizeUnit,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              runSpacing: 8 * sizeUnit,
              spacing: 10 * sizeUnit,
              children: recommendKeywordList,
            ),
          ),
        ],
      ),
    );
  }

  // 제목 검색 결과 리스트
  Widget titleListView() {
    if (controller.loading || controller.titleSearchList == null) {
      return const Center(child: CircularProgressIndicator(color: nolColorOrange));
    } else {
      return controller.titleSearchList!.isEmpty
          ? noSearchResultWidget('"${controller.query}"\n에 해당하는 게시글이 없어요')
          : ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.titleSearchList!.length,
              itemBuilder: (context, index) {
                final Post post = controller.titleSearchList![index];
                final MeetingPost? meetingPost = postType != Post.postTypeMeeting ? null : controller.titleSearchList![index] as MeetingPost;

                if (GlobalData.blockedUserIDList.contains(post.userID)) return const SizedBox.shrink(); // 차단한 사용자인 경우

                return PostCard(
                  post: post,
                  meetingPost: meetingPost,
                  onTap: () => Get.toNamed('${postType != Post.postTypeMeeting ? CommunityDetailPage.route : CommunityDetailPage.meetingRoute}/${post.id}')!
                      .then((value) => GlobalFunction.syncPost()), // 게시글 동기화
                );
              },
            );
    }
  }

  // 태그 검색 결과 리스트
  Widget tagListView() {
    if (controller.loading || controller.tagSearchList == null) {
      return const Center(child: CircularProgressIndicator(color: nolColorOrange));
    } else {
      return controller.tagSearchList!.isEmpty
          ? noSearchResultWidget('"${controller.query}"\n에 해당하는 게시글이 없어요')
          : ListView.builder(
              controller: controller.scrollController,
              itemCount: controller.tagSearchList!.length,
              itemBuilder: (context, index) {
                final TagPreview tagPreview = controller.tagSearchList![index];

                return tagPreviewItem(
                  controller.tagSearchList![index],
                  trailingWidget: SvgPicture.asset(
                    GlobalAssets.svgArrowRight,
                    width: 24 * sizeUnit,
                  ),
                  onTap: () => Get.toNamed('${BoardPage.route}/${GlobalFunction.encodeUrl('#${tagPreview.tag}')}?type=${tagPreview.postType}'),
                );
              },
            );
    }
  }

  // 앱바, 텍스트필드
  Container buildAppBarAndTextFiled() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 8 * sizeUnit),
      width: double.infinity,
      height: 56 * sizeUnit,
      child: Row(
        children: [
          InkWell(
            onTap: () => Get.back(),
            child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
          ),
          Expanded(
            child: SearchTextField(
              controller: controller.textEditingController,
              focusNode: controller.focusNode,
              onChanged: (value) => controller.query(value),
              onSubmitted: (value) => controller.searchFunc(),
              autofocus: true,
              hintText: '검색',
              suffixIcon: Obx(
                () => controller.query.isEmpty || !controller.hasFocus.value
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () {
                          controller.clearQuery();
                          controller.clearList();
                        },
                        child: SizedBox(
                          width: 20 * sizeUnit,
                          height: 20 * sizeUnit,
                          child: Center(
                            child: SvgPicture.asset(GlobalAssets.svgCancelInCircle, width: 20 * sizeUnit),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
