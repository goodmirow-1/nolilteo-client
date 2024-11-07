import 'package:flutter/services.dart';

import '../config/global_function.dart';

//다이나믹링크 받는 함수
void initDynamicLinks() {
  //do nothing
}

void shareLink({required String routeInfo, String contents = ""}) {
  //do share link
  String url = 'https://nolilteo.com$routeInfo';
  Clipboard.setData(ClipboardData(text: url));
  GlobalFunction.showToast(msg: 'url이 클립보드에 복사되었습니다.');
}
