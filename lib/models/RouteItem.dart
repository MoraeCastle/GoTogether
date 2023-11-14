// 일정 객체
class RouteItem {
  late String routeName;
  late String position;
  late String startTime;
  late String endTime;

  RouteItem({
    String routeName = "",
    String position = "",
    String startTime = "",
    String endTime = "",
  })  : routeName = routeName,
        position = position,
        startTime = startTime,
        endTime = endTime;

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

  String getStartTime() {
    return startTime;
  }
  setStartTime(String t) {
    startTime = t;
  }

  String getEndTime() {
    return endTime;
  }
  setEndTime(String t) {
    endTime = t;
  }

  Map<String, dynamic> toJson() => {
    'routeName': routeName,
    'position': position,
    'startTime': startTime,
    'endTime': endTime,
  };

  factory RouteItem.fromJson(json) {
    var routeItem = RouteItem(
      routeName: json['routeName'] ?? "",
      position: json['position'] ?? "",
      startTime: json['startTime'] ?? "",
      endTime: json['endTime'] ?? "",
    );

    return routeItem;
  }
}
