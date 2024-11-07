import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/interest_register_page.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/global_widgets/search_text_field.dart';
import 'package:nolilteo/data/tag_preview.dart';
import '../../community/models/post.dart';
import '../../data/global_data.dart';
import 'controllers/tag_search_controller.dart';

// ignore: must_be_immutable
class TagSearchPage extends StatelessWidget {
  TagSearchPage({Key? key, required this.postType}) : super(key: key);

  final int postType;

  final TagSearchController controller = Get.put(TagSearchController());
  final InterestRegisterController interestRegisterController = Get.find<InterestRegisterController>();
  bool initialize = false;

  @override
  Widget build(BuildContext context) {
    if (!initialize) {
      initialize = true;
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
                child: GetBuilder<TagSearchController>(
                  builder: (_) {
                    if (interestRegisterController.tmpTagInterestList.isNotEmpty && controller.tagSearchList == null) {
                      return Column(
                        children: [
                          SizedBox(height: 16 * sizeUnit),
                          Expanded(
                            child: Wrap(
                              spacing: 8 * sizeUnit,
                              runSpacing: 8 * sizeUnit,
                              children: List.generate(interestRegisterController.tmpTagInterestList.length, (index) {
                                final String tag = interestRegisterController.tmpTagInterestList[index];

                                return nolChips(
                                  text: tag,
                                  cancelFunc: () {
                                    interestRegisterController.tmpTagInterestList.remove(tag);
                                    interestRegisterController.tagInterestList.remove(tag);
                                    controller.update();
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      );
                    }

                    if (!controller.loading && controller.tagSearchList == null) return noSearchResultWidget('검색어를 입력해 주세요');

                    return Column(
                      children: [
                        buildLine(),
                        Expanded(child: tagListView()),
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

  // 태그 검색 결과 리스트
  Widget tagListView() {
    if (controller.loading || controller.tagSearchList == null) {
      return const Center(child: CircularProgressIndicator(color: nolColorOrange));
    } else {
      return controller.tagSearchList!.isEmpty
          ? noSearchResultWidget('"${controller.query}"\n에 해당하는 게시글이 없어요')
          : ListView.builder(
              itemCount: controller.tagSearchList!.length,
              itemBuilder: (context, index) {
                final TagPreview tagPreview = controller.tagSearchList![index];
                List<String> tagInterestList = tagPreview.postType == Post.postTypeTopic
                    ? [...GlobalData.interestTopicTagList, ...interestRegisterController.tmpTagInterestList]
                    : [...GlobalData.interestJobTagList, ...interestRegisterController.tmpTagInterestList];

                final bool isContain = tagInterestList.contains('#${tagPreview.tag}');

                return tagPreviewItem(
                  controller.tagSearchList![index],
                  trailingWidget: SvgPicture.asset(
                    isContain ? GlobalAssets.svgPlusInCircleGrey : GlobalAssets.svgPlusInCircle,
                    width: 24 * sizeUnit,
                  ),
                  onTap: () {
                    if (!isContain) controller.tagRegisterInterest(tagPreview.tag, isContain);
                  },
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
              hintText: postType == Post.postTypeTopic
                  ? '놀터'
                  : postType == Post.postTypeJob
                      ? '일터'
                      : '모여라',
              suffixIcon: Obx(
                () => controller.query.isEmpty || !controller.hasFocus.value
                    ? const SizedBox.shrink()
                    : InkWell(
                        onTap: () => controller.clearQuery(),
                        splashColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        focusColor: Colors.transparent,
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
