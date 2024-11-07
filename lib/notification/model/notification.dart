
import 'package:nolilteo/config/global_function.dart';

import '../../config/constants.dart';

class NotificationModel {
  int id;
  int to;
  int from;
  String title;
  String nickName;
  int type;
  int tableIndex;
  int subTableIndex;
  int cType;
  bool isSend;
  bool isRead;
  bool isLoad;
  String createdAt;
  String updatedAt;

  NotificationModel({
    this.id = nullInt,
    this.to = nullInt,
    this.from = nullInt,
    this.title = '',
    this.nickName = '',
    this.type = nullInt,
    this.tableIndex = nullInt,
    this.subTableIndex = nullInt,
    this.cType = 0,
    this.isSend = false,
    this.isRead = false,
    this.isLoad = false,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {

    String subData = json['SubData'] ?? '';

    return NotificationModel(
      id : json['id'] ?? nullInt,
      to : json['TargetID'] ?? nullInt,
      from: json['UserID'] ?? nullInt,
      title: json['Title'] ?? '',
      nickName: json['NickName'] ?? '',
      type: json['Type'] ?? nullInt,
      tableIndex: int.parse(subData.split('|')[0]),
      subTableIndex: int.parse(subData.split('|')[1]),
      cType: int.parse(subData.split('|')[2]),
      isSend: json['isSend'] ?? false,
      isRead: false,
      isLoad: false,
      createdAt: GlobalFunction.replaceDateToDateTime(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDateToDateTime(json['updatedAt'] ?? '')
    );
  }
}