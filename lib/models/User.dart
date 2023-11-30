// 사용자 객체
class User {
  late String authority; // 권한
  late String deviceCode; // 기기 고유코드
  late String name; // 유저이름
  late String position; // 위치좌표
  late String pushToken; // 알림전송용 고유토큰
  late String userCode; // 유저 고유코드

  User({
    String authority = "",
    String deviceCode = "",
    String name = "",
    String position = "",
    String pushToken = "",
    String userCode = "",
  })  : authority = authority,
        deviceCode = deviceCode,
        name = name,
        position = position,
        pushToken = pushToken,
        userCode = userCode;

  void setAuthority(String authority) {
    this.authority = authority;
  }
  String getAuthority() {
    return authority;
  }

  void setDeviceCode(String deviceCode) {
    this.deviceCode = deviceCode;
  }

  getDeviceCode() {
    return deviceCode;
  }

  void setName(String name) {
    this.name = name;
  }

  String getName() {
    return name;
  }

  void setPosition(String position) {
    this.position = position;
  }

  getPosition() {
    return position;
  }

  void setPushToken(String pushToken) {
    this.pushToken = pushToken;
  }

  getPushToken() {
    return pushToken;
  }

  void setUserCode(String userCode) {
    this.userCode = userCode;
  }

  getUserCode() {
    return userCode;
  }

  Map<String, dynamic> toJson() => {
    'authority': authority,
    'deviceCode': deviceCode,
    'name': name,
    'position': position,
    'pushToken': pushToken,
    'userCode': userCode,
  };

  factory User.fromJson(json) {
    var user = User(
      authority: json['authority'] ?? "",
      deviceCode: json['deviceCode'] ?? "",
      name: json['name'] ?? "",
      position: json['position'] ?? "",
      pushToken: json['pushToken'] ?? "",
      userCode: json['userCode'] ?? "",
    );

    return user;
  }
}
