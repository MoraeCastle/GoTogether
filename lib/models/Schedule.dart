// 일정 객체
import 'package:go_together/main.dart';
import 'package:go_together/models/RouteItem.dart';

class Schedule {
  /// 날짜에 따른 일정 리스트.
  late Map<String, List<RouteItem>> routeMap;

  Schedule () {
    routeMap = {};
  }

  Map<String, List<RouteItem>> getRouteMap() {
    return routeMap;
  }
  setRouteMap(Map<String, List<RouteItem>> data) {
    routeMap = data;
  }

  /// 추후 오름차순으로 추가하게...
  addRoute(String day, RouteItem item) {
    routeMap[day] ??= [];  // If null, assign an empty list.
    routeMap[day]!.add(item);
  }
  removeRoute(String day, RouteItem item) {
    if (routeMap.containsKey(day)) {
      if (routeMap[day] != null) {
        RouteItem? target; // Initialize as nullable
        for (RouteItem data in routeMap[day]!) {
          if (data.position == item.position) {
            target = data;
            break;
          }
        }

        if (target != null && target.position.isNotEmpty) {
          routeMap[day]!.remove(target);
        }
      }
    }
  }

  Map<String, dynamic> toJson() => {
    'routeMap': routeMap.map((key, value) =>
        MapEntry(key, value.map((item) => item.toJson()).toList())),
  };

  factory Schedule.fromJson(json) {
    var schedule = Schedule();

    schedule.setRouteMap(Map.from(json['routeMap'] ?? {}).map((key, value) => MapEntry(
        key,
        (value as List<dynamic>)
            .map((item) =>
            RouteItem.fromJson(Map<String, dynamic>.from(item)))
            .toList())));

    return schedule;
  }
}
