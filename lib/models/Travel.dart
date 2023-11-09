// 여행그룹 객체
import 'package:go_together/models/Schedule.dart';

import 'User.dart';

class Travel {
  late String date; // 여행기간
  late String guideCode; // 가이드 아이디
  late String travelCode; // 고유 그룹코드
  late String title; // 그룹명
  late Map<String, User> userList; // 유저 리스트

  late List<Schedule> schedule;

  Travel() {
    date = "";
    guideCode = "";
    travelCode = "";
    title = "";
    userList = {};
    schedule = [];
  }

  factory Travel.fromJson(json) {
    Travel data = Travel();
    data.setDate(json['date']);
    data.setGuideCode(json['guideCode']);
    data.setTravelCode(json['travelCode']);
    data.setTitle(json['title']);
    if (json['userList'] != null) {
      data.setUserList(json['userList'].cast<String, User>());
    }
    if (json['schedule'] != null) {
      data.setSchedule(json['schedule'].cast<Schedule>());
    }
    // data.setUserList(List<User>.from(json['userList']));
    return data;
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

  getTitle() {
    return title;
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

  getSchedule() {
    return schedule;
  }
  /// DB 규칙으로 인해 리스트 형식으로 저장.
  /// 따라서 삽입 시 무조건 clear.
  setSchedule(Schedule data) {
    schedule.clear();
    schedule.add(data);
  }

  Map<String, dynamic> toJson() {
    return {
      "travelCode": travelCode,
      "title": title,
      "date": date,
      "guideCode": guideCode,
      "userList": userList.map((key, value) => MapEntry(key, value.toJson())),
      "schedule": schedule.map((player) => player.toJson()).toList(),
    };
  }
}
