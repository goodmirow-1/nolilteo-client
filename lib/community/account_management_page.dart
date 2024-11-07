import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/global_function.dart';
import '../config/global_widgets/base_widget.dart';
import '../config/global_widgets/global_widget.dart';
import '../config/s_text_style.dart';

class AccountManagementPage extends StatelessWidget {
  AccountManagementPage({Key? key}) : super(key: key);

  final AccountManagementController controller = Get.put(AccountManagementController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: 'Account Management Page'),
        body: GestureDetector(
          onTap: () => GlobalFunction.unFocus(context),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24 * sizeUnit),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20 * sizeUnit),
                  Text('로그인 이메일', style: STextStyle.subTitle4()),
                  SizedBox(height: 6 * sizeUnit),
                  Text(controller.email ?? '', style: STextStyle.subTitle3()),
                  SizedBox(height: 20 * sizeUnit),
                  Text('비빌번호 변경', style: STextStyle.subTitle4()),
                  SizedBox(height: 6 * sizeUnit),
                  SizedBox(height: 20 * sizeUnit),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AccountManagementController extends GetxController {
  final _authentication = FirebaseAuth.instance;
  late final String? email = _authentication.currentUser!.email;

  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController newConfirmPasswordController = TextEditingController();

  RxString currentPassword = ''.obs; // 현재 비밀번호
  RxString newPassword = ''.obs; // 새로운 비밀번호
  RxString newConfirmPassword = ''.obs; // 새로운 비밀번호 확인

  // 비밀번호 변경
  Future<void> changePassword() async {
    final User? _user = _authentication.currentUser;

    if (_user != null) {
      try {
        // 사용자 재인증
        final AuthCredential credential = EmailAuthProvider.credential(email: email ?? '', password: currentPassword.value);
        await _user.reauthenticateWithCredential(credential);

        // 기존 비밀번호와 같을경우
        if (currentPassword.value == newPassword.value) {
          return GlobalFunction.showToast(msg: '기존 비밀번호와 다르게 설정해주세요.');
        }

        await _user.updatePassword(newPassword.value); // 비밀번호 업데이트
        resetTextField(); // 텍스트필드 초기화
        return GlobalFunction.showToast(msg: '비밀번호 변경완료!');
      } catch (e) {
        if(kDebugMode) print(e.toString());
        if (e.toString() == '[firebase_auth/wrong-password] The password is invalid or the user does not have a password.') {
          return GlobalFunction.showToast(msg: '기존 비밀번호를 확인해주세요.');
        }
      }
    }
  }

  // 텍스트필드 초기화
  void resetTextField() {
    currentPassword('');
    newPassword('');
    newConfirmPassword('');
    currentPasswordController.clear();
    newPasswordController.clear();
    newConfirmPasswordController.clear();
  }
}
