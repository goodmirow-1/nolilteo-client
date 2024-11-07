
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'package:nolilteo/config/global_function.dart';
import '../config/constants.dart';
import '../data/global_data.dart';
import 'CustomException.dart';

/*
class Response<T> {
  Status status;
  T data;
  String message;

  Response.loading(this.message) : status = Status.LOADING;
  Response.completed(this.data) : status = Status.COMPLETED;
  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }
}
*/

enum Status { LOADING, COMPLETED, ERROR }

class ApiProvider {
  final String _baseUrl = kReleaseMode == false ? "http://192.168.2.168:" : !kIsWeb ? "http://nolilteo.com:" : "http://nolilteo.com:"; //서버 붙는 위치
  final String _imageUrl = kReleaseMode == false ? "http://192.168.2.168:" : !kIsWeb ? "http://nolilteo.com:" : "http://nolilteo.com:";
  final String port = kReleaseMode == false ? "50100" : !kIsWeb ? "50100" : "50100";                       //기본 포트
  final String authPort = kReleaseMode == false ? "50100" : "50100";
  String get getUrl => _baseUrl + port;
  String get getImgUrl => _imageUrl + port;
  //get
  Future<dynamic> get(String url) async {
    var responseJson;

    var uri = Uri.parse(_baseUrl + port + url);

    HttpClient httpClient = HttpClient();
    httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

    IOClient ioClient = IOClient(httpClient);

    try {
      final response = await ioClient.get(uri,
        headers: {
          'Content-Type' : 'application/json',
          'user' : GlobalData.loginUser.id == nullInt ? 'nolilteoToken' : GlobalData.loginUser.id.toString() ,
          'accessToken' : GlobalData.accessToken
        },);

      if(response.body == "") return null;

      responseJson = _response(response);
    } on SocketException {
      throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
    }
    return responseJson;
  }

  //post
  Future<dynamic> post(String url, dynamic data, {bool isAuth = false}) async{
    var responseJson;

    String tempUri = _baseUrl + port;

    if(isAuth) tempUri = "https://nolilteo.com:$authPort";

    var uri = Uri.parse(tempUri + url);

    if(kIsWeb){
      try {
        final response = await http.post(uri,
            headers: {
              'Content-Type' : 'application/json',
              'user' : GlobalData.loginUser.id == nullInt ? 'nolilteoToken' : GlobalData.loginUser.id.toString() ,
              'accessToken' : GlobalData.accessToken,
            },
            body: data,
            encoding: Encoding.getByName('utf-8'));

        if(response.body == "" || response.body == null) return null;

        responseJson = _response(response);
      } on SocketException {
        throw FetchDataException('인터넷 접속이 원활하지 않습니다.');
      }
    }else {
      HttpClient httpClient = HttpClient();
      httpClient.badCertificateCallback = (X509Certificate cert, String host, int port) => true;

      IOClient ioClient = IOClient(httpClient);

      try {
        final response = await ioClient.post(uri,
            headers: {
              'Content-Type' : 'application/json',
              'user' : GlobalData.loginUser.id == nullInt ? 'nolilteoToken' : GlobalData.loginUser.id.toString() ,
              'accessToken' : GlobalData.accessToken
            },
            body: data,
            encoding: Encoding.getByName('utf-8'));

        if(response.body == "") return null;

        responseJson = _response(response);
      } on SocketException {
        throw FetchDataException('인터넷 접속이 원활하지 않습니다');
      }
    }

    return responseJson;
  }

  dynamic _response(http.Response response) {
    if(kDebugMode) print(response.statusCode.toString());

    switch (response.statusCode) {
      case 200:
        var responseJson = json.decode(response.body.toString());
        if(kDebugMode) print(responseJson.toString());
        return responseJson;
      case 400:
      //throw BadRequestException(response.body.toString());
        BadRequestException(response.body.toString());
        return null;
      case 401: //토큰 정보 실패
        BadRequestException(response.body.toString());
        return null;
      case 403:
      //throw UnauthorisedException(response.body.toString());
        BadRequestException(response.body.toString());
        return null;
      case 404: //토큰 정보 실패
        GlobalFunction.globalLogout(isSend: false);
        throw BadRequestException('토큰 정보가 존재하지 않습니다.');
        return null;
      case 429: //API 한도 초과
        throw BadRequestException("너무 잦은 요청으로 1시간동안 사용이 제한됩니다.");
      case 500:
        return null;
      default:
      //throw FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
        FetchDataException('Error occured while Communication with Server with StatusCode : ${response.statusCode}');
        return null;
    }
  }
}