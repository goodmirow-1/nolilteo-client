
import 'package:nolilteo/config/constants.dart';
import 'package:nolilteo/config/global_function.dart';

class BlockTime{
  BlockTime({
    required this.id,
    required this.userID,
    required this.endTime,
    required this.contents,
    required this.createdAt,
    required this.updatedAt
  });

  int id;
  int userID;
  String endTime;
  String contents;
  String createdAt;
  String updatedAt;

  factory BlockTime.fromJson(Map<String, dynamic> json) {
    return BlockTime(
        id: json['id'],
        userID: json['UserID'],
        endTime: json['EndTime'],
        contents: json['Contents'],
        createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
        updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? '')
    );
  }
}

class User{
  User({
    required this.id,
    required this.nickName,
    this.wbti = '',
    this.job = '',
    this.gender,
    this.birthday,
    this.loginState,
    required this.createdAt,
    required this.updatedAt,
    this.blockTimeList,
    this.marketingAgree,
  });

  int id;
  String nickName;
  String wbti = '';
  String job = '';
  int? gender;
  String? birthday;
  int? loginState;
  String createdAt;
  String updatedAt;
  List<BlockTime>? blockTimeList;
  bool? marketingAgree;

  static const int genderMale = 1;
  static const int genderFemale = 2;
  static const int genderOther = 3;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['UserID'],
      nickName: json['NickName'] ?? '',
      wbti: json['WBTIType'] ?? '',
      job: json['Job'] ?? '',
      gender: json['Gender'],
      birthday: json['Birthday'],
      marketingAgree: json['MarketingAgree'] == null ? null : json['MarketingAgree'] as bool,
      loginState: json['LoginState'],
      createdAt: GlobalFunction.replaceDate(json['createdAt'] ?? ''),
      updatedAt: GlobalFunction.replaceDate(json['updatedAt'] ?? ''),
      blockTimeList: json['BlockTimes'] == null ? [] : (json['BlockTimes'] as List).map((e) => BlockTime.fromJson(e)).toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'UserID' : id,
    'NickName': nickName,
    'WBTIType': wbti,
    'Job' : job,
    'Gender' : gender,
    'Birthday' : birthday,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}