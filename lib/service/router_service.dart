import 'package:flutter/material.dart';
import 'package:go_together/screens/log_in_screen.dart';
import 'package:go_together/screens/main_screen.dart';
import 'package:go_together/service/routing_service.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case HomeViewRoute:
      print(">>>>>>>>>>>>>>>..");
      return MaterialPageRoute(builder: (context) => HomeView());
    case LoginViewRoute:
      return MaterialPageRoute(builder: (context) => LoginView());
    default:
      return MaterialPageRoute(builder: (context) => HomeView());
  }
}
