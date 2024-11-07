import 'dart:io';

import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_assets.dart';
import 'package:nolilteo/config/global_widgets/responsive.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/login/otp_login_page.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../community/models/post.dart';
import '../../data/tag_preview.dart';
import '../../home/controllers/main_page_controller.dart';
import '../../home/main_page.dart';
import '../../login/login_page.dart';
import '../global_function.dart';
import '../s_text_style.dart';

double sizeUnit = 1;

Widget adminItemBox({required String title, required Widget child}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            child: Text(title, style: STextStyle.subTitle1()),
          ),
        ],
      ),
      child,
      const Divider(),
    ],
  );
}

// 새로고침
Widget customRefreshIndicator({required Widget child, required Function() onRefresh}) {
  return CustomRefreshIndicator(
    onRefresh: () async {
      await onRefresh();
      return Future.delayed(const Duration(milliseconds: 500));
    },
    builder: (
      BuildContext context,
      Widget child,
      IndicatorController indicatorController,
    ) {
      return AnimatedBuilder(
        animation: indicatorController,
        builder: (BuildContext context, _) {
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              !indicatorController.isDragging && !indicatorController.isHiding && !indicatorController.isIdle
                  ? Positioned(
                      top: 12 * sizeUnit * indicatorController.value,
                      child: SizedBox(
                        width: 20 * sizeUnit,
                        height: 20 * sizeUnit,
                        child: CircularProgressIndicator(strokeWidth: 3 * sizeUnit, color: nolColorOrange),
                      ),
                    )
                  : Container(),
              Transform.translate(
                offset: Offset(0, 40 * sizeUnit * indicatorController.value),
                child: Container(
                  color: Colors.white,
                  child: child,
                ),
              ),
            ],
          );
        },
      );
    },
    child: child,
  );
}

Widget defaultButton({required String text, required GestureTapCallback onTap, bool isOk = false, Color color = Colors.blue, GestureTapCallback? notOkFunc}) {
  return InkWell(
    onTap: () {
      if (isOk) {
        onTap();
      } else {
        if (notOkFunc != null) notOkFunc();
      }
    },
    child: Container(
      width: double.infinity,
      height: 40 * sizeUnit,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isOk ? color : Colors.grey,
        borderRadius: BorderRadius.circular(8 * sizeUnit),
      ),
      child: Text(
        text,
        style: STextStyle.subTitle3().copyWith(color: Colors.white),
      ),
    ),
  );
}

// 다이어로그
showCustomDialog({
  String title = '',
  String description = '',
  String okText = '확인',
  String cancelText = '취소',
  GestureTapCallback? okFunc,
  Color okColor = nolColorOrange,
  bool isCancelButton = false,
  GestureTapCallback? cancelFunc,
}) {
  // 버튼
  Widget button({required String text, required GestureTapCallback onTap, Color bgColor = nolColorGrey, bool isSmallButton = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28 * sizeUnit),
        child: Container(
          width: isSmallButton ? 104 * sizeUnit : double.infinity,
          height: isSmallButton ? 48 * sizeUnit : 36 * sizeUnit,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28 * sizeUnit),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: STextStyle.subTitle1().copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        padding: EdgeInsets.symmetric(vertical: 24 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6 * sizeUnit,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: STextStyle.subTitle1().copyWith(height: 24 / 16),
                  textAlign: TextAlign.center,
                ),
              ],
              if (description.isNotEmpty) ...[
                SizedBox(height: 8 * sizeUnit),
                Text(
                  description,
                  style: STextStyle.body4().copyWith(height: 18 / 12),
                  textAlign: TextAlign.center,
                ),
              ],
              SizedBox(height: 16 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                child: isCancelButton
                    ? Row(
                        children: [
                          button(
                            text: cancelText,
                            isSmallButton: true,
                            onTap: cancelFunc ?? () => Get.back(),
                          ),
                          SizedBox(width: 8 * sizeUnit),
                          button(
                            text: okText,
                            bgColor: okColor,
                            isSmallButton: true,
                            onTap: okFunc ?? () => Get.back(),
                          ),
                        ],
                      )
                    : button(
                        text: okText,
                        bgColor: okColor,
                        onTap: okFunc ?? () => Get.back(),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierColor: const Color.fromRGBO(42, 46, 55, 0.3),
  );
}

// 위젯 다이어로그
showCustomWidgetDialog({
  String title = '',
  required Widget descriptionWidget,
  String okText = '확인',
  String cancelText = '취소',
  GestureTapCallback? okFunc,
  Color okColor = nolColorOrange,
  bool isCancelButton = false,
  GestureTapCallback? cancelFunc,
}) {
  // 버튼
  Widget button({required String text, required GestureTapCallback onTap, Color bgColor = nolColorGrey, bool isSmallButton = false}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28 * sizeUnit),
        child: Container(
          width: isSmallButton ? 104 * sizeUnit : double.infinity,
          height: isSmallButton ? 48 * sizeUnit : 36 * sizeUnit,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(28 * sizeUnit),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: STextStyle.subTitle1().copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  return Get.dialog(
    Center(
      child: Container(
        width: 280 * sizeUnit,
        padding: EdgeInsets.symmetric(vertical: 24 * sizeUnit),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(14 * sizeUnit),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(0, 0, 0, 0.05),
              blurRadius: 6 * sizeUnit,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: DefaultTextStyle(
          style: const TextStyle(decoration: TextDecoration.none),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (title.isNotEmpty) ...[
                Text(
                  title,
                  style: STextStyle.subTitle1().copyWith(height: 24 / 16),
                  textAlign: TextAlign.center,
                ),
              ],
              descriptionWidget,
              SizedBox(height: 16 * sizeUnit),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32 * sizeUnit),
                child: isCancelButton
                    ? Row(
                        children: [
                          button(
                            text: cancelText,
                            isSmallButton: true,
                            onTap: cancelFunc ?? () => Get.back(),
                          ),
                          SizedBox(width: 8 * sizeUnit),
                          button(
                            text: okText,
                            bgColor: okColor,
                            isSmallButton: true,
                            onTap: okFunc ?? () => Get.back(),
                          ),
                        ],
                      )
                    : button(
                        text: okText,
                        bgColor: okColor,
                        onTap: okFunc ?? () => Get.back(),
                      ),
              ),
            ],
          ),
        ),
      ),
    ),
    barrierColor: const Color.fromRGBO(42, 46, 55, 0.3),
  );
}

