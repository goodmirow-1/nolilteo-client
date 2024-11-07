import 'package:get/get.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/repository/post_repository.dart';
import 'package:nolilteo/repository/user_repository.dart';
import '../../config/global_function.dart';
import '../../declare/model/declare.dart';
import 'package:flutter/material.dart';

class DeclareEditController extends GetxController {
  static get to => Get.find<DeclareEditController>();

  final ScrollController scrollController = ScrollController();
  late final int type;
  late final int declaredID;
  late final List<String> selectedReportList;
  RxString head = ''.obs;
  RxString contents = ''.obs;

  RxBool get isOk => (head.isNotEmpty && (head.value == '기타' ? contents.isNotEmpty : true)).obs;

  @override
  void onClose(){
    super.onClose();

    scrollController.dispose();
  }

  void set({required declareType, required id}) {
    type = declareType;
    declaredID = id;
    selectedReportList = declareType == Declare.declareTypeUser ? userReportList : reportList;
  }

  //신고 서버로 보내기
  void send() async {
    GlobalFunction.loadingDialog(); // 로딩 시작
    String contents = '${head.value}\n${this.contents.value}';

    // 신고
    late final bool? result;
    if (type == Declare.declareTypeUser) {
      result = await UserRepository.declare(targetID: declaredID, contents: contents); // 유저 신고
    } else {
      result = await PostRepository.declare(type: type, targetID: declaredID, contents: contents); // 게시글, 댓글, 답글 신고
    }

    if (result != null) {
      if (result) {
        GlobalFunction.showToast(msg: '신고되었습니다.');
      } else {
        GlobalFunction.showToast(msg: type == Declare.declareTypeUser? '이미 신고한 사용자입니다.' : '이미 신고한 글입니다.');
      }

      Get.back(); // 로딩 끝
      Get.back(); // 디테일 페이지로
    } else {
      Get.back(); // 로딩 끝
      GlobalFunction.showToast(msg: '잠시 후 다시 시도해 주세요.');
    }
  }
}
