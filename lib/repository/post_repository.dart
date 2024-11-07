import 'dart:convert';

import 'package:nolilteo/community/models/post.dart';
import 'package:nolilteo/config/global_function.dart';
import 'package:nolilteo/network/ApiProvider.dart';
import 'package:dio/dio.dart';

import '../community/models/reply.dart';
import '../data/global_data.dart';
import '../data/tag_preview.dart';
import '../meeting/model/meeting_post.dart';

class PostRepository {
  static const int postLimit = 30; // 게시글 갯수 제한
  static const int replyLimit = 30; // 댓글 갯수 제한
  static const int postType = 0; // 게시글
  static const int replyType = 1; // 댓글
  static const int replyReplyType = 2; // 답글

  // 게시글 리스트 받아오기 (type -> 0:놀터, 1:일터, 2:모여라, 3: wbti)
  static Future<List<Post>> getPostList({
    required int type,
    required bool needAll,
    int index = 0,
    String categoryText = '',
    String tagText = '',
    String locationText = '',
  }) async {
    List<Post> list = [];

    var result = await ApiProvider().post(
        '/Community/Select',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
          "type": type,
          "categoryList": categoryText,
          "tagList": tagText,
          "locationList": locationText,
          "needAll": needAll == false ? 0 : 1,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(type == Post.postTypeMeeting ? MeetingPost.fromJson(json) : Post.fromJson(json));
      }
    }

