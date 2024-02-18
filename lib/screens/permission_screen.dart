import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/api/firebase_api.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// 권한 씬
class PermissionView extends StatefulWidget {
  const PermissionView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _PermissionViewState();
}

class _PermissionViewState extends State<PermissionView> {
  late stt.SpeechToText _speech;

  /// 소개가 끝날 시.
  Future<void> _nextView() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SystemData.permissionCheck, true);

    Navigator.pop(context);
    Navigator.pushNamed(context, LoginViewRoute);
  }

  /// 퍼미션 체크
  Future<void> checkPermission() async {
    // 0. 알림
    await FirebaseApi().initNotifications(context);

    // 1. 위치
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // 2. 녹음
    _speech = stt.SpeechToText();
    await _speech.initialize();

    // 3. 저장공간
    await Permission.storage.request();

    _nextView();
  }

  @override
  void initState() {
    super.initState();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 242, 255),
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          // SystemNavigator.pop();

          CustomDialog.doubleButton(
            context, Icons.exit_to_app, '나가기',
                '종료하시겠습니까?', null, '네', () {
              SystemNavigator.pop();
            }, '아니오', () {
              Navigator.pop(context);
            }, true
          );        },
        child: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 10,
                child: Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  padding: EdgeInsets.all(15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '권한 허용',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Divider(
                                color: Colors.grey,
                                height: 1,
                              ),
                            ),
                            Text(
                              textAlign: TextAlign.center,
                              '지금 거부해도 이후 이용 시 다시 권한을 묻습니다.\n거부 시 일부 서비스 이용에 문제가 있을 수 있습니다.',
                              style: TextStyle(
                                color: Color.fromARGB(200, 0, 0, 0),
                                fontSize: 15
                              ),
                            ),
                            SizedBox(height: 10,),
                            Text(
                              textAlign: TextAlign.center,
                              '※ 아래 권한들은 앱 설정에서 수정 가능합니다.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(150, 0, 0, 0),
                                  fontSize: 15,
                              ),
                            ),
                          ],
                        )
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const PermissionItemWidget(
                              icon: Icons.notifications_active, title: '알림',
                              content: '새 메세지 등 시스템 알림을 받을 수 있습니다.',
                            ),
                            Visibility(
                              visible: Platform.isAndroid,
                              child: const PermissionItemWidget(
                                icon: Icons.charging_station, title: '배터리 최적화 중지',
                                content: '앱을 사용하지 않아도 알림을 원활히 받을 수 있습니다.',
                              ),
                            ),
                            const PermissionItemWidget(
                              icon: Icons.my_location_rounded, title: '위치',
                              content: '사용자의 위치를 지도에 표시합니다.',
                            ),
                            const PermissionItemWidget(
                              icon: Icons.keyboard_voice_rounded, title: '녹음',
                              content: '번역기의 음성인식을 위해 마이크를 사용합니다.',
                            ),
                            const PermissionItemWidget(
                              icon: Icons.folder_open, title: '저장소',
                              content: '사용자 프로필 및 채팅 내 미디어 파일을 올립니다.',
                            ),
                          ],
                        )
                      )
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 159, 195, 255),
                          elevation: 10,
                          side: const BorderSide(
                              color: Colors.grey,
                              width: 0
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        onPressed: () async => checkPermission(),
                        child: const Text(
                          '확인',
                          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                )
              ),
            ],
          )
        ),
      ),
    );
  }
}

class PermissionItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;

  const PermissionItemWidget({super.key, required this.icon, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 1.0, //그림자 깊이
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(8),
          margin: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Material(
                  shape: CircleBorder(),
                  elevation: 2,
                  child: CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.white,
                    child: Icon(icon),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                flex: 10,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      content,
                      style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
