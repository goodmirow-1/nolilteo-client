import 'package:flutter/material.dart';
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_widgets/base_widget.dart';
import 'package:nolilteo/config/global_widgets/global_widget.dart';
import 'package:nolilteo/data/user.dart';
import 'package:nolilteo/my_page/controller/block_management_controller.dart';
import 'package:get/get.dart';
import 'package:nolilteo/wbti/model/wbti_type.dart';

import '../config/s_text_style.dart';

class BlockManagementPage extends StatelessWidget {
  BlockManagementPage({Key? key}) : super(key: key);

  final BlockManagementController controller = Get.put(BlockManagementController());

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: Scaffold(
        appBar: customAppBar(context, title: '차단관리',centerTitle: false),
        body: GetBuilder<BlockManagementController>(
            initState: (_) => controller.fetchData(),
            builder: (_) {
              if (controller.loading) return const Center(child: CircularProgressIndicator(color: nolColorOrange));

              return Column(
                children: [
                  buildLine(),
                  SizedBox(height: 8 * sizeUnit),
                  Expanded(
                    child: ListView.builder(
                      itemCount: controller.userList.length,
                      itemBuilder: (context, index) => listItem(controller.userList[index]),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }

  Widget listItem(User user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * sizeUnit, vertical: 14 * sizeUnit),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nickName,
                  style: STextStyle.subTitle1(),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8 * sizeUnit),
                Text(
                  '${WbtiType.getType(user.wbti).title} ${user.job}',
                  style: STextStyle.subTitle2().copyWith(color: nolColorOrange),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: () => controller.unBlock(user.id),
            child: Text('차단해제', style: STextStyle.body3().copyWith(color: nolColorGrey)),
          ),
        ],
      ),
    );
  }
}
