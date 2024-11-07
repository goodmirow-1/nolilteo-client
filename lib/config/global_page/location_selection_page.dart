import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/config/global_widgets/search_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../analytics.dart';
import '../constants.dart';
import '../global_function.dart';
import '../global_widgets/responsive.dart';
import '../location_constants.dart';
import '../s_text_style.dart';
import '../../data/global_data.dart';

class LocationSelectionPage extends StatelessWidget {
  LocationSelectionPage({Key? key, this.showInterestList = true, this.showAll = true}) : super(key: key);

  final bool showInterestList;
  final bool showAll;

  final LocationSelectionController controller = Get.put(LocationSelectionController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      onWillPop: () {
        if (controller.selectionLevel == 0) {
          return Future.value(true);
        } else {
          controller.backFunc();
          return Future.value(false);
        }
      },
      child: GetBuilder<LocationSelectionController>(builder: (_) {
        return Scaffold(
          appBar: controller.selectionLevel == 0
              ? customAppBar(context, 
                  title: '지역 등록',
                  leadingWidth: Responsive.isMobile(context) ? null : 48 * sizeUnit,
                  leading: InkWell(
                    onTap: () => controller.backFunc(),
                    child: Center(child: SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit)),
                  ),
                )
              : null,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => GlobalFunction.unFocus(context),
            child: Column(
              children: [
                buildLine(),
                if (controller.selectionLevel == 0) ...[
                  if (showInterestList && GlobalData.interestLocationList.isNotEmpty) buildInterestList(),
                ] else ...[
                  buildAppBarAndTextFiled(),
                ],
                Expanded(
                  child: controller.items.isEmpty
                      ? noSearchResultWidget('검색 결과가 없어요')
                      : ListView.builder(
                          itemCount: controller.items.length,
                          itemBuilder: (context, index) => locationItem(controller.items[index], index),
                        ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // 관심 지역
  Widget buildInterestList() {
    return Container(
      width: double.infinity,
      height: 48 * sizeUnit,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: nolColorLightGrey))),
      child: SingleChildScrollView(
          controller: controller.scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              GlobalData.interestLocationList.length,
              (index) {
                final String location = GlobalData.interestLocationList[index];

                return Padding(
                  padding: EdgeInsets.only(left: index == 0 ? 16 * sizeUnit : 0, right: 8 * sizeUnit),
                  child: nolChips(
                    text: '@$location'.replaceFirst(' ALL', ''),
                    cancelFunc: () => controller.locationDeleteFunc(index),
                  ),
                );
              },
            ),
          )),
    );
  }

  Widget locationItem(String location, int index) {
    return InkWell(
      onTap: () => controller.selectionEvent(location: location, index: index, showAll: showAll),
      child: Container(
        padding: EdgeInsets.all(16 * sizeUnit),
        child: Row(
          children: [
            Expanded(
              child: Text('@$location', style: STextStyle.subTitle1()),
            ),
            SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
          ],
        ),
      ),
    );
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
            onTap: () => controller.backFunc(),
            child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
          ),
          Expanded(
            child: SearchTextField(
              controller: controller.searchController,
              hintText: '상세 지역을 검색해주세요.',
              onChanged: (value) => controller.searchEvent(value),
            ),
          ),
        ],
      ),
    );
  }
}

class LocationSelectionController extends GetxController {
  final List<List<String>> allLocationList = [
    areaSeoulCategory,
    areaInCheonCategory,
    areaGyongGiCategory,
    areaKangWonCategory,
    areaChungSouthCategory,
    areaChungNorthCategory,
    areaSejongCategory,
    areaDaejeonCategory,
    areaGyeongsangNorthCategory,
    areaGyeongsangSouthCategory,
    areaDaeguCategory,
    areaBusanCategory,
    areaJeonNorthCategory,
    areaJeonSouthCategory,
    areaGwangjuCategory,
    areaUlsanCategory,
    areaJejuCategory,
  ];

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  String bigLocation = ''; // 큰 지역
  String smallLocation = ''; // 작은 지역
  late List<String> smallLocationList; // 선택된 작은 지역 리스트
  int selectionLevel = 0; // 지역 선택 단계
  List<String> items = areaCategory; // 화면에 보이는 리스트

  @override
  void onClose() {
    super.onClose();

    searchController.dispose();
    scrollController.dispose();
  }

  // 지역 삭제
  void locationDeleteFunc(int index) async{
    GlobalData.interestLocationList.removeAt(index);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('interestLocationList', GlobalData.interestLocationList); // 로컬 리스트 세팅
    update();
  }

  // 검색
  void searchEvent(String value) {
    items = smallLocationList.where((element) => element.contains(value)).toList();
    update();
  }

  // 지역 선택
  void selectionEvent({required String location, required int index, required bool showAll}) async{
    if (selectionLevel == 0) {
      bigLocation = location; // 큰 지역 세팅
      if (showAll) {
        smallLocationList = ['전체', ...allLocationList[index]]; // 작은 지역 리스트 세팅
      } else {
        smallLocationList = allLocationList[index];
      }
      selectionLevel = 1; // 지역 선택 단계
      items = smallLocationList; // 화면에 보이는 리스트 세팅
      update();
    } else {
      final String resultLocation = '$bigLocation${location == '전체' ? ' ALL' : ' $location'}';

      if(showAll) {
        if(!GlobalData.interestLocationList.contains(resultLocation)) {
          GlobalData.interestLocationList.add(resultLocation);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setStringList('interestLocationList', GlobalData.interestLocationList); // 로컬 리스트 세팅
          NolAnalytics.logEvent(name: 'interest_location_add', parameters: {'location': resultLocation}); // 애널리틱스 관심 지역 등록
          WidgetsBinding.instance.addPostFrameCallback((_) => setMaxScroll()); // 스크롤 맨 뒤로
        } else {
          GlobalFunction.showToast(msg: '이미 등록되어 있는 지역입니다.');
        }

        selectionLevel = 0; // 지역 선택 단계
        items = areaCategory; // 화면에 보이는 리스트 세팅
        bigLocation = '';
        smallLocation = '';
        update();
      } else {
        Get.back(result: resultLocation); // 글쓰기 페이지로 이동
      }
    }
  }

  void backFunc() {
    if (selectionLevel == 0) {
      Get.back();
    } else {
      selectionLevel = 0; // 지역 선택 단계
      searchController.clear();
      items = areaCategory; // 화면에 보이는 리스트 세팅
      update();
    }
  }

  // 관심 등록 스크롤 마지막으로
  void setMaxScroll(){
    if(scrollController.hasClients) {
      scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }
}
