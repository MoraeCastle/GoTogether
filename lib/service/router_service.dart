import 'package:flutter/material.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/screens/addUser_screen.dart';
import 'package:go_together/screens/chatRoom_screen.dart';
import 'package:go_together/screens/country_info.dart';
import 'package:go_together/screens/createGroup_screen.dart';
import 'package:go_together/screens/introduction_screen.dart';
import 'package:go_together/screens/log_in_screen.dart';
import 'package:go_together/screens/main_screen.dart';
import 'package:go_together/screens/map_screen.dart';
import 'package:go_together/screens/map_select_screen.dart';
import 'package:go_together/screens/notice_list_screen.dart';
import 'package:go_together/screens/permission_screen.dart';
import 'package:go_together/screens/schedule_add_view.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/screens/translator_screen.dart';
import 'package:go_together/service/routing_service.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      return MaterialPageRoute(builder: (context) => HomeView());
    case IntroViewRoute:
      return MaterialPageRoute(builder: (context) => const IntroductionView());
    case PermissionViewRoute:
      return MaterialPageRoute(builder: (context) => const PermissionView());
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
    case NoticeListViewRoute:
      try {
        final arg = settings.arguments as Map<String, Notice>;
        return MaterialPageRoute(builder: (context) => NoticeListView(arguments: arg));

      } catch(error) {
        return MaterialPageRoute(builder: (context) => NoticeListView(arguments: {}));
      }
    case CountryInfoViewRoute:
      try {
        String? argument = settings.arguments as String?;

        return MaterialPageRoute(builder: (context) => CountryInfoView(arguments: argument ?? ''));
      } catch(e) {
        return MaterialPageRoute(builder: (context) => CountryInfoView(arguments: ''));
      }
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
