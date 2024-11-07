import '../../config/global_function.dart';

import '../../config/constants.dart';

class Reply {
  static final Reply nullReply = Reply(id: nullInt, userID: nullInt, nickName: '', parentsID: nullInt, contents: '', createdAt: '', updatedAt: '');

  Reply({
    required this.id,
    required this.userID,
    required this.parentsID,
    this.parentsTitle = '',
    required this.nickName,
    required this.contents,
    this.likesLength = 0,
    this.deleteType = deleteTypeShow,
    this.isLike = false,
    this.isBlind = false,
    this.isModify = false,
    this.replyReplyList = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userID;
  int parentsID;
  String parentsTitle;
  String nickName;
  String contents;
  int likesLength;
  int deleteType;
  bool isLike;
  bool isBlind;
  bool isModify;
  List<ReplyReply> replyReplyList;
  String createdAt;
  String updatedAt;

  factory Reply.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    return Reply(
      id: json['reply']['id'],
      userID: json['reply']['UserID'],
      parentsID: json['reply']['PostID'] ?? 0,
      parentsTitle: json['reply']['PostTitle'] ?? '',
      nickName: json['reply']['NickName'] ?? '',
      contents: json['reply']['Contents'] ?? '',
      likesLength: json['reply']['LikeCount'] ?? 0,
      deleteType: json['reply']['DeleteType'] ?? deleteTypeShow,
      isLike: json['isLike'] ?? false,
      isBlind: GlobalFunction.blindCheck(declareLength: json['reply']['DeclareCount'] ?? 0, likeLength: json['reply']['LikeCount'] ?? 0),
      isModify: json['reply']['IsModify'] ?? false,
      replyReplyList: json['reply']['CommunityPostReplyReplies'] == null ? [] : (json['reply']['CommunityPostReplyReplies'] as List).map((e) => ReplyReply.fromJson(e)).toList(),
      createdAt: json['reply']['createdAt'].toString(),
      updatedAt: json['reply']['updatedAt'].toString(),
    );
  }

  factory Reply.simpleFromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    return Reply(
      id: json['id'],
      userID: json['UserID'],
      parentsID: json['PostID'],
      parentsTitle: json['PostTitle'] ?? '',
      nickName: json['NickName'] ?? '',
      contents: json['Contents'] ?? '',
      likesLength: json['LikeCount'] ?? 0,
      deleteType: json['DeleteType'] ?? deleteTypeShow,
      isLike: json['isLike'] ?? false,
      isBlind: GlobalFunction.blindCheck(declareLength: json['DeclareCount'] ?? 0, likeLength: json['LikeCount'] ?? 0),
      isModify: json['IsModify'] ?? false,
      replyReplyList: json['CommunityPostReplyReplies'] == null ? [] : (json['CommunityPostReplyReplies'] as List).map((e) => ReplyReply.fromJson(e)).toList(),
      createdAt: json['createdAt'].toString(),
      updatedAt: json['updatedAt'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'postID': parentsID,
        'postTitle': parentsTitle,
        'nickName': nickName,
        'contents': contents,
        'deleteType': deleteType,
        'isBlind': isBlind,
        'isModify': isModify,
        'replyReplyList': replyReplyList.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class ReplyReply extends Reply {
  ReplyReply({
    required super.id,
    required super.userID,
    required super.parentsID,
    super.parentsTitle = '',
    required super.nickName,
    required super.contents,
    super.deleteType = deleteTypeShow,
    super.isBlind = false,
    super.isModify = false,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReplyReply.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    return ReplyReply(
      id: json['id'],
      userID: json['UserID'],
      parentsID: json['ReplyID'],
      parentsTitle: json['ReplyContents'] ?? '',
      nickName: json['NickName'] ?? '',
      contents: json['Contents'] ?? '',
      deleteType: json['DeleteType'] ?? deleteTypeShow,
      isBlind: GlobalFunction.blindCheck(declareLength: json['DeclareCount'] ?? 0, likeLength: 0),
      isModify: json['IsModify'] ?? false,
      createdAt: json['createdAt'].toString(),
      updatedAt: json['updatedAt'].toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'replyID': parentsID,
        'replyContents': parentsTitle,
        'nickName': nickName,
        'contents': contents,
        'deleteType': deleteType,
        'isBlind': isBlind,
        'isModify': isModify,
        'replyReplyList': replyReplyList.map((e) => e.toJson()).toList(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
