// 기기 내 공유변수 저장용 문자열 데이터.
class SystemData {
  static const String trvelCode = 'travelCode';
  static const String userCode = 'userCode';
  // 여행그룹이 새로 생성중인 건지? true일경우 새로 생성.
  static const String travelState = 'travelState';
  static const String selectPosition = 'selectPosition';
}

enum UserType { common, guide, system }
