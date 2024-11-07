import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:share_plus/share_plus.dart';

import '../config/global_function.dart';
import '../config/global_widgets/global_widget.dart';
import '../data/global_data.dart';

//다이나믹링크 받는 함수
void initDynamicLinks() async {
  //앱이 켜져있을때 딥링크 받은 경우
  FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) {
    Get.toNamed(dynamicLinkData.link.path);
  }).onError((error) {
    GlobalFunction.showToast(msg: 'onLinkError${error.message}');
    if (kDebugMode) {
      print('onLinkError ${error.message}');
    }
  });

  //앱이 켜지며 받은 딥링크
  final PendingDynamicLinkData? initialLink = await FirebaseDynamicLinks.instance.getInitialLink();

  if (initialLink != null) {
    final Uri deepLink = initialLink.link;
    GlobalData.dynamicLink = deepLink.path; // 다이나믹링크 저장
  }
}

void shareLink({required String routeInfo, String contents = ""}) {
  showCustomDialog(
      title: '공유하기',
      okText: '앱 링크',
      isCancelButton: true,
      cancelText: '웹 링크',
      okFunc: () async {
        Get.back(); // 다이어로그 끄기
        final dynamicLinkParams = DynamicLinkParameters(
          link: Uri.parse("https://www.nolilteo.com$routeInfo"),
          uriPrefix: "https://nolilteo.page.link",
          androidParameters: const AndroidParameters(packageName: "kr.sheeps.nolilteo"),
          iosParameters: const IOSParameters(bundleId: "kr.sheeps.nolilteo"), //ios 변경 필요
        );
        final dynamicLink = await FirebaseDynamicLinks.instance.buildShortLink(dynamicLinkParams);
        if(kDebugMode) print(dynamicLink.shortUrl.toString());
        String preContents = "WBTI, 일할 때 나의 성격유형";
        if (contents.isNotEmpty) {
          preContents += '\n$contents';
        }
        Share.share('$preContents\n${dynamicLink.shortUrl}'); //앱 다이나믹링크 공유
      },
      cancelFunc: () {
        Get.back(); // 다이어로그 끄기
        Share.share('https://nolilteo.com$routeInfo'); //웹 url 공유
      });
}
