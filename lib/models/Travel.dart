// 여행그룹 객체
import 'User.dart';

class Travel {
  late String date; // 여행기간
  late String guideCode; // 가이드 아이디
  late String travelCode; // 고유 그룹코드
  late String title; // 그룹명
  late List<User> userList; // 유저 리스트

  Travel() {
    date = "";
    guideCode = "";
    travelCode = "";
    title = "";
    userList = List.empty();
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

  void setUserList(List<User> userList) {
    this.userList = userList;
  }

  getUserList() {
    return userList;
  }

  Map<String, dynamic> toJson() {
    return {
      "travelCode": travelCode,
      "title": title,
      "date": date,
      "guideCode": guideCode,
      "userList": userList,
    };
  }
}
