import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:nolilteo/community/community_detail_page.dart';

import '../../community/models/post.dart';
import '../../data/global_data.dart';
import '../../wbti/model/wbti_type.dart';
import '../constants.dart';
import '../global_widgets/global_widget.dart';
import '../s_text_style.dart';

class WebRightSection extends StatelessWidget {
  WebRightSection({Key? key}) : super(key: key);

  final WbtiType wbtiType = WbtiType.getType(GlobalData.loginUser.wbti);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: Padding(
        padding: EdgeInsets.only(left: 12 * sizeUnit, top: 16 * sizeUnit),
        child: Column(
          children: [
            GlobalData.loginUser.id == nullInt ? loginWidget() : userWidget(wbtiType),
            SizedBox(height: 16 * sizeUnit),
            Expanded(child: hotAndPopularListView()),
          ],
        ),
      ),
    );
  }

  // 로그인 위젯
  Container loginWidget() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 24 * sizeUnit),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: nolColorLightGrey,
          width: 1.5 * sizeUnit,
        ),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      ),
      child: noLoginInduceWidget(),
    );
  }

  // 유저 정보
  Container userWidget(WbtiType wbtiType) {
    return Container(
      padding: EdgeInsets.all(16 * sizeUnit),
      width: double.infinity,
      height: 202 * sizeUnit,
      decoration: BoxDecoration(
        border: Border.all(
          color: nolColorLightGrey,
          width: 1.5 * sizeUnit,
        ),
        borderRadius: BorderRadius.circular(14 * sizeUnit),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            GlobalData.loginUser.nickName,
            softWrap: true,
            style: STextStyle.highlight1(),
            overflow: TextOverflow.ellipsis,
          ),
          if (wbtiType.title.isNotEmpty) ...[
            SizedBox(height: 10 * sizeUnit),
            Text('${wbtiType.title} ${GlobalData.loginUser.job}', style: STextStyle.subTitle2().copyWith(color: nolColorOrange)),
          ],
          Expanded(
            child: Center(
              child: SvgPicture.asset(
                wbtiType.src,
                height: 110 * sizeUnit,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 핫, 인기 게시글
  Widget hotAndPopularListView() {
    Widget simplePostCard(Post post) {
      return InkWell(
        onTap: () => Get.toNamed('${CommunityDetailPage.route}/${post.id}'),
        child: SizedBox(
          width: 250 * sizeUnit,
          height: 32 * sizeUnit,
          child: Row(
            children: [
              nolTag(post.type == Post.postTypeWbti ? WbtiType.getType(post.category).name : post.category),
              SizedBox(width: 4 * sizeUnit),
              Expanded(
                child: Text(
                  post.title,
                  style: STextStyle.body4(),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${DateTime.now().hour.toString()}시 HOT 순위',
            style: STextStyle.highlight1(),
          ),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => Column(
                children: List.generate(
                  GlobalData.hotListByHour.length,
                  (index) => simplePostCard(GlobalData.hotListByHour[index]),
                ),
              )),
          SizedBox(height: 16 * sizeUnit),
          Text(
            '전체 인기글',
            style: STextStyle.highlight1(),
          ),
          SizedBox(height: 8 * sizeUnit),
          Obx(() => Column(
                children: List.generate(
                  GlobalData.popularListByRealTime.length,
                  (index) => simplePostCard(GlobalData.popularListByRealTime[index]),
                ),
              )),
        ],
      ),
    );
  }
}
