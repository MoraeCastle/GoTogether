import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_together/service/router_service.dart' as router;
import 'package:go_together/service/routing_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

String route = LoginViewRoute;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(Platform.isAndroid) {
    // AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: 'assets/config/.env');
  route = await checkAutoLogin();
  runApp(const MyApp());
}

/// 자동로그인 체크
Future<String> checkAutoLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  String initScene = "";
  prefs.getString(SystemData.userCode) != null
      ? initScene = HomeViewRoute
      : initScene = LoginViewRoute;

  return initScene;
}

/// 메인
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 타겟 언어 설정.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      locale: const Locale('ko'),
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   primarySwatch: Colors.blue,
      // ),
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      onGenerateRoute: (settings) => router.generateRoute(settings),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      initialRoute: route,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
