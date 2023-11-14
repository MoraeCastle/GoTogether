// 일정관리 씬 내에서 관리되는 provider
import 'package:flutter/foundation.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:logger/logger.dart';

class ScheduleClass with ChangeNotifier {
  // 데이터 필드들
  Travel _travel = Travel();

  // 데이터 접근자(getter)
  Travel get travel => _travel;

  // 데이터 설정자(setter)
  set travel(Travel value) {
    var logger = Logger();
    logger.d("저장됨...");
    _travel = value;
    notifyListeners();
  }

  getDateTime(int isStartDay) {
    return SystemUtil.changeDateTime(travel.date, isStartDay);
  }
}
