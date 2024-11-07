import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/data/global_data.dart';
import '../config/s_text_style.dart';

// ignore: must_be_immutable
class CategorySelectionPage extends StatelessWidget {
  CategorySelectionPage({Key? key, required this.categoryType}) : super(key: key);

  final int categoryType;

  static const categoryTypeTopic = 0; // 놀터
  static const categoryTypeJob = 1; // 일터
  static const categoryTypeAll = 2; // 전체

  final CategorySelectionController controller = Get.put(CategorySelectionController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GetBuilder<CategorySelectionController>(
          initState: (_) => controller.init(categoryType),
          builder: (_) {
            return Scaffold(
              appBar: buildAppBar(context),
              body: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
                  child: Column(
                    children: [
                      buildLine(),
                      SizedBox(height: 24 * sizeUnit),
                      buildTitle('관심 카테고리'),
                      SizedBox(height: 16 * sizeUnit),
                      Wrap(
                        runSpacing: 4 * sizeUnit,
                        spacing: 4 * sizeUnit,
                        alignment: WrapAlignment.center,
                        children: List.generate(
                          controller.interestList.length,
                          (index) {
                            final String category = controller.interestList[index];

                            return nolChips(
                              text: category,
                              bgColor: controller.selectedCategory == category ? nolColorOrange : Colors.white,
                              fontColor: controller.selectedCategory == category ? Colors.white : nolColorOrange,
                              onTap: () => controller.categorySelect(category),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 24 * sizeUnit),
                      if (categoryType != CategorySelectionPage.categoryTypeAll) ...[
                        buildTitle('메인 카테고리'),
                        SizedBox(height: 16 * sizeUnit),
                        categoryWrap(controller.categoryList),
                      ] else ...[
                        buildTitle('놀터'),
                        SizedBox(height: 16 * sizeUnit),
                        categoryWrap(topicCategoryList),
                        SizedBox(height: 24 * sizeUnit),
                        buildTitle('일터'),
                        SizedBox(height: 16 * sizeUnit),
                        categoryWrap(jobCategoryList),
                      ],
                      SizedBox(height: 24 * sizeUnit),
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }

  Wrap categoryWrap(List<String> categoryList) {
    return Wrap(
      runSpacing: 4 * sizeUnit,
      spacing: 4 * sizeUnit,
      alignment: WrapAlignment.center,
      children: List.generate(
        categoryList.length,
        (index) {
          final String category = categoryList[index];

          return nolChips(
            text: category,
            bgColor: controller.selectedCategory == category ? nolColorOrange : nolColorGrey,
            fontColor: Colors.white,
            borderColor: controller.selectedCategory == category ? nolColorOrange : nolColorGrey,
            onTap: () => controller.categorySelect(category),
          );
        },
      ),
    );
  }

  PreferredSize? buildAppBar(BuildContext context) {
    return customAppBar(context, title: controller.title, actions: [
      Padding(
        padding: EdgeInsets.only(right: 16 * sizeUnit),
        child: Center(
          child: InkWell(
            onTap: controller.completion,
            child: Text(
              '완료',
              style: STextStyle.subTitle1().copyWith(
                color: controller.selectedCategory.isEmpty ? nolColorGrey : nolColorOrange,
              ),
            ),
          ),
        ),
      )
    ]);
  }

  Text buildTitle(String title) {
    return Text(
      title,
      style: STextStyle.highlight2(),
    );
  }
}

class CategorySelectionController extends GetxController {
  late final int categoryType;
  String selectedCategory = ''; // 선택된 카테고리
  String title = ''; // 앱바 타이틀
  List<String> interestList = []; // 관심 카테고리
  List<String> categoryList = []; // 메인 카테고리

  void init(int categoryType) {
    this.categoryType = categoryType;

    switch (categoryType) {
      case CategorySelectionPage.categoryTypeJob:
        title = '일터';
        interestList = GlobalData.interestJobList;
        categoryList = jobCategoryList;
        break;
      case CategorySelectionPage.categoryTypeTopic:
        title = '놀터';
        interestList = GlobalData.interestTopicList;
        categoryList = topicCategoryList;
        break;
      case CategorySelectionPage.categoryTypeAll:
        title = '카테고리';
        interestList = [...GlobalData.interestJobList, ...GlobalData.interestTopicList];
        break;
    }
  }

  // 카테고리 선택
  void categorySelect(String category) {
    selectedCategory = category;
    update();
  }

  // 완료
  void completion() {
    if (selectedCategory.isEmpty) return;
    Get.back(result: selectedCategory);
  }
}
