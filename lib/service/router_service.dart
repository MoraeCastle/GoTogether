import 'package:flutter/material.dart';
import 'package:go_together/screens/addUser_screen.dart';
import 'package:go_together/screens/createGroup_screen.dart';
import 'package:go_together/screens/log_in_screen.dart';
import 'package:go_together/screens/main_screen.dart';
import 'package:go_together/screens/map_screen.dart';
import 'package:go_together/screens/schedule_add_view.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/service/routing_service.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeView());
    case LoginViewRoute:
      return MaterialPageRoute(builder: (context) => const LoginView());
    case MapViewRoute:
      return MaterialPageRoute(builder: (context) => MapView());
    case CreateGroupRoute:
      return MaterialPageRoute(builder: (context) => const CreateGroupView());
    case AddScheduleRoute:
      return MaterialPageRoute(builder: (context) => const ScheduleAddView());
    case AddUserRoute:
      return MaterialPageRoute(builder: (context) => const AddUserView());
    case ScheduleRoute:
      return MaterialPageRoute(builder: (context) => ScheduleView());
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
