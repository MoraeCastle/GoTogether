// 일정관리 씬 내에서 관리되는 provider
import 'package:flutter/foundation.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:logger/logger.dart';

class ScheduleClass with ChangeNotifier {
  // 데이터 필드들
  Travel _travel = Travel();
  User _currentUser = User();
  DateTime selectDate = DateTime.now();
  bool isDetailViewVisible = false;
  bool isGuide = false;

  set detailViewVisible(bool isVisible) {
    isDetailViewVisible = isVisible;
    notifyListeners();
  }

  /// 가이드여부
  set guidCheck(bool isVisible) {
    isGuide = isVisible;
    notifyListeners();
  }

  // 데이터 접근자(getter)
  Travel get travel => _travel;
  User get user => _currentUser;

  DateTime get date => selectDate;
  set date(DateTime date) {
    selectDate = date;
    notifyListeners();
  }

  // 데이터 설정자(setter)
  set travel(Travel value) {
    var logger = Logger();
    logger.d("저장됨...");
    _travel = value;
    selectDate = getDateTime(0);

    notifyListeners();
  }

  set user(User value) {
    _currentUser = value;
    notifyListeners();
  }

  DateTime getDateTime(int isStartDay) {
    return SystemUtil.changeDateTime(travel.getDate(), isStartDay);
  }
}
