import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';

import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/bottom_line_text_field.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/global_widgets/responsive.dart';
import '../config/s_text_style.dart';
import '../data/global_data.dart';
import 'controllers/login_controller.dart';

class NicknamePage extends StatefulWidget {
  const NicknamePage({Key? key}) : super(key: key);
  static const String route = '/nickname_page';

  @override
  State<NicknamePage> createState() => _NicknamePageState();
}

class _NicknamePageState extends State<NicknamePage> {


  final LoginController controller = Get.put(LoginController());
  final PageController pageController = PageController();
  TextEditingController textEditingController = TextEditingController();
  TextEditingController jobTextEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GlobalData.pageRouteList.add(NicknamePage.route);
    controller.nickPageInit();
    textEditingController.text = controller.nickname.value;
    jobTextEditingController.text = controller.job;
  }

  @override
  void dispose() {
    if(GlobalData.pageRouteList.isNotEmpty && GlobalData.pageRouteList.last == NicknamePage.route){
      GlobalData.pageRouteList.removeLast();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      onWillPop: () {
        controller.nickPageBackFunc(pageController);
        return Future.value(false);
      },
      child: GestureDetector(
        onTap: () => GlobalFunction.unFocus(context),
        child: Scaffold(
          appBar: customAppBar(context,
            leadingWidth: Responsive.isMobile(context) ? null : 48 * sizeUnit,
            leading: InkWell(
              onTap: () {
                controller.nickPageBackFunc(pageController);
              },
              child: Center(
                child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
              ),
            ),
          ),
          body: GetBuilder<LoginController>(
              id: 'nickname_page',
              builder: (_) {
                return Column(
                  children: [
                    Expanded(
                      child: PageView(
                        controller: pageController,
                        onPageChanged: controller.nickPageChanged,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          nickNamePage(textEditingController),
                          jobPage(jobTextEditingController),
                        ],
                      ),
                    ),
                    nolBottomButton(
                        text: '다음',
                        isOk: controller.isCanNextForNick(),
                        onTap: (){
                          GlobalFunction.unFocus(context);
                          controller.nickPageNextFunc(pageController);
                        }
                    ),
                  ],
                );
              }),
        ),
      ),
    );
  }

  Widget nickNamePage(TextEditingController textEditingController){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        topTextBox(),
        Row(children: [SizedBox(height: 48 * sizeUnit)]),
        SizedBox(
          width: 280 * sizeUnit,
          height: 68 * sizeUnit,
          child: BottomLineTextField(
            controller: textEditingController,
            hintText: '닉네임 입력',
            onChanged: controller.changeNicknameFunc,
            textInputType: TextInputType.name,
            errorText: controller.nicknameErrorText,
          ),
        ),
      ],
    );
  }

  Widget jobPage(TextEditingController textEditingController){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        topTextBox(text: '활동할 때 보여질\n직업을 입력주세요 :)'),
        Row(children: [SizedBox(height: 48 * sizeUnit)]),

        SizedBox(
          width: 280 * sizeUnit,
          height: 72 * sizeUnit,
          child: GetBuilder<LoginController>(
              id: 'job_input',
              builder: (_) {
                return BottomLineTextField(
                  controller: textEditingController,
                  hintText: '예) 디자이너',
                  onChanged: controller.changeJobFunc,
                  textInputType: TextInputType.name,
                  errorText: controller.jobErrorText,
                );
              }),
        ),
        SizedBox(height: 16 * sizeUnit),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 40 * sizeUnit),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [Text('WBTI 결과에 따라 이렇게 보여요!', style: STextStyle.subTitle1().copyWith(color: nolColorOrange))],
              ),
              SizedBox(height: 16 * sizeUnit),
              GetBuilder<LoginController>(
                  id: 'job_example',
                  builder: (_) {
                    String job = controller.job.isEmpty ? '디자이너' : controller.job;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ex) 배려가 넘치는 $job',
                          style: STextStyle.body4().copyWith(color: nolColorOrange),
                        ),
                        SizedBox(height: 8 * sizeUnit),
                        Text(
                          'ex) 효율적인 해결사 $job',
                          style: STextStyle.body4().copyWith(color: nolColorOrange),
                        ),
                        SizedBox(height: 8 * sizeUnit),
                        Text(
                          'ex) 근면성실한 $job',
                          style: STextStyle.body4().copyWith(color: nolColorOrange),
                        ),
                      ],
                    );
                  }),
              SizedBox(height: 24 * sizeUnit),
              Text('*올바른 직업명이 아닐 경우 이용에 제한이 있을 수 있습니다.', style: STextStyle.body5()),
              SizedBox(height: 8 * sizeUnit),
              Text('ex) 마법사, 주술사, 도적', style: STextStyle.body5()),
              SizedBox(height: 8 * sizeUnit),
              Text('예외) 취준생, 알바생', style: STextStyle.body5()),
              SizedBox(height: 24 * sizeUnit),
            ],
          ),
        ),
      ],
    );
  }

  Widget topTextBox({String? text}) {
    return Padding(
      padding: EdgeInsets.only(left: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(text ?? '활동할 때 사용하실\n닉네임을 정해주세요 :)', style: STextStyle.body1()),
            ],
          ),
        ],
      ),
    );
  }
}