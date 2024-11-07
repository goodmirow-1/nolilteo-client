import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/models/post.dart';
import 'package:nolilteo/config/analytics.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_page/tag_search_page.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';

// ignore: must_be_immutable
class InterestRegisterPage extends StatelessWidget {
  InterestRegisterPage({Key? key, required this.isJob}) : super(key: key);

  final bool isJob;

  final InterestRegisterController controller = Get.put(InterestRegisterController());
  bool initialize = false;

  @override
  Widget build(BuildContext context) {
    if (!initialize) {
      initialize = true;
      controller.setData(isJob); // 데이터 세팅
    }

    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, 
          titleWidget: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${isJob ? '일터' : '놀터'} 관심 등록', style: STextStyle.appBar()),
              SizedBox(width: 4 * sizeUnit),
              Text('최대 10개', style: STextStyle.highlight2().copyWith(color: nolColorGrey)),
            ],
          ),
          leadingWidth: Responsive.isMobile(context) ? null : 48 * sizeUnit,
          leading: InkWell(
            onTap: () => Get.back(),
            child: Center(
              child: SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit),
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              buildLine(),
              buildInterests(), // 관심 목록
              SizedBox(height: 24 * sizeUnit),
              Text('메인 카테고리', style: STextStyle.highlight2()),
              SizedBox(height: 16 * sizeUnit),
              categoryWrap(),
              SizedBox(height: 24 * sizeUnit),
              Text('#', style: STextStyle.highlight2()),
              SizedBox(height: 16 * sizeUnit),
              Obx(() => tagWrap()),
              SizedBox(height: 24 * sizeUnit),
            ],
          ),
        ),
      ),
    );
  }

  Widget categoryWrap() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Obx(() => Wrap(
            spacing: 8 * sizeUnit,
            runSpacing: 8 * sizeUnit,
            alignment: WrapAlignment.center,
            children: List.generate(
              controller.categoryList.length,
              (index) {
                final String category = controller.categoryList[index];
                bool isActive = controller.interestList.contains(category);
                final Color activeColor = isActive ? nolColorOrange : nolColorGrey;

                return nolChips(
                  text: category,
                  bgColor: activeColor,
                  borderColor: activeColor,
                  fontColor: Colors.white,
                  onTap: () => controller.categoryToggle(category),
                );
              },
            ),
          )),
    );
  }

  Widget tagWrap() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
      child: Wrap(
        spacing: 8 * sizeUnit,
        runSpacing: 8 * sizeUnit,
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: List.generate(
          controller.tmpTagInterestList.length + 1,
          (index) {
            if (index == controller.tmpTagInterestList.length) {
              return InkWell(
                onTap: () => Get.to(() => TagSearchPage(postType: isJob ? Post.postTypeJob : Post.postTypeTopic))!.then((value) {
                  if(value != null) {
                    controller.tagToggle(tag: value, isContain: false);
                  }
                }),
                borderRadius: BorderRadius.circular(12 * sizeUnit),
                child: SvgPicture.asset(GlobalAssets.svgPlusInCircle, width: 24 * sizeUnit),
              );
            }

            final String tag = controller.tmpTagInterestList[index];
            final bool isContain = controller.tagInterestList.contains(tag);
            final Color activeColor = isContain ? nolColorOrange : nolColorGrey;

            return nolChips(
              text: tag,
              bgColor: activeColor,
              borderColor: activeColor,
              fontColor: Colors.white,
              onTap: () => controller.tagToggle(tag: tag, isContain: isContain),
            );
          },
        ),
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
        controller: controller.scrollController,
        scrollDirection: Axis.horizontal,
        child: Obx(() => Row(
              children: List.generate(
                controller.interestList.length + controller.tagInterestList.length,
                (index) {
                  final String interest = index < controller.interestList.length ? controller.interestList[index] : controller.tagInterestList[index - controller.interestList.length];

                  return Padding(
                    padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
                    child: nolChips(
                      text: interest,
                      bgColor: Colors.white,
                      fontColor: nolColorOrange,
                      cancelFunc: () => index < controller.interestList.length ? controller.categoryToggle(interest) : controller.tagToggle(tag: interest, isContain: true),
                    ),
                  );
                },
              ),
            )),
      ),
    );
  }
}

class InterestRegisterController extends GetxController {
  static get to => Get.find<InterestRegisterController>();

  final ScrollController scrollController = ScrollController();
  late final bool isJob;
  late final List<String> categoryList;
  RxList<String> interestList = <String>[].obs;
  RxList<String> tagInterestList = <String>[].obs;
  RxList<String> tmpTagInterestList = <String>[].obs;

  @override
  void onClose(){
    super.onClose();

    scrollController.dispose();
  }

  // 데이터 세팅
  void setData(bool isJob) {
    this.isJob = isJob;

    if (isJob) {
      interestList(GlobalData.interestJobList);
      tagInterestList(GlobalData.interestJobTagList);
      tmpTagInterestList(GlobalData.tmpInterestJobTagList);
      categoryList = jobCategoryList;
    } else {
      interestList(GlobalData.interestTopicList);
      tagInterestList(GlobalData.interestTopicTagList);
      tmpTagInterestList(GlobalData.tmpInterestTopicTagList);
      categoryList = topicCategoryList;
    }
  }

  // 카테고리 토글
  void categoryToggle(String interest) async {
    final bool isContain = interestList.contains(interest);

    if (isContain) {
      interestList.removeWhere((element) => element == interest);
    } else {
      if (interestList.length + tagInterestList.length >= interestMaxNum) {
        GlobalFunction.showToast(msg: '관심 등록은 최대 $interestMaxNum개 까지만 가능해요');
      } else {
        interestList.add(interest);
        WidgetsBinding.instance.addPostFrameCallback((_) => setMaxScroll()); // 스크롤 맨 뒤로
        NolAnalytics.logEvent(name: 'interest_add', parameters: {'category': interest, 'type': isJob ? Post.postTypeJob : Post.postTypeTopic}); // 애널리틱스 관심등록
      }
    }

    // 로컬 세팅
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(isJob ? 'interestJobList' : 'interestTopicList', interestList);
    final bool isAllView = interestList.isEmpty && tagInterestList.isEmpty;
    await prefs.setBool(isJob ? 'jobAllView' : 'topicAllView', isAllView);
  }

  // 태그 토글
  void tagToggle({required String tag, required bool isContain}) async{
    if (isContain) {
      tagInterestList.removeWhere((element) => element == tag);
    } else {
      if (interestList.length + tagInterestList.length >= interestMaxNum) {
        GlobalFunction.showToast(msg: '관심 등록은 최대 $interestMaxNum개 까지만 가능해요');
      } else {
        tagInterestList.add(tag);
        WidgetsBinding.instance.addPostFrameCallback((_) => setMaxScroll()); // 스크롤 맨 뒤로
        NolAnalytics.logEvent(name: 'interest_add', parameters: {'tag': tag, 'type': isJob ? Post.postTypeJob : Post.postTypeTopic}); // 애널리틱스 관심 등록
      }
    }

    // 로컬 세팅
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(isJob ? 'interestJobTagList' : 'interestTopicTagList', tagInterestList);
    final bool isAllView = interestList.isEmpty && tagInterestList.isEmpty;
    await prefs.setBool(isJob ? 'jobAllView' : 'topicAllView', isAllView);
  }

  // 관심 등록 스크롤 마지막으로
  void setMaxScroll(){
    if(scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
