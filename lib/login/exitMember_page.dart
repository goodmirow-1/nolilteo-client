import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/analytics.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/config/global_widgets/custom_text_field.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/login/login_page.dart';
import 'package:nolilteo/repository/user_repository.dart';

import '../../config/global_widgets/base_widget.dart';

import '../config/constants.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';

class ExitMemberPage extends StatefulWidget {
  const ExitMemberPage({Key? key}) : super(key: key);

  @override
  State<ExitMemberPage> createState() => _ExitMemberPageState();
}

class _ExitMemberPageState extends State<ExitMemberPage> {
  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  int exitType = -1;
  String exitContents = '';

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, 
          title: '탈퇴하기',
        ),
        body: GestureDetector(
          onTap: () => GlobalFunction.unFocus(context),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  buildLine(),
                  SizedBox(height: 24 * sizeUnit),
                  buildTitle('탈퇴 전 꼭! 확인해주세요.'),
                  SizedBox(height: 8 * sizeUnit),
                  Text(
                    '탈퇴 시, 작성한 게시글과 댓글 등 모든 활동 정보 및 개인정보가 삭제됩니다.',
                    style: STextStyle.body3().copyWith(height: 21 / 14),
                  ),
                  SizedBox(height: 32 * sizeUnit),
                  buildTitle('탈퇴하시는 이유가 궁금해요.'),
                  SizedBox(height: 16 * sizeUnit),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: userExitReportList.length,
                    itemBuilder: (context, index) => reportItem(userExitReportList[index], index),
                  ),
                  SizedBox(height: 16 * sizeUnit),
                  reportContentsWidget(), // 신고 내용 위젯
                  ConstrainedBox(constraints: BoxConstraints(minHeight: 24 * sizeUnit)),
                  nolBottomButton(
                    padding: EdgeInsets.zero,
                    text: '탈퇴하기',
                    isOk: exitType != -1 && (exitType == userExitReportList.length - 1 ? exitContents.isNotEmpty : true),
                    onTap: () {
                      showCustomDialog(
                        title: '정말 탈퇴하시겠어요?',
                        okFunc: () async {
                          Get.back();

                          exitContents = exitType != (userExitReportList.length - 1) ? '' : exitContents;
                          await UserRepository.exitMember(userID: GlobalData.loginUser.id, type: exitType, contents: exitContents);
                          NolAnalytics.logEvent(name: 'user_exit', parameters: {'userID': GlobalData.loginUser.id}); // 애널리틱스 탈퇴

                          showCustomDialog(
                            title: '탈퇴되셨어요.\n언제든 돌아오시길 기다릴께요',
                            okFunc: () async {
                              Get.back();

                              Get.offAll(() => LoginPage());
                            },
                            okText: '네',
                          );
                        },
                        isCancelButton: true,
                        okText: '네',
                        cancelText: '아니오',
                      );
                    },
                  ),
                  SizedBox(height: 16 * sizeUnit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Text buildTitle(String text) {
    return Text(
      text,
      style: STextStyle.headline3().copyWith(color: nolColorOrange),
    );
  }

  Widget reportItem(String reportTitle, int index) {
    return Padding(
      padding: EdgeInsets.only(bottom: index != userExitReportList.length - 1 ? 16 * sizeUnit : 0),
      child: InkWell(
        onTap: () {
          setState(() {
            exitType = index;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            scrollController.animateTo(scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
          });
        },
        child: Row(
          children: [
            exitType == index ? SvgPicture.asset(GlobalAssets.svgCheckCircle) : SvgPicture.asset(GlobalAssets.svgCheckCircleEmpty),
            SizedBox(width: 8 * sizeUnit),
            Text(
              reportTitle,
              style: STextStyle.body3(),
            )
          ],
        ),
      ),
    );
  }

  Widget reportContentsWidget() {
    return exitType == -1
        ? const SizedBox.shrink()
        : CustomTextField(
            hintText: '상세한 사유를 알려주세요',
            onChanged: (value) {
              setState(() {
                exitContents = value;
              });
            },
            maxLines: 4,
          );
  }
}
