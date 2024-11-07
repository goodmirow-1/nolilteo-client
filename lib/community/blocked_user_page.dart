import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../community/controllers/community_controller.dart';
import '../../config/global_widgets/base_widget.dart';

import '../config/global_function.dart';
import '../config/global_widgets/global_widget.dart';
import '../data/global_data.dart';
import '../data/user.dart';

class BlockedUserPage extends StatelessWidget {
  BlockedUserPage({Key? key, required this.userList}) : super(key: key);

  final List<User> userList;

  final CommunityController communityController = Get.find<CommunityController>();

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: 'BlockedUserPage'),
        body: ListView.builder(
          itemCount: userList.length,
          itemBuilder: (context, index) => userItem(userList[index]),
        ),
      ),
    );
  }

  Widget userItem(User user) {
    RxBool isBlock = true.obs;

    return ListTile(
      title: Text(user.nickName),
      trailing: IconButton(
        onPressed: () => blockUser(isBlock: isBlock, userID: user.id),
        icon: Obx(() => Icon(isBlock.value ? Icons.handshake_sharp : Icons.block)),
      ),
      onTap: () {},
    );
  }

  // 사용자 차단
  Future<void> blockUser({required RxBool isBlock, required int userID}) async {
    bool? result;
    // bool? result = await UserRepository.blockUser(isBlock: isBlock.value, blockedUserID: userID);

    if (result != null) {
      isBlock(result);

      if (result) {
        GlobalData.blockedUserIDList.add(userID);
        GlobalFunction.showToast(msg: '차단되었습니다.');
      } else {
        GlobalData.blockedUserIDList.removeWhere((element) => element == userID);
        GlobalFunction.showToast(msg: '차단 해제되었습니다.');
      }

      CommunityController.to.update();
    } else {
      GlobalFunction.showToast(msg: '잠시후 다시 시도해주세요.');
    }
  }
}
