class Like{
  Like({
    required this.id,
    required this.userID,
    required this.postID,
    required this.createdAt,
    required this.updatedAt,
  });

  int id;
  int userID;
  int postID;
  String createdAt;
  String updatedAt;

  factory Like.fromJson(Map<String, dynamic> json, {bool isHot = false, bool isNotice = false}) {
    return Like(
      id: json['id'],
      userID: json['userID'],
      postID: json['postID'],
      createdAt: json['createdAt'].toDate().toString(),
      updatedAt: json['updatedAt'].toDate().toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id' : id,
    'userID' : userID,
    'postID' : postID,
    'createdAt' : createdAt,
    'updatedAt' : updatedAt,
  };
}