    return list;
  }

  // 핫 게시글 리스트 받아오기 (type -> 0:놀터, 1:일터, 2:모여라)
  static Future<List<Post>> getHotPostList({required int type, int index = 0, String categoryText = '', String tagText = ''}) async {
    List<Post> list = [];

    var result = await ApiProvider().post(
        '/Community/Select/HotList',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
          "type": type,
          "categoryList": categoryText,
          "tagList": tagText,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json, isHot : true));
      }
    }

    return list;
  }

  // 인기 게시글 리스트 받아오기 (type -> 0:놀터, 1:일터, 2:모여라)
  static Future<List<Post>> getPopularPostList({required int type, int index = 0, String categoryText = '', String tagText = '', int limit = postLimit}) async {
    List<Post> list = [];

    var result = await ApiProvider().post(
        '/Community/Select/PopularList',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
          "type": type,
          "categoryList": categoryText,
          "tagList": tagText,
          "limit": limit,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json));
      }
    }

    return list;
  }

  // 게시글 id로 받아오기
  static Future<Post?> getPostByID(int id) async {
    var result = await ApiProvider().post(
        '/Community/Select/ID',
        jsonEncode({
          "id": id,
          "userID": GlobalData.loginUser.id,
        }));

    if (result == null) {
      return null;
    } else {
      return result['community']['Type'] == Post.postTypeMeeting ? MeetingPost.fromJson(result) : Post.fromJson(result);
    }
  }

  // 댓글 postID로 받아오기
  static Future<List<Reply>> getReplyListByID({required int id, int index = 0, int limit = replyLimit}) async {
    List<Reply> list = [];

    var result = await ApiProvider().post(
        '/Community/Select/Detail',
        jsonEncode({
          "id": id,
          "index": index,
          "limit": limit,
          "userID": GlobalData.loginUser.id,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(Reply.fromJson(json));
      }
    }

    return list;
  }

  // 게시글 좋아요
  static Future<bool?> postLike(int id, int postType) async {
    var result = await ApiProvider().post(
        '/Community/Insert/Like',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "nickName": GlobalData.loginUser.nickName,
          "postID": id,
          "type": postType,
        }));

    if (result == null) {
      return null;
    } else {
      return result['created'];
    }
  }

  // 게시글 삭제 (0: 게시글, 1: 댓글, 2: 답글)
  static Future<bool?> delete({required int id, required int postType}) async {
    var result = await ApiProvider().post(
        '/Community/Delete',
        jsonEncode({
          "id": id,
          "postType": postType,
        }));

    return result;
  }

  // 댓글 쓰기
  static Future<Reply?> writeReply({required int id, required String contents, required bool agree}) async {
    var result = await ApiProvider().post(
        '/Community/Insert/Reply',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "nickName": GlobalFunction.getFullNickName(GlobalData.loginUser),
          "postID": id,
          "contents": contents,
          "agree" : agree
        }));

    if (result == null) {
      return null;
    } else {
      return Reply.simpleFromJson(result);
    }
  }

  // 댓글 수정
  static Future<bool?> modifyReply({required int id, required String contents}) async {
    var result = await ApiProvider().post(
        '/Community/Modify/Reply',
        jsonEncode({
          "id": id,
          "contents": contents,
        }));

    return result;
  }

  // 댓글 좋아요
  static Future<bool?> replyLike({required int postID, required int replyID}) async {
    var result = await ApiProvider().post(
        '/Community/Insert/Reply/Like',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "nickName": GlobalData.loginUser.nickName,
          "postID": postID,
          "replyID": replyID,
        }));

    if (result == null) {
      return null;
    } else {
      return result['created'];
    }
  }

  // 답글 쓰기
  static Future<ReplyReply?> writeReplyReply({required int replyID, required String contents}) async {
    var result = await ApiProvider().post(
        '/Community/Insert/ReplyReply',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "nickName": GlobalFunction.getFullNickName(GlobalData.loginUser),
          "replyID": replyID,
          "contents": contents,
        }));

    if (result == null) {
      return null;
    } else {
      return ReplyReply.fromJson(result);
    }
  }

  // 답글 수정
  static Future<bool?> modifyReplyReply({required int id, required String contents}) async {
    var result = await ApiProvider().post(
        '/Community/Modify/ReplyReply',
        jsonEncode({
          "id": id,
          "contents": contents,
        }));

    return result;
  }

  static Future<List<Post>> getTitleSearch({required int index, required String keywords}) async {
    var result = await ApiProvider().post(
        '/Community/Search/Contents',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
          "keywords": keywords,
        }));

    List<Post> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json));
      }
    }

    return list;
  }

  static Future<List<MeetingPost>> getGatheringTitleSearch({required int index, required String keywords}) async {
    var result = await ApiProvider().post('/Community/Search/Gathering/Contents', jsonEncode({"userID": GlobalData.loginUser.id, "index": index, "keywords": keywords}));

    List<MeetingPost> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(MeetingPost.fromJson(json));
      }
    }

    return list;
  }

  static Future<List<TagPreview>> getTagSearch({required int index, required String name, int? type}) async {
    var result = await ApiProvider().post(
        '/Community/Search/Tag',
        jsonEncode({
          "index": index,
          "name": name,
        }));

    List<TagPreview> tagPreviewList = [];

    if (result != null) {
      for (var json in result) {
        TagTableData tagTableData = TagTableData.fromJson(json);

        if ((type == null || type == Post.postTypeTopic) && tagTableData.playCount > 0) {
          TagPreview tagPreview = TagPreview(tag: tagTableData.name, postType: Post.postTypeTopic, count: tagTableData.playCount);
          tagPreviewList.add(tagPreview);
        }

        if ((type == null || type == Post.postTypeJob) && tagTableData.workCount > 0) {
          TagPreview tagPreview = TagPreview(tag: tagTableData.name, postType: Post.postTypeJob, count: tagTableData.workCount);
          tagPreviewList.add(tagPreview);
        }

        // if ((type == null || type == Post.postTypeMeeting) && tagTableData.gatherCount > 0) {
        //   TagPreview tagPreview = TagPreview(tag: tagTableData.name, postType: Post.postTypeMeeting, count: tagTableData.gatherCount);
        //   tagPreviewList.add(tagPreview);
        // }

        if ((type == null || type == Post.postTypeWbti) && tagTableData.wbtiCount > 0) {
          TagPreview tagPreview = TagPreview(tag: tagTableData.name, postType: Post.postTypeWbti, count: tagTableData.wbtiCount);
          tagPreviewList.add(tagPreview);
        }
      }
    }

    return tagPreviewList;
  }

  static Future<List<Post>> getTagPlayOrWorkPost({required String tag, required int index, required int type}) async {
    var result = await ApiProvider().post(
        '/Community/Search/Gathering/Contents',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "tag": tag,
          "index": index,
          "type": type,
        }));

    List<Post> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json));
      }
    }

    return list;
  }

  static Future<List<MeetingPost>> getTagGatherPost({required String tag, required int index}) async {
    var result = await ApiProvider().post(
        '/Community/Search/Gathering/Contents',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "tag": tag,
          "index": index,
          "type": 2,
        }));

    List<MeetingPost> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(MeetingPost.fromJson(json));
      }
    }

    return list;
  }

  // 모여라 참가하기
  static Future<bool?> participate(int id) async {
    var result = await ApiProvider().post(
        '/Community/Gathering/Join',
        jsonEncode({
          "id": id,
          "userID": GlobalData.loginUser.id,
        }));

    return result;
  }

  // 모여라 나가기
  static Future<bool?> exitMeeting(int meetingID) async {
    var result = await ApiProvider().post(
        '/Community/Gathering/Leave',
        jsonEncode({
          "gatheringID": meetingID,
          "userID": GlobalData.loginUser.id,
        }));

    return result;
  }

  // 모여라 마감
  static Future<bool?> closeMeeting(int meetingID) async {
    var result = await ApiProvider().post(
        '/Community/Gathering/Close',
        jsonEncode({
          "id": meetingID,
        }));

    return result;
  }

  // 글쓰기
  static Future<Post?> writeOrModify({required FormData formData, required bool isMeeting}) async {
    Dio dio = Dio();

    var res = await dio.post('${ApiProvider().getUrl}/Community/InsertOrModify', data: formData);
    var result = json.decode(res.toString());

    if (result != null) {
      if (isMeeting) {
        result = MeetingPost.fromJson(result);
      } else {
        result = Post.fromJson(result);
      }
    }

    return result;
  }

  static Future<List<Post>> getPostListByUserID({required int targetID, required int type, required int index}) async {
    var result = await ApiProvider().post(
        '/Community/Select/PlayWork/UserID',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "targetID": targetID,
          "index": index,
          "type": type,
        }));

    List<Post> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json));
      }
    }

    return list;
  }

  static Future<List<Post>> getLikesPost({required int type, required int index}) async {
    var result = await ApiProvider().post(
        '/Community/Select/LikeList',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
          "type": type,
        }));

    List<Post> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(Post.fromJson(json));
      }
    }

    return list;
  }

  static Future<List<MeetingPost>> getMeetingPostListByUserID({required int index, required int userID}) async {
    var result = await ApiProvider().post(
        '/Community/Select/GatheringList',
        jsonEncode({
          "userID": userID,
          "index": index,
        }));

    List<MeetingPost> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(MeetingPost.fromJson(json));
      }
    }

    return list;
  }

  // 신고
  static Future<bool?> declare({required int type, required int targetID, required String contents}) async {
    var result = await ApiProvider().post(
        '/Community/Declare',
        jsonEncode({
          "postType": type,
          "userID": GlobalData.loginUser.id,
          "targetID": targetID,
          "contents": contents,
        }));

    return result[1];
  }

  //내 댓글 가져오기
  static Future<List<Reply>> getReplyList({required int index}) async {
    var result = await ApiProvider().post(
        '/Community/Select/ReplyList',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
        }));

    List<Reply> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(Reply.fromJson(json));
      }
    }

    return list;
  }

  //내 댓글 가져오기
  static Future<List<ReplyReply>> getReplyReplyList({required int index}) async {
    var result = await ApiProvider().post(
        '/Community/Select/ReplyReplyList',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "index": index,
        }));

    List<ReplyReply> list = [];
    if (result != null) {
      for (var json in result) {
        list.add(ReplyReply.fromJson(json));
      }
    }

    return list;
  }

  // 댓글 데이터 가져오기
  static Future<Reply?> getReplyByID(int replyID) async {
    var result = await ApiProvider().post(
        '/Community/Select/ReplyDetail',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "replyID": replyID,
        }));

    if (result == null) return null;
    return Reply.fromJson(result);
  }
  
  static Future<bool> subscribeCreateOrDestroy({required int postID, required bool isCreate}) async {
    var result = await ApiProvider().post(
        '/Community/Subscriber/CreateOrDestroy',
        jsonEncode({
          "userID": GlobalData.loginUser.id,
          "postID": postID,
          "isCreate" : isCreate
        }));

    return result;
  }

  // 시간별 핫 리스트 받아오기
  static Future<List<Post>> getHotPostListByHour({int index = 0, limit = 10}) async {
    List<Post> list = [];

    var result = await ApiProvider().post(
        '/Community/Select/HotList/ByHour',
        jsonEncode({
          "index": index,
          "limit": limit,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(Post.simpleFromJson(json, isHot : true));
      }
    }

    return list;
  }

  // 실시간 인기 리스트 받아오기
  static Future<List<Post>> getPopularListByRealTime({int index = 0, limit = 10}) async {
    List<Post> list = [];

    var result = await ApiProvider().post(
        '/Community/Select/PopularList/ByNow',
        jsonEncode({
          "index": index,
          "limit": limit,
        }));

    if (result != null) {
      for (var json in result) {
        list.add(Post.simpleFromJson(json));
      }
    }

    return list;
  }
}
