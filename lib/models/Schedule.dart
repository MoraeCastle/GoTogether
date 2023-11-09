// 일정 객체
import 'package:go_together/main.dart';
import 'package:go_together/models/RouteItem.dart';

class Schedule {
  late Map<int, List<RouteItem>> routeMap;

  Schedule() {
    routeMap = Map();
  }

  getRouteMap() {
    return routeMap;
  }
  setRouteMap(Map<int, List<RouteItem>> data) {
    routeMap = data;
  }

  addRoute(int day, RouteItem item) {
    if (routeMap[day] == null) {
      routeMap[day] = <RouteItem>[];
    }
    routeMap[day]!.add(item);
  }
  removeRoute(int day, RouteItem item) {
    if (routeMap.keys.contains(day)) {
      if (routeMap[day] != null) {
        RouteItem target = RouteItem();
        for (RouteItem data in routeMap[day]!) {
          if (data.position == item.position) {
            target = data;
            break;
          }
        }

        if (target.position.isNotEmpty) {
          routeMap[day]!.remove(target);
        }
      }
    }
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    Schedule data = Schedule();
    if (json['routeMap'] != null) {
      data.setRouteMap(json['routeMap'].cast<int, RouteItem>());
    }
    return data;
  }

  Map<String, dynamic> toJson() {
    return {
      "routeMap": routeMap.map((key, value) => MapEntry(key,
          value.map((value) => value.toJson()).toList())),
    };
  }
}
