import 'package:nolilteo/network/ApiProvider.dart';

import 'package:flutter_chat_types/flutter_chat_types.dart' show PreviewData;
import '../../config/constants.dart';

class Post {
  static const int postTypeTopic = 0; // 놀터
  static const int postTypeJob = 1; // 일터
  static const int postTypeMeeting = 2; // 모여라
  static const int postTypeWbti = 3; // wbti

  Post({
    required this.id,
    required this.userID,
    required this.nickName,
    required this.category,
    this.tag = '',
    required this.title,
    required this.contents,
    this.imageUrlList = const [],
    this.type = postTypeTopic,
    this.repliesLength = 0,
    this.declareLength = 0,
    this.likesLength = 0,
    this.hitCount = 0,
    this.deleteType = deleteTypeShow,
    this.isLike = false,
    this.isWriteReply = false,
    this.isSubscribe = false,
    this.isHot = false,
    this.isModify = false,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userID;
  String nickName;
  String category;
  String tag;
  String title;
  String contents;
  List<PostImage> imageUrlList;
  int type;
  int repliesLength;
  int declareLength;
  int likesLength;
  int hitCount;
  int deleteType;
  bool isLike;
  bool isWriteReply;
  bool isSubscribe;
  bool isHot;
  bool isModify;
  String createdAt;
  String updatedAt;
  PreviewData? previewData;

  factory Post.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    return Post(
      id: json['community']['id'],
      userID: json['community']['UserID'],
      nickName: json['community']['NickName'] ?? '',
      category: json['community']['Category'] ?? '',
      tag: json['community']['Tag'] ?? '',
      title: json['community']['Title'] ?? '',
      contents: json['community']['Contents'] ?? '',
      imageUrlList: json['community']['CommunityPhotos'] == null ? [] : (json['community']['CommunityPhotos'] as List).map((e) => PostImage.fromJson(e)).toList(),
      type: json['community']['Type'] ?? postTypeTopic,
      repliesLength: json['community']['ReplyCount'] ?? 0,
      declareLength: json['community']['DeclareCount'] ?? 0,
      likesLength: json['community']['LikeCount'] ?? 0,
      hitCount: json['community']['HitCount'] ?? 0,
      deleteType: json['community']['DeleteType'] ?? deleteTypeShow,
      isLike: json['isLike'] ?? false,
      isWriteReply: json['isReply'] ?? false,
      isSubscribe: json['isSubscribe'] ?? false,
      isHot: isHot,
      isModify: json['community']['IsModify'] ?? false,
      createdAt: json['community']['createdAt'].toString(),
      updatedAt: json['community']['updatedAt'].toString(),
    );
  }

  factory Post.simpleFromJson(Map<String, dynamic> json, {bool isHot = false}) => Post(
        id: json['id'],
        title: json['Title'],
        category: json['Category'],
        tag: json['Tag']  ?? '',
        userID : json['UserID'] ?? nullInt,
        type: json['Type'] ?? 0,
        isHot: isHot,
        nickName: '',
        contents: '',
        createdAt: '',
        updatedAt: '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'nickName': nickName,
        'category': category,
        'tag': tag,
        'title': title,
        'contents': contents,
        'imageUrlList': imageUrlList,
        'type': type,
        'repliesLength': repliesLength,
        'declareLength': declareLength,
        'likesLength': likesLength,
        'hitCount': hitCount,
        'deleteType': deleteType,
        'isLike': isLike,
        'isWriteReply': isWriteReply,
        'isSubscribe': isSubscribe,
        'isHot': isHot,
        'isModify': isModify,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}

class PostImage {
  PostImage({required this.id, required this.url, this.description, required this.width, required this.height});

  final int id;
  final String url;
  final String? description;
  final int width;
  final int height;

  factory PostImage.fromJson(Map<String, dynamic> json) => PostImage(
        id: json['id'],
        url: '${ApiProvider().getImgUrl}/${json['ImageURL']}',
        description: json['Description'] ?? '',
        width: json['Width'] == 0 ? 360 : json['Width'],
        height: json['Height'] == 0 ? 360 : json['Height'],
      );
}
