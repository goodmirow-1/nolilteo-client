import 'package:nolilteo/community/models/post.dart';

import '../../config/constants.dart';

class MeetingPost extends Post {
  static const int anyGender = 0; // 아무나
  static const int onlyMale = 1; // 남자
  static const int onlyFemale = 2; // 여자

  MeetingPost({
    required super.id,
    required this.meetingID,
    required super.userID,
    required super.nickName,
    required super.category,
    super.tag = '',
    required super.title,
    required super.contents,
    super.imageUrlList = const [],
    super.type = Post.postTypeMeeting,
    super.repliesLength = 0,
    super.declareLength = 0,
    super.likesLength = 0,
    super.hitCount = 0,
    super.deleteType = deleteTypeShow,
    super.isLike = false,
    super.isWriteReply = false,
    super.isModify = false,
    required super.createdAt,
    required super.updatedAt,
    required this.location,
    this.detailLocation,
    this.url = '',
    this.meetingDate,
    this.startAge,
    this.endAge,
    this.sex = anyGender,
    this.personnel,
    this.meetingMembers = const [],
    this.isClosed = false,
  });

  int meetingID;
  String location; // 지역
  String? detailLocation; // 주소
  String url; // 모임 url
  String? meetingDate; // 모임 날짜
  int? startAge; // 연령
  int? endAge; // 연령
  int sex; // 성별 (0: 제한 없음, 1: 남자만, 2: 여자만)
  int? personnel; // 정원
  List<int> meetingMembers = []; // 참여자 id 리스트
  bool isClosed; // 모집 마감 여부 (1이 마감)

  factory MeetingPost.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    // 참여자 id 리스트 가공
    List<int> meetingMembers = [];
    if (json['gathering']['GatheringMembers'] != null) {
      for (var member in json['gathering']['GatheringMembers'] as List) {
        meetingMembers.add(member['UserID']);
      }
    }

    return MeetingPost(
      id: json['community']['id'],
      meetingID: json['gathering']['id'],
      userID: json['community']['UserID'],
      nickName: json['community']['NickName'] ?? '',
      category: json['community']['Category'] ?? '',
      tag: json['community']['Tag'] ?? '',
      title: json['community']['Title'] ?? '',
      contents: json['community']['Contents'] ?? '',
      imageUrlList: json['community']['CommunityPhotos'] == null ? [] : (json['community']['CommunityPhotos'] as List).map((e) => PostImage.fromJson(e)).toList(),
      type: json['community']['Type'] ?? Post.postTypeMeeting,
      repliesLength: json['community']['ReplyCount'] ?? 0,
      declareLength: json['community']['DeclareCount'] ?? 0,
      likesLength: json['community']['LikeCount'] ?? 0,
      hitCount: json['community']['HitCount'] ?? 0,
      deleteType: json['community']['DeleteType'] ?? deleteTypeShow,
      isLike: false,
      isWriteReply: false,
      isModify: json['community']['IsModify'] ?? false,
      location: json['community']['Location'],
      detailLocation: json['gathering']['DetailLocation'],
      url: json['gathering']['Link'] ?? '',
      meetingDate: json['gathering']['Date'],
      startAge: json['gathering']['MinAge'],
      endAge: json['gathering']['MaxAge'],
      sex: json['gathering']['NeedGender'],
      personnel: json['gathering']['MaxMemberNum'],
      meetingMembers: meetingMembers,
      isClosed: (json['gathering']['State'] ?? 0) == 0 ? false : true,
      createdAt: json['community']['createdAt'].toString(),
      updatedAt: json['community']['updatedAt'].toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'meetingID': meetingID,
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
        'isModify': isModify,
        'location': location,
        'detailLocation': detailLocation,
        'url': url,
        'meetingDate': meetingDate,
        'startAge': startAge,
        'endAge': endAge,
        'sex': sex,
        'personnel': personnel,
        'isClosed': isClosed,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  // 나이 제한
  static String? getAgeLimit({required int? startAge, required int? endAge}) {
    bool isNull(int? age) => (age == null || age == nullInt);

    return (isNull(startAge) && isNull(endAge))
        ? null
        : (startAge == endAge)
            ? '$startAge세'
            : !isNull(startAge)
                ? '$startAge세${!isNull(endAge) ? '~$endAge세' : ' 이상'}'
                : '$endAge세 이하';
  }
}
