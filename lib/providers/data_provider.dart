// 홈에서 탭들에서 접근 가능한 데이터 관리 클래스.
import 'package:flutter/foundation.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';

class DataClass with ChangeNotifier {
  // 데이터 필드들
  late Travel _travel;
  late User _currentUser;

  // 현재 보고있는 일정
  late RouteItem _targetRoute;
  late String _targetDayKey;

  DataClass() {
    travel = Travel();
  }

  // 데이터 접근자(getter)
  Travel get travel => _travel;
  User get currentUser => _currentUser;
  RouteItem get targetRoute => _targetRoute;
  String get targetDayKey => _targetDayKey;

  // 데이터 설정자(setter)
  set travel(Travel value) {
    _travel = value;

    targetRoute = RouteItem();
    targetDayKey = "";

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
}
