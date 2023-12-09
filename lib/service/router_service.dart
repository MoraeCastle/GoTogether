import 'package:flutter/material.dart';
import 'package:go_together/screens/addUser_screen.dart';
import 'package:go_together/screens/chatRoom_screen.dart';
import 'package:go_together/screens/createGroup_screen.dart';
import 'package:go_together/screens/log_in_screen.dart';
import 'package:go_together/screens/main_screen.dart';
import 'package:go_together/screens/map_screen.dart';
import 'package:go_together/screens/map_select_screen.dart';
import 'package:go_together/screens/schedule_add_view.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/screens/translator_screen.dart';
import 'package:go_together/service/routing_service.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeView());
    case LoginViewRoute:
      return MaterialPageRoute(builder: (context) => const LoginView());
    case MapViewRoute:
      return MaterialPageRoute(builder: (context) => MapView());
    case MapSelectViewRoute:
      return MaterialPageRoute(builder: (context) => MapSelectView());
    case CreateGroupRoute:
      return MaterialPageRoute(builder: (context) => const CreateGroupView());
    case AddScheduleRoute:
      // 씬 이동 전 변수가 넘어올 경우...
      String? argument = settings.arguments as String?;

      return MaterialPageRoute(builder: (context) => ScheduleAddView(arguments: argument ?? ''));
    case AddUserRoute:
      return MaterialPageRoute(builder: (context) => const AddUserView());
    case ScheduleRoute:
      return MaterialPageRoute(builder: (context) => ScheduleView());
    case ChatRoomRoute:
      final arg = settings.arguments as Map<String, String>;

      return MaterialPageRoute(builder: (context) => ChatRoomView(arguments: arg,));
    case TranslatorViewRoute:
      return MaterialPageRoute(builder: (context) => TranslatorView());
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
