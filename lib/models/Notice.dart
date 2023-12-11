/// 공지 객체
class Notice {
  late String noticeCode;
  late String title;
  late String url;
  late String updateTime;
  late String timeLimit;

  Notice({
    String noticeCode = "",
    String title = "",
    String url = "",
    String updateTime = "",
    String timeLimit = "",
  }) : noticeCode = noticeCode,
  title = title,
  url = url,
  updateTime = updateTime,
  timeLimit = timeLimit;

  void setNoticeCode(String code) {
    this.noticeCode = code;
  }
  String getNoticeCode() {
    return noticeCode;
  }

  void setTitle(String title) {
    this.title = title;
  }
  String getTitle() {
    return title;
  }

  void setUrl(String url) {
    this.url = url;
  }
  String getUrl() {
    return url;
  }

  void setUpdateTime(String time) {
    this.updateTime = time;
  }
  String getUpdateTime() {
    return updateTime;
  }

  void setTimeLimit(String time) {
    this.timeLimit = time;
  }
  String getTimeLimit() {
    return timeLimit;
  }

  Map<String, dynamic> toJson() => {
    'noticeCode': noticeCode,
    'title': title,
    'url': url,
    'updateTime': updateTime,
    'timeLimit': timeLimit,
  };

  factory Notice.fromJson(json) {
    var notice = Notice(
      noticeCode: json['noticeCode'] ?? "",
      title: json['title'] ?? "",
      url: json['url'] ?? "",
      updateTime: json['updateTime'] ?? "",
      timeLimit: json['timeLimit'] ?? "",
    );

    return notice;
  }
}
