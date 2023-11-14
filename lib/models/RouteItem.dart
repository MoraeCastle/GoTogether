// 일정 객체
class RouteItem {
  late String routeName; // 권한
  late String position; // 권한
  late String time; // 권한

  RouteItem({
    String routeName = "",
    String position = "",
    String time = "",
  })  : routeName = routeName,
        position = position,
        time = time;

  String getRouteName() {
    return routeName;
  }
  setRouteName(String name) {
    routeName = name;
  }

  String getPosition() {
    return position;
  }
  setPosition(String latlng) {
    position = latlng;
  }

  String getTime() {
    return time;
  }
  setTime(String t) {
    time = t;
  }

  Map<String, dynamic> toJson() => {
    'routeName': routeName,
    'position': position,
    'time': time,
  };

  factory RouteItem.fromJson(json) {
    var routeItem = RouteItem(
      routeName: json['routeName'] ?? "",
      position: json['position'] ?? "",
      time: json['time'] ?? "",
    );

    return routeItem;
  }
}
