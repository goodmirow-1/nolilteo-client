import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../../config/global_widgets/global_widget.dart';
import '../../repository/user_repository.dart';
import '../../wbti/wbti_test_page.dart';

class EditProfileController extends GetxController {
  static get to => Get.find<EditProfileController>();

  bool isEdit = false;

  RxString nickname = ''.obs;
  String? nicknameErrorText;

  String wbti = '';
  late WbtiType wbtiType;

  String job = '';
  String? jobErrorText;
  late TextEditingController jobTextEditingController;
  late TextEditingController birthdayEditingController;

  int? gender;
  DateTime? preDate;
  DateTime? birthdayDateTime;

  bool duplicateCheckLoading = false; // 중복체크 로딩

  @override
  void onInit() {
    super.onInit();

    nicknameDuplicateCheck(); // 닉네임 중복 체크
  }

  //수정완료 버튼
  void editFunc() async {
    if (isEdit && isValid()) {
      //수정완료
      GlobalData.loginUser.nickName = nickname.value;
      GlobalData.loginUser.job = job;
      GlobalData.loginUser.gender = gender;
      GlobalData.loginUser.birthday = birthdayDateTime == null ? null : birthdayDateTime!.toString();
      if (kDebugMode) {
        print('수정완료');
      }

      await UserRepository.edit(
          id: GlobalData.loginUser.id,
          nickName: GlobalData.loginUser.nickName,
          wbtiType: GlobalData.loginUser.wbti,
          job: GlobalData.loginUser.job,
          gender: GlobalData.loginUser.gender == null ? null : GlobalData.loginUser.gender!,
          birthday: GlobalData.loginUser.birthday == null ? null : GlobalData.loginUser.birthday!);

      Fluttertoast.showToast(
        msg: '수정이 완료되었습니다.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: const Color.fromRGBO(0, 0, 0, 0.51),
        textColor: Colors.white,
      );

      Get.back();
    }
  }

  bool isValid() {
    if (nicknameErrorText != null || jobErrorText != null || nickname.isEmpty || job.isEmpty || duplicateCheckLoading) {
      return false;
    }
    return true;
  }

  Future<void> initNickname(TextEditingController controller) async {
    nickname(GlobalData.loginUser.nickName);
    controller.text = nickname.value;
  }

  void nicknameChangeFun(String value) {
    isEdit = true;
    nickname(value);
    nicknameErrorText = GlobalFunction.validNickNameErrorText(nickname.value);
    duplicateCheckLoading = true; // 중복체크 로딩 시작

    update(['nickname', 'edit_button']);
  }

  // 닉네임 중복 체크
  void nicknameDuplicateCheck() async{
    debounce(
      nickname,
      time: const Duration(milliseconds: 500),
          (callback) async {
        if (nicknameErrorText == null && nickname.value.length >= 2 && nickname.value != GlobalData.loginUser.nickName) {
          var result = await UserRepository.checkNickName(nickName: nickname.value);
          if (result == false) nicknameErrorText = '이미 존재하는 닉네임이에요!';
          duplicateCheckLoading = false; // 중복체크 로딩 끝
          update(['nickname', 'edit_button']);
        }
      },
    );
  }

  Future<void> initWbti() async {
    wbti = GlobalData.loginUser.wbti;
    wbtiType = WbtiType.getType(wbti);

    update(['wbti']);
  }

  void wbtiTestButtonFunc() {
    Get.to(() => const WbtiTestPage());
  }

  Future<void> initJob() async {
    job = GlobalData.loginUser.job;
    try {
      jobTextEditingController.text = job;
    } catch (e) {
      if(kDebugMode) print(e.toString());
    }

    update(['job']);
  }

  void jobChangeFun(String value) {
    isEdit = true;
    job = value;
    jobErrorText = GlobalFunction.validJobErrorText(job);

    update(['job', 'edit_button']);
  }

  Future<void> initGender() async {
    gender = GlobalData.loginUser.gender;
    if (gender != 1 && gender != 2 && gender != 3) {
      gender = null;
    }
  }

  void genderCheckFunc(int selectGender) {
    if (gender == null) {
      showCustomDialog(
        title: '성별은 한 번 결정하면\n수정할 수 없어요!',
        okText: '확인',
        okFunc: () {
          Get.back(); // 다이어로그 끄기
        },
      );
      isEdit = true;
    }
    gender = selectGender;
    update(['gender', 'edit_button']);
  }

  Future<void> initBirthday(TextEditingController controller) async {
    birthdayEditingController = controller;
    if (GlobalData.loginUser.birthday != null) {
      preDate = DateTime.parse(GlobalData.loginUser.birthday!);
      setBirthday(preDate!);
      isEdit = false;
    }
  }

  void setBirthday(DateTime date) {
    birthdayDateTime = date;
    birthdayEditingController.text = DateFormat('y년 M월 d일').format(birthdayDateTime!);
    if (preDate != birthdayDateTime) {
      isEdit = true;
    }
    update(['birthday', 'edit_button']);
  }
}
