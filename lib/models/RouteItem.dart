// 일정 객체
class RouteItem {
  late String routeName; // 권한
  late String position; // 권한
  late String time; // 권한

  RouteItem() {
    routeName = "";
    position = "";
    position = "";
  }

  getRouteName() {
    return routeName;
  }
  setRouteName(String name) {
    routeName = name;
  }

  getPosition() {
    return position;
  }
  setPosition(String latlng) {
    position = latlng;
  }

  getTime() {
    return time;
  }
  setTime(String t) {
    time = t;
  }

  factory RouteItem.fromJson(Map<String, dynamic> json) {
    RouteItem data = RouteItem();
    data.setRouteName(json['routeName']);
    data.setPosition(json['position']);
    data.setTime(json['time']);
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      "routeName": routeName,
      "position": position,
      "time": time,
    };
  }
}
