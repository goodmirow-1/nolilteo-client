class TagPreview {
  TagPreview({required this.tag, required this.postType, required this.count});

  final String tag;
  final int postType;
  final int count;

  factory TagPreview.fromJson(Map<String, dynamic> json) => TagPreview(
        tag: json['tag'],
        postType: json['postType'],
        count: json['count'],
      );
}


class TagTableData {
  TagTableData({required this.id,required this.name, required this.playCount, required this.workCount, required this.gatherCount, required this.wbtiCount});

  final int id;
  final String name;
  final int playCount;
  final int workCount;
  final int gatherCount;
  final int wbtiCount;


  factory TagTableData.fromJson(Map<String, dynamic> json) => TagTableData(
    id: json['id'],
    name: json['Name'],
    playCount: json['PlayCount'],
    workCount: json['WorkCount'],
    gatherCount: json['GatherCount'],
    wbtiCount: json['WbtiCount'],
  );
}