// 앱바
PreferredSize? customAppBar(
  BuildContext context, {
  Widget? leading,
  String? title,
  List<Widget>? actions,
  Widget? titleWidget,
  PreferredSize? bottom,
  bool? centerTitle,
  double? leadingWidth,
  ScrollController? controller,
  bool showAppBar = true,
}) {
  if (!showAppBar) return null;

  Widget leadingWidget({required GestureTapCallback onTap}) {
    return Padding(
      padding: EdgeInsets.only(left: 12 * sizeUnit),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          onTap: onTap,
          child: SvgPicture.asset(GlobalAssets.svgArrowLeft, width: 24 * sizeUnit),
        ),
      ),
    );
  }

  return PreferredSize(
    preferredSize: Size.fromHeight(bottom != null ? 90 * sizeUnit : 56 * sizeUnit),
    child: GestureDetector(
      onTap: () {
        if (Platform.isIOS && (controller != null && controller.positions.isNotEmpty)) {
          controller.animateTo(0, duration: const Duration(milliseconds: 250), curve: Curves.bounceInOut);
        }
      },
      child: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 56 * sizeUnit,
        elevation: 0.0,
        centerTitle: centerTitle,
        titleSpacing: 0.0,
        leadingWidth: leadingWidth ?? (Responsive.isMobile(context) ? null : 12 * sizeUnit),
        iconTheme: const IconThemeData(color: nolColorBlack),
        leading: Responsive.isMobile(context)
            ? Get.currentRoute != MainPage.route && Get.previousRoute.isEmpty
                ? leadingWidget(onTap: () => Get.offNamed(MainPage.route))
                : leading ?? leadingWidget(onTap: () => Get.back())
            : leading ?? const SizedBox.shrink(),
        title: titleWidget ??
            (title != null
                ? Text(
                    title,
                    style: STextStyle.appBar().copyWith(color: nolColorBlack),
                  )
                : null),
        actions: actions,
        bottom: bottom,
      ),
    ),
  );
}

Widget nolBottomButton({
  required String text,
  bool isOk = true,
  required Function() onTap,
  EdgeInsetsGeometry? padding,
}) {
  return Padding(
    padding: padding ?? EdgeInsets.only(left: 32 * sizeUnit, right: 32 * sizeUnit, bottom: 24 * sizeUnit),
    child: InkWell(
      borderRadius: BorderRadius.circular(24 * sizeUnit),
      onTap: () {
        if (isOk) {
          onTap();
        }
      },
      child: Container(
        width: double.infinity,
        height: 48 * sizeUnit,
        decoration: BoxDecoration(
          color: isOk ? nolColorOrange : nolColorGrey,
          borderRadius: BorderRadius.circular(24 * sizeUnit),
        ),
        child: Center(
          child: Text(text, style: STextStyle.button()),
        ),
      ),
    ),
  );
}

