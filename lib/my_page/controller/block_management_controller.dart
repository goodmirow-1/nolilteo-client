import 'package:get/get.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/data/global_data.dart';
import 'package:nolilteo/data/user.dart';
import 'package:nolilteo/repository/user_repository.dart';

import '../../config/global_widgets/global_widget.dart';

class BlockManagementController extends GetxController {
  bool loading = true;
  List<User> userList = [];

  Future<void> fetchData() async{
    // 유저 데이터 세팅
    for(int id in GlobalData.blockedUserIDList) {
      userList.add(await GlobalFunction.getFutureUserByID(id));
    }

    loading = false;
    update();
  }

  void unBlock(int id) {
    showCustomDialog(
      title: '차단을 해제하시겠어요?',
      okText: '해제',
      cancelText: '취소',
      isCancelButton: true,
      okFunc: () async{
        Get.back(); // 다이어로그 끄기
        bool? res = await UserRepository.unblock(targetID: id);

        if(res != null) {
          GlobalData.blockedUserIDList.remove(id);
          userList.removeWhere((element) => element.id == id);
          update();
        } else {
          GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
        }

      },
    );
  }
}