// 기기 내 공유변수 저장용 문자열 데이터.
class SystemData {
  static const String introCheck = 'introCheck';
  static const String permissionCheck = 'permissionCheck';
  static const String travelCode = 'travelCode';
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

  static const String noticeName = '공지';

  static const String naverClientID = 'BGwhW2W9uwbQALukaWDH';
  static const String naverSecretID = 'rfGxmb4r9Q';
  static const String openDataAPIKey = 'HR8TyxL0w4ktjhNK3sGgYDehPyfUNFiQmInLBxO4Oacj0WiY4aDSIGvjVLgMdt0SnrgXg6YGKMTlryaLcEFL0w%3D%3D';
}

/// 유저 타입. common은 입장 대기임.
enum UserType { common, guide, system, user }
