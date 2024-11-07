import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:nolilteo/data/global_data.dart';
import '../config/constants.dart';
import '../config/global_assets.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/bottom_line_text_field.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';
import '../data/user.dart';
import '../my_page/controller/edit_profile_controller.dart';

class EditProfilePage extends StatelessWidget {
  EditProfilePage({Key? key}) : super(key: key);

  final EditProfileController controller = Get.put(EditProfileController());

  final TextEditingController nicknameEditingController = TextEditingController();
  final TextEditingController jobEditingController = TextEditingController();
  final TextEditingController birthdayEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: GestureDetector(
        onTap: () {
          GlobalFunction.unFocus(context);
        },
        child: Scaffold(
          appBar: customAppBar(context, 
            title: '프로필 수정',
            actions: [
              GetBuilder<EditProfileController>(
                id: 'edit_button',
                builder: (_) {
                  return TextButton(
                    onPressed: controller.editFunc,
                    child: Text(
                      '완료',
                      style: STextStyle.subTitle1().copyWith(color: controller.isEdit && controller.isValid() ? nolColorOrange : nolColorGrey),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                nolDivider(),
                GetBuilder<EditProfileController>(
                  id: 'nickname',
                  initState: (_) {
                    controller.initNickname(nicknameEditingController);
                  },
                  builder: (_) {
                    return nicknameBox();
                  },
                ),
                nolDivider(),
                GetBuilder<EditProfileController>(
                  id: 'wbti',
                  initState: (_) {
                    controller.initWbti();
                  },
                  builder: (_) {
                    return wbtiBox();
                  },
                ),
                nolDivider(),
                GetBuilder<EditProfileController>(
                  id: 'job',
                  initState: (_) {
                    controller.jobTextEditingController = jobEditingController;
                    controller.initJob();
                  },
                  builder: (_) {
                    return jobBox();
                  },
                ),
                // nolDivider(),
                // GetBuilder<EditProfileController>(
                //   id: 'gender',
                //   initState: (_) {
                //     controller.initGender();
                //   },
                //   builder: (_) {
                //     return genderBox();
                //   },
                // ),
                // nolDivider(),
                // GetBuilder<EditProfileController>(
                //   id: 'birthday',
                //   initState: (_) {
                //     controller.initBirthday(birthdayEditingController);
                //   },
                //   builder: (_) {
                //     return birthdayBox(context);
                //   },
                // ),
                nolDivider(),
                SizedBox(height: 24 * sizeUnit),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget nicknameBox() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * sizeUnit, horizontal: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('닉네임', style: STextStyle.subTitle1()),
          SizedBox(height: 8 * sizeUnit),
          BottomLineTextField(
            controller: nicknameEditingController,
            onChanged: controller.nicknameChangeFun,
            errorText: controller.nicknameErrorText,
          ),
        ],
      ),
    );
  }

  Widget wbtiBox() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * sizeUnit, horizontal: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('WBTI 캐릭터', style: STextStyle.subTitle1()),
          SizedBox(
            height: 200 * sizeUnit,
            child: Center(
              child: SvgPicture.asset(
                controller.wbtiType.src,
                height: 150 * sizeUnit,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: controller.wbtiTestButtonFunc,
                child: SizedBox(
                  child: Text(
                    'WBTI 검사 다시하기',
                    style: STextStyle.body4().copyWith(color: nolColorOrange),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget jobBox() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * sizeUnit, horizontal: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('직업', style: STextStyle.subTitle1()),
          SizedBox(height: 8 * sizeUnit),
          BottomLineTextField(
            controller: jobEditingController,
            onChanged: controller.jobChangeFun,
            errorText: controller.jobErrorText,
          ),
        ],
      ),
    );
  }

  Widget genderBox() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * sizeUnit, horizontal: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('성별', style: STextStyle.subTitle1()),
          SizedBox(height: 8 * sizeUnit),
          SizedBox(
            height: 48 * sizeUnit,
            child: Row(
              children: [
                if (GlobalData.loginUser.gender == null || GlobalData.loginUser.gender == User.genderMale) ...[
                  customRadioButton(gender: User.genderMale),
                  SizedBox(width: 24 * sizeUnit),
                ],
                if (GlobalData.loginUser.gender == null || GlobalData.loginUser.gender == User.genderFemale) ...[
                  customRadioButton(gender: User.genderFemale),
                  SizedBox(width: 24 * sizeUnit),
                ],
                if (GlobalData.loginUser.gender == null || GlobalData.loginUser.gender == User.genderOther) ...[
                  customRadioButton(gender: User.genderOther),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget birthdayBox(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16 * sizeUnit, horizontal: 24 * sizeUnit),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('생년월일', style: STextStyle.subTitle1()),
          SizedBox(height: 8 * sizeUnit),
          InkWell(
            onTap: () async {
              controller.setBirthday(await datePicker(context: context, initialDateTime: controller.birthdayDateTime));
            },
            child: BottomLineTextField(
              controller: birthdayEditingController,
              hintText: '선택하기',
              enable: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget customRadioButton({required int gender}) {
    String text = '';
    switch (gender) {
      case User.genderMale:
        text = '남성';
        break;
      case User.genderFemale:
        text = '여성';
        break;
      case User.genderOther:
        text = '그 외';
        break;
    }
    return InkWell(
      onTap: () {
        controller.genderCheckFunc(gender);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            gender == controller.gender ? GlobalAssets.svgCheckCircle : GlobalAssets.svgCheckCircleEmpty,
            width: 20 * sizeUnit,
            height: 20 * sizeUnit,
          ),
          SizedBox(width: 8 * sizeUnit),
          Text(text, style: STextStyle.body3()),
        ],
      ),
    );
  }

  // datePicker
  Future<DateTime> datePicker({required BuildContext context, DateTime? initialDateTime}) async {
    final DateTime now = DateTime.now();
    DateTime? date;

    await showCupertinoModalPopup(
        context: context,
        builder: (_) => SizedBox(
              height: 200 * sizeUnit,
              child: CupertinoDatePicker(
                backgroundColor: Colors.white,
                initialDateTime: initialDateTime ?? DateTime(now.year - 30, now.month, now.day),
                mode: CupertinoDatePickerMode.date,
                maximumDate: now,
                maximumYear: now.year,
                minimumDate: DateTime(1900, 1, 1),
                minimumYear: 1900,
                onDateTimeChanged: (val) => date = val,
              ),
            ));

    date ??= initialDateTime ?? now;

    return DateTime(date!.year, date!.month, date!.day);
  }
}
