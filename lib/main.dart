import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:go_together/api/firebase_api.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/service/router_service.dart' as router;
import 'package:go_together/service/routing_service.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_together/utils/string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

String route = LoginViewRoute;

void main() async {
//  WidgetsFlutterBinding.ensureInitialized();
  // 초기 부팅 이미지를 잠시 멈춥니다.
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // androidProvider: AndroidProvider.playIntegrity,
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.deviceCheck,
  );

  if(Platform.isAndroid) {
    // AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  }

  await dotenv.load(fileName: 'assets/config/.env');
  route = await checkAutoLogin();

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

/// 자동로그인 체크
Future<String> checkAutoLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // 권한은 일단 인트로만 넘어가면 패스되도록...
  String initScene = "";

  var introCheck = prefs.getBool(SystemData.introCheck) ?? false;
  var travelCode = prefs.getString(SystemData.travelCode) ?? "";
  var userCode = prefs.getString(SystemData.userCode) ?? "";

  if (!introCheck) {
    initScene = IntroViewRoute;
  } else if (travelCode.isEmpty || userCode.isEmpty) {
    // 둘중 하나라도 빠져있으면 오류이므로 일단 로그인으로.
    initScene = LoginViewRoute;
  } else {
    // 이제 이 코드가 유효한지 체크.
    bool answer = await travelCheck(travelCode, userCode);
    initScene = answer ? HomeViewRoute : LoginViewRoute;
  }

  return initScene;
}

/// 기기 내 여행데이터가 유효한지 체크합니다.
Future<bool> travelCheck(String travelCode, String userCode) async {
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  final snapshot = await ref.child('travel/$travelCode').get();

  bool answer = false;

  if (snapshot.exists) {
    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);

      for (User user in travel.getUserList().values) {
        // 유저코드가 존재하거나, 입장 가능한 상태인경우.
        if (user.getUserCode() == userCode) {
          answer = user.getAuthority() == describeEnum(UserType.user) || user.getAuthority() == describeEnum(UserType.guide);

          break;
        }
      }

      return answer;
    } else {
      return answer;
    }
  } else {
    return answer;
  }
}

/// 메인
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 타겟 언어 설정.
      localizationsDelegates: const [
        CountryLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko'),
        Locale('en'),
      ],
      locale: const Locale('ko'),
      title: '여행갈까요',
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
