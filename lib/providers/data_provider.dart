// 홈에서 탭들에서 접근 가능한 데이터 관리 클래스.
import 'package:flutter/foundation.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';

class DataClass with ChangeNotifier {
  // 데이터 필드들
  late Travel _travel;
  late User _currentUser;

  // 데이터 접근자(getter)
  Travel get travel => _travel;
  User get currentUser => _currentUser;

  // 데이터 설정자(setter)
  set travel(Travel value) {
    _travel = value;
    notifyListeners();
  }

  set currentUser(User value) {
    _currentUser = value;
    notifyListeners();
  }
}
