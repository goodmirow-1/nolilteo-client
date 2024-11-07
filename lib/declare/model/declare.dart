
class Declare {
  static const int declareTypePost = 0; // 게시글
  static const int declareTypeReply = 1; // 댓글
  static const int declareTypeReplyReply = 2; // 답글
  static const int declareTypeUser = 4; // 유저

  Declare({
    required this.id,
    required this.userID,
    required this.type,
    required this.declaredID,
    required this.contents,
    required this.isProcessed,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userID;
  int type;
  int declaredID;
  String contents;
  bool isProcessed;
  String createdAt;
  String updatedAt;

  factory Declare.fromJson(Map<String, dynamic> json, {required int declareType}) {
    return Declare(
      id: json['id'],
      userID: json['userID'],
      type: declareType,
      declaredID: json['declaredID'],
      contents: json['contents'] ?? '',
      isProcessed: json['isProcessed'] ?? false,
      createdAt: json['createdAt'].toDate().toString(),
      updatedAt: json['updatedAt'].toDate().toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userID': userID,
        'declaredID': declaredID,
        'contents': contents,
        'isProcessed': isProcessed,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
