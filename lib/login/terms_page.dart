import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../data/global_data.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import 'controllers/login_controller.dart';

class TermsPage extends StatefulWidget {
  const TermsPage({Key? key}) : super(key: key);
  static const String route = '/terms_page';

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {

  final LoginController controller = Get.put(LoginController());

  static const int radioTypeNormal = 1; // 기본
  static const int radioTypeMarketing = 2; // 마케팅

  @override
  void initState() {
    GlobalData.pageRouteList.add(TermsPage.route);
    super.initState();
  }

  @override
  void dispose() {
    if(GlobalData.pageRouteList.isNotEmpty && GlobalData.pageRouteList.last == TermsPage.route){
      GlobalData.pageRouteList.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context),
        body: GetBuilder<LoginController>(
            id: 'terms_page',
            builder: (_) {
              return Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 64 * sizeUnit),
                          topTextBox(),
                          SizedBox(height: 44 * sizeUnit),
                          Column(
                            children: [
                              checkButtonBoxAll(text: '전체 동의', radioValue: controller.allAgree),
                              SizedBox(height: 16 * sizeUnit),
                              Container(
                                width: 328 * sizeUnit,
                                height: 2 * sizeUnit,
                                color: nolColorLightGrey,
                              ),
                              SizedBox(height: 16 * sizeUnit),
                              customRadioButton(
                                type: radioTypeNormal,
                                text: '이용약관 동의',
                                radioValue: controller.termsOfUseAgree,
                                url: urlTermsOfService,
                                variety: 1,
                              ),
                              SizedBox(height: 16 * sizeUnit),
                              customRadioButton(
                                type: radioTypeNormal,
                                text: '개인정보 수집 및 이용 동의',
                                radioValue: controller.privacyAgree,
                                url: urlPrivacyPolicy,
                                variety: 2,
                              ),
                              SizedBox(height: 16 * sizeUnit),
                              customRadioButton(
                                type: radioTypeMarketing,
                                text: '마케팅 정보 수신동의',
                                radioValue: controller.marketingAgree,
                                isRequired: false,
                                url: urlMarketingTerms,
                                variety: 3,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  nolBottomButton(
                    text: '다음',
                    isOk: controller.activeNextForTerms,
                    onTap: controller.goToNickNamePage,
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget topTextBox() {
    return Padding(
      padding: EdgeInsets.only(left: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('안녕하세요!', style: STextStyle.headline1()),
          SizedBox(height: 16 * sizeUnit),
          Text('WBTI 이용약관에 동의해주세요', style: STextStyle.body1()),
          Padding(
            padding: EdgeInsets.only(top: 4 * sizeUnit),
            child: Text('이용약관에 동의하고 WBTI의 다양한 혜택을 누리세요 :)', style: STextStyle.body4()),
          ),
        ],
      ),
    );
  }

  Widget checkButtonBoxAll({required String text, required bool radioValue}) {
    return Padding(
      padding: EdgeInsets.only(left: 24 * sizeUnit, right: 20 * sizeUnit),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: () {
                  controller.termAllCheckBoxFunc();
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      radioValue ? GlobalAssets.svgCheckCircle : GlobalAssets.svgCheckCircleEmpty,
                      width: 20 * sizeUnit,
                      height: 20 * sizeUnit,
                    ),
                    SizedBox(width: 8 * sizeUnit),
                    Text(text, style: STextStyle.subTitle1().copyWith(color: nolColorOrange)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget customRadioButton({required int type, required String text, required bool radioValue, bool isRequired = true, String url = '', required int variety}) {
    return Padding(
      padding: EdgeInsets.only(left: 24 * sizeUnit, right: 20 * sizeUnit),
      child: InkWell(
        onTap: () {
          controller.termCheckBoxFunc(variety);
        },
        child: Column(
          children: [
            Row(
              children: [
                Row(
                  children: [
                    SvgPicture.asset(
                      radioValue ? GlobalAssets.svgCheckCircle : GlobalAssets.svgCheckCircleEmpty,
                      width: 20 * sizeUnit,
                      height: 20 * sizeUnit,
                    ),
                    SizedBox(width: 8 * sizeUnit),
                    RichText(
                        text: TextSpan(text: text, style: STextStyle.body2(), children: [
                          TextSpan(
                            text: isRequired ? ' (필수)' : ' (선택)',
                            style: STextStyle.body2().copyWith(color: isRequired ? nolColorOrange : nolColorBlack),
                          )
                        ])),
                  ],
                ),
                const Spacer(),
                InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    GlobalFunction.launchWebUrl(url);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(4 * sizeUnit),
                    child: SvgPicture.asset(
                      GlobalAssets.svgArrowRight,
                      width: 20 * sizeUnit,
                      height: 20 * sizeUnit,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

