import 'dart:convert';

import 'package:nolilteo/data/global_data.dart';

import '../network/ApiProvider.dart';

class UserRepository {
  // 회원가입
  static Future<dynamic> insert({required String email, required String nickName, required String wbtiType, required String job, required int loginType, required bool marketingAgree}) async {
    var res = await ApiProvider().post(
        '/User/Insert',
        jsonEncode({
          "email": email,
          "nickName": nickName,
          "wbtiType": wbtiType,
          "job": job,
          "loginType": loginType,
          "marketingAgree": marketingAgree
        }));

    return res;
  }

  // 로그인
  static Future<dynamic> login({required String email, required int loginType}) async {
    var res = await ApiProvider().post(
        '/User/Login',
        jsonEncode({
          "email": email,
          "loginType": loginType,
        }));

    return res;
  }

  //관리자 로그인
  static Future<dynamic> adminLogin({required String email,required String pw}) async {
    var res = await ApiProvider().post(
        '/User/Admin/Login',
        jsonEncode({
          "email": email,
          "pw": pw,
        }));

    return res;
  }

  //로그아웃
  static Future<dynamic> logout({required int userID}) async {
    var res = await ApiProvider().post(
        '/User/Logout',
        jsonEncode({
          "userID": userID,
        }));

    return res;
  }

  //프로필 수정
  static Future<dynamic> edit({required int id, required String nickName, required String wbtiType, required String job, required int? gender,required String? birthday}) async {
    var res = await ApiProvider().post(
        '/User/EditInfo',
        jsonEncode({
          "userID": id,
          "nickName": nickName,
          "wbtiType": wbtiType,
          "job": job,
          "gender": gender,
          "birthday": birthday,
        }));

    return res;
  }

  //알림 수정
  static Future<dynamic> editAlarm({required int id, required bool playAlarm, required bool workAlarm, required bool gatherAlarm, required bool subscribeAlarm, required bool recommendAlarm}) async {
    var res = await ApiProvider().post(
        '/Fcm/DetailAlarmSetting',
        jsonEncode({
          "userID": id,
          "playAlarm": playAlarm,
          "workAlarm": workAlarm,
          "gatherAlarm": gatherAlarm,
          "subscribeAlarm": subscribeAlarm,
          "recommendAlarm": recommendAlarm
        }));

    return res;
  }

  //탈퇴하기
  static Future<dynamic> exitMember({required int userID, required int type, required String contents}) async {
    var res = await ApiProvider().post(
        '/User/Exit/Member',
        jsonEncode({
          "userID": userID,
          "type" : type,
          "contents" : contents
        }));

    return res;
  }

  //닉네임 중복체크
  static Future<dynamic> checkNickName({required String nickName}) async {
    var res = await ApiProvider().post(
        '/User/Check/NickName',
        jsonEncode({
          "nickName" : nickName
        }));

    return res;
  }

  // 밴 리스트
  static Future<List<int>> getBanList() async {
    List<int> list = [];

    var res = await ApiProvider().post(
        '/User/Select/BanList',
        jsonEncode({
          "userID" : GlobalData.loginUser.id,
        }));

    if(res != null) {
      for(var json in res) {
        list.add(json['TargetID']);
      }
    }

    return list;
  }

  // 유저 차단
  static Future<bool?> userBan({required int targetID}) async {
    var res = await ApiProvider().post(
        '/User/Insert/BanUser',
        jsonEncode({
          "userID" : GlobalData.loginUser.id,
          "targetID" : targetID,
        }));

    return res;
  }

  // 유저 차단 취소
  static Future<bool?> unblock({required int targetID}) async {
    var res = await ApiProvider().post(
        '/User/Delete/BanUser',
        jsonEncode({
          "userID" : GlobalData.loginUser.id,
          "targetID" : targetID,
        }));

    return res;
  }

  // 사용자 신고
  static Future<bool?> declare({required int targetID, required String contents}) async {
    var result = await ApiProvider().post(
        '/User/Declare',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "targetID": targetID,
          "contents": contents,
        }));

    return result[1];
  }

  //otp generate
  static Future<String> otpGenerate() async {
    var result = await ApiProvider().post(
        '/OTP/Generate',
        jsonEncode({
          "loginType": 2,
        }),
        isAuth: true
    );

    return result["otp"];
  }

  //otp
  static Future<bool?> otpCheck({required String otp}) async {
    var result = await ApiProvider().post(
        '/OTP/Check',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          'secret' : otp
        }),
        isAuth: true
    );

    return result;
  }

  //otp login
  static Future<dynamic> otpLogin({required String otp}) async {
    var result = await ApiProvider().post(
        '/OTP/Login',
        jsonEncode({
          'secret' : otp
        }),
        isAuth: true
    );

    return result;
  }
}
