// 여행그룹 객체
import 'dart:convert';

import 'package:go_together/models/Schedule.dart';

import 'User.dart';

class Travel {
  late String date; // 여행기간
  late String guideCode; // 가이드 아이디
  late String travelCode; // 고유 그룹코드
  late String title; // 그룹명
  late String notice;
  late Map<String, User> userList; // 유저 리스트

  late List<Schedule> schedule;

  Travel() {
    date = "";
    guideCode = "";
    travelCode = "";
    title = "";
    notice = "";
    userList = {};
    schedule = [];
  }

  void setDate(String date) {
    this.date = date;
  }

  getDate() {
    return date;
  }

  void setGuideCode(String guideCode) {
    this.guideCode = guideCode;
  }

  getGuideCode() {
    return guideCode;
  }

  void setTravelCode(String travelCode) {
    this.travelCode = travelCode;
  }

  getTravelCode() {
    return travelCode;
  }

  void setTitle(String title) {
    this.title = title;
  }

  String getTitle() {
    return title;
  }

  void setNotice(String data) {
    notice = data;
  }
  String getNotice() {
    return notice;
  }

  void setUserList(Map<String, User> userList) {
    this.userList = userList;
  }

  // 키에는 특수문자가 포함되면 안됨.
  void addUser(User user) {
    userList.addAll({user.getUserCode(): user});
  }

  Map<String, User> getUserList() {
    return userList;
  }

  List<Schedule> getSchedule() {
    return schedule;
  }
  /// DB 규칙으로 인해 리스트 형식으로 저장.
  /// 따라서 삽입 시 무조건 clear.
  setSchedule(List<Schedule> data) {
    schedule = data;
  }

  Map<String, dynamic> toJson() => {
    'date': date ?? '',
    'guideCode': guideCode ?? '',
    'travelCode': travelCode ?? '',
    'title': title ?? '',
    'notice': notice ?? '',
    'userList': userList?.map((key, value) => MapEntry(key, value.toJson())) ?? {},
    'schedule': schedule?.map((s) => s.toJson())?.toList() ?? [],
  };

  factory Travel.fromJson(json) {
    var travel = Travel();
    travel.setDate(json['date'] ?? "");
    travel.setGuideCode(json['guideCode'] ?? "");
    travel.setTravelCode(json['travelCode'] ?? "");
    travel.setTitle(json['title'] ?? "");
    travel.setNotice(json['notice'] ?? "");
    travel.setUserList(Map.from(json['userList'] ?? {}).map(
            (key, value) => MapEntry(key, User.fromJson(Map<String, dynamic>.from(value)))));
    var data = (json['schedule'] as List<dynamic>? ?? [])
        .map((item) => Schedule.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    travel.setSchedule(data);

    return travel;
  }
}
