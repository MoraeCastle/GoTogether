// 홈에서 탭들에서 접근 가능한 데이터 관리 클래스.
import 'package:flutter/foundation.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';

class DataClass with ChangeNotifier {
  // 데이터 필드들
  late Travel _travel;
  late User _currentUser;
  late Map<String, Notice> _noticeList;
  late int _allUnreadCount;

  // 현재 보고있는 일정
  late RouteItem _targetRoute;
  late String _targetDayKey;

  // 정렬된 일차데이터 키 리스트.
  late List<String> _sortedList;

  DataClass() {
    travel = Travel();
    currentUser = User();
    noticeList = {};
    allUnreadCount = 0;
  }

  // 데이터 접근자(getter)
  Travel get travel => _travel;
  User get currentUser => _currentUser;
  RouteItem get targetRoute => _targetRoute;
  String get targetDayKey => _targetDayKey;
  List<String> get sortedDayList => _sortedList;
  Map<String, Notice> get noticeList => _noticeList;
  int get allUnreadCount => _allUnreadCount;

  // 데이터 설정자(setter)
  set travel(Travel value) {
    _travel = value;

    targetRoute = RouteItem();
    targetDayKey = "";
    sortedDayList = [];

    notifyListeners();
  }

  set currentUser(User value) {
    _currentUser = value;
    notifyListeners();
  }

  set targetRoute(RouteItem value) {
    _targetRoute = value;
    notifyListeners();
  }
  set targetDayKey(String value) {
    _targetDayKey = value;
    notifyListeners();
  }

  set sortedDayList(List<String> value) {
    _sortedList = value;
    notifyListeners();
  }

  set noticeList(Map<String, Notice> value) {
    _noticeList = value;
    notifyListeners();
  }

  set allUnreadCount(int value) {
    _allUnreadCount = value;
    notifyListeners();
  }
}
