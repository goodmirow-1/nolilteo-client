import 'dart:convert';

import '../data/global_data.dart';
import '../network/ApiProvider.dart';

class NotificationRepository {
  static Future<dynamic> select() async {
    var res = await ApiProvider().post(
        '/Notification/Select',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
        }));

    return res;
  }

  static Future<dynamic> update({required int id}) async {
    var res = await ApiProvider().post(
        '/Notification/Update',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "id" : id
        }));

    return res;
  }

  static Future<dynamic> unSendSelect() async {
    var res = await ApiProvider().post(
        '/Notification/UnSendSelect',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
        }));

    return res;
  }
}