Widget nolRoundFitButton({
  required String text,
  Color? color = nolColorOrange,
  bool isOk = true,
  double? radius,
  required Function() onTap,
}){
  return InkWell(
    borderRadius: BorderRadius.circular(radius ?? 24 * sizeUnit),
    onTap: () {
      if (isOk) {
        onTap();
      }
    },
    child: Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isOk ? color : nolColorGrey,
        borderRadius: BorderRadius.circular(24 * sizeUnit),
      ),
      child: Center(
        child: Text(text, style: STextStyle.button()),
      ),
    ),
  );
}

Widget nolChips({
  required String text,
  Color bgColor = Colors.white,
  Color fontColor = nolColorOrange,
  Color borderColor = nolColorOrange,
  GestureTapCallback? onTap,
  GestureTapCallback? cancelFunc,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20 * sizeUnit),
    child: Container(
      height: 32 * sizeUnit,
      padding: EdgeInsets.symmetric(horizontal: 12 * sizeUnit),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: 1.5 * sizeUnit),
        borderRadius: BorderRadius.circular(20 * sizeUnit),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: STextStyle.highlight3().copyWith(
              color: fontColor,
              height: 1.2,
            ),
          ),
          if (cancelFunc != null) ...[
            SizedBox(width: 8 * sizeUnit),
            InkWell(
              onTap: cancelFunc,
              borderRadius: BorderRadius.circular(10 * sizeUnit),
              child: SvgPicture.asset(GlobalAssets.svgCancelInCircle, width: 20 * sizeUnit),
            ),
          ],
        ],
      ),
    ),
  );
}

Widget nolTag(String text, {Color? bgColor, Color? fontColor, Color? borderColor, Function? tapCallback}) {
  if (tapCallback != null) {
    return InkWell(
      borderRadius: BorderRadius.circular(12 * sizeUnit),
      onTap: () {
        tapCallback();
      },
      child: Container(
        height: 18 * sizeUnit,
        padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor ?? Colors.white,
          border: Border.all(color: borderColor ?? nolColorOrange, width: 1 * sizeUnit),
          borderRadius: BorderRadius.circular(12 * sizeUnit),
        ),
        child: Text(
          text,
          style: STextStyle.highlight4().copyWith(color: fontColor ?? nolColorOrange, height: 1.1 * sizeUnit),
        ),
      ),
    );
  }

  return Container(
    height: 18 * sizeUnit,
    padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: bgColor ?? Colors.white,
      border: Border.all(color: borderColor ?? nolColorOrange, width: 1 * sizeUnit),
      borderRadius: BorderRadius.circular(12 * sizeUnit),
    ),
    child: Text(
      text,
      style: STextStyle.highlight4().copyWith(color: fontColor ?? nolColorOrange, height: 1.1 * sizeUnit),
    ),
  );
}

Widget categoryFirstButton(String text) {
  return Container(
    height: 32 * sizeUnit,
    padding: EdgeInsets.symmetric(horizontal: 6 * sizeUnit),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: nolColorOrange,
      border: Border.all(color: nolColorOrange, width: 1 * sizeUnit),
      borderRadius: BorderRadius.circular(20 * sizeUnit),
    ),
    child: Text(
      text,
      style: STextStyle.highlight4().copyWith(color: Colors.white, height: 1.1 * sizeUnit),
    ),
  );
}

class IconAndCount extends StatelessWidget {
  const IconAndCount({Key? key, required this.iconPath, required this.count, this.textWidth, this.spaceWidth, this.onTap}) : super(key: key);

  final String iconPath;
  final int count;
  final double? textWidth;
  final double? spaceWidth;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          SvgPicture.asset(iconPath, width: 20 * sizeUnit),
          SizedBox(width: spaceWidth ?? 4 * sizeUnit),
          SizedBox(
            width: textWidth,
            child: Text(count > 999 ? '999+' : count.toString(), style: STextStyle.body5()),
          ),
        ],
      ),
    );
  }
}

Divider buildLine() => Divider(height: 1 * sizeUnit, thickness: 1 * sizeUnit, color: nolColorLightGrey);

Widget nolDivider() {
  return Container(
    width: double.infinity,
    height: 1 * sizeUnit,
    color: nolColorLightGrey,
  );
}

