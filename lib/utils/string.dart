// 기기 내 공유변수 저장용 문자열 데이터.
class SystemData {
  static const String trvelCode = 'travelCode';
  static const String userCode = 'userCode';
  static const String userName = 'userName';
  // 여행그룹이 새로 생성중인 건지? true일경우 새로 생성.
  static const String travelState = 'travelState';
  static const String selectPosition = 'selectPosition';
  // 일정 관련 yyyy-mm-dd
  static const String selectDate = 'selectDate';
  // 채팅 관련
  static const String chatTitle = 'chatTitle';
  static const String chatUserCount = 'chatUserCount';
  static const String chatUserList = 'chatUserList';
}

enum UserType { common, guide, system }
