// 일정관리 씬 내에서 관리되는 provider
import 'package:flutter/foundation.dart';
import 'package:go_together/models/Travel.dart';

class ScheduleClass with ChangeNotifier {
  // 데이터 필드들
  late Travel _travel;

  // 데이터 접근자(getter)
  Travel get travel => _travel;

  // 데이터 설정자(setter)
  set travel(Travel value) {
    _travel = value;
    notifyListeners();
  }
}