// 검색결과 없음 위젯
Widget noSearchResultWidget(String text) {
  final String src = GlobalData.loginUser.id == nullInt ? GlobalAssets.svgLogo : WbtiType.getType(GlobalData.loginUser.wbti).src;

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(src, width: GlobalData.loginUser.id == nullInt ? 120 * sizeUnit : null),
      SizedBox(height: 16 * sizeUnit),
      Text(
        text,
        style: STextStyle.subTitle1().copyWith(height: 1.2),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

Widget nolFitButton({
  required String text,
  Function()? onTap,
}) {
  return InkWell(
    borderRadius: BorderRadius.circular(18 * sizeUnit),
    onTap: onTap,
    child: Container(
      height: 36 * sizeUnit,
      decoration: BoxDecoration(
        color: nolColorOrange,
        borderRadius: BorderRadius.circular(18 * sizeUnit),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: STextStyle.button(),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget bottomSheetCancelButton() {
  return InkWell(
    onTap: () => Get.back(),
    child: Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Row(
        children: [
          SvgPicture.asset(GlobalAssets.svgCancel, width: 24 * sizeUnit),
          SizedBox(width: 8 * sizeUnit),
          Text('취소', style: STextStyle.body2()),
        ],
      ),
    ),
  );
}

// 바텀 시트 아이템
Widget bottomSheetItem({required String text, required GestureTapCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: EdgeInsets.all(16 * sizeUnit),
      child: Row(
        children: [
          Expanded(child: Text(text, style: STextStyle.body2())),
          SvgPicture.asset(GlobalAssets.svgArrowRight, width: 24 * sizeUnit),
        ],
      ),
    ),
  );
}

Widget tagPreviewItem(TagPreview tagPreview, {required GestureTapCallback onTap, Widget? trailingWidget}) {
  final String tag = '#${tagPreview.tag}';
  final String postType = tagPreview.postType == Post.postTypeJob
      ? '일터'
      : tagPreview.postType == Post.postTypeTopic
          ? '놀터'
          : 'WBTI';
  final String count = GlobalFunction.getCount(tagPreview.count);

  return InkWell(
    onTap: onTap,
    child: SizedBox(
      width: double.infinity,
      height: 48 * sizeUnit,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tag,
                    style: STextStyle.subTitle1(),
                  ),
                  SizedBox(width: 8 * sizeUnit),
                  Text(
                    tagPreview.postType != Post.postTypeMeeting ? '$postType $count' : count,
                    style: STextStyle.subTitle3().copyWith(
                      color: nolColorGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (trailingWidget != null) trailingWidget
          ],
        ),
      ),
    ),
  );
}

// 닉네임 위젯
Widget nickNameWidget(String fullNickName, {double? fontSize, required double maxWidth}) {
  List<String> list = fullNickName.split(' | ');
  if (list.length < 2) return const SizedBox.shrink();

  return ConstrainedBox(
    constraints: BoxConstraints(maxWidth: maxWidth),
    child: RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          TextSpan(text: '${list[0]} | ', style: STextStyle.subTitle3().copyWith(fontSize: fontSize, height: 1.1)),
          TextSpan(
            text: list[1],
            style: STextStyle.subTitle3().copyWith(color: nolColorOrange, fontSize: fontSize, height: 1.1),
          ),
        ],
      ),
    ),
  );
}

// 로그인 유도 위젯
Widget noLoginInduceWidget() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      SvgPicture.asset(
        GlobalAssets.svgLogo,
        width: 100 * sizeUnit,
        height: 100 * sizeUnit,
      ),
      Row(children: [SizedBox(height: 16 * sizeUnit)]),
      Text(
        '로그인 후 이용해 주세요.',
        style: STextStyle.headline3(),
      ),
      SizedBox(height: 4 * sizeUnit),
      Text(
        '로그인하고 WBTI의 더 많은\n서비스를 이용해 보세요:)',
        style: STextStyle.body4().copyWith(height: 18 / 12),
        textAlign: TextAlign.center,
      ),
      SizedBox(height: 24 * sizeUnit),
      nolFitButton(
          text: kIsWeb ? '로그인' : '로그인/회원가입',
          onTap: () {
            if (kIsWeb) {
              //모바일웹인지?
              if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android) {
                //모바일 웹
                GlobalFunction.mobileWebLoginDialog();
              } else {
                //pc 웹
                Get.dialog(const OtpLoginPage());
              }
            } else {
              Get.to(() => LoginPage(noTest: true, beBack: true));
              MainPageController mainPageController = Get.find<MainPageController>();
              mainPageController.changePage(0);
            }
          }),
    ],
  );
}
