import 'dart:async';
import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

/// 설정 씬
class SettingView extends StatefulWidget {
  const SettingView({Key? key, required this.arguments}) : super(key: key);
  final Map<String, String> arguments;

  @override
  State<StatefulWidget> createState() => _SettingView();
}

class _SettingView extends State<SettingView> {
  Logger logger = Logger();

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  DatabaseReference ref = FirebaseDatabase.instance.ref("travel");

  String emailAddress = 'gotogetherqna@gmail.com';
  String travelCode = '';
  String userCode = '';


  @override
  void initState() {
    super.initState();

    getDeviceData();
  }

  getDeviceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    travelCode = prefs.getString(SystemData.travelCode) ?? "";
    userCode = prefs.getString(SystemData.userCode) ?? "";
  }

  Future<bool> backPress() async {
    return (await showDialog(
            context: context,
            // barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Container(
                    alignment: Alignment.center,
                    child: const Text('안내'),
                  ),
                  content: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '입력한 내용이 사라집니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.info_outline_rounded),
                  actions: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          //Navigator.pushNamed(context, ScheduleRoute);
                        },
                        child: const Text('네')),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('아니오')),
                  ],
                ))) ??
        false;
  }

  /// 로그아웃
  Future<bool> logoutDialog() async {
    // 가이드 상태 확인.
    bool isGuide = false;
    String state = widget.arguments['state'] ?? "";
    int userCount = int.parse(widget.arguments['userCount'] ?? "0");
    
    isGuide = state.isNotEmpty && state == describeEnum(UserType.guide);

    return (await showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: const Text('나가기'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 60),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '그룹을 나가시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
                Text(
                  '모든 데이터가 삭제됩니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.info_outline_rounded),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () {
                  Navigator.pop(context);

                  // 가이드인데 나말고 누군가가 있다면?
                  if (isGuide && userCount > 1) {
                    BotToast.showText(text: '가이드인 경우 그룹원이 모두 나갔을 경우에만 나갈 수 있습니다.');
                  } else {
                    BotToast.showLoading();
                    deleteUserData();
                  }
                },
                child: const Text('네')),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('아니오')),
          ],
        ))) ??
        false;
  }

  /// 유저 정보 이 그룹에서 삭제.
  Future<void> deleteUserData() async {
    await NetworkUtil.logout(travelCode, userCode);
    await SystemUtil.resetDeviceSetting();

    BotToast.closeAllLoading();

    CustomDialog.oneButton(
      context, Icons.info_outline_rounded, '안내', '로그아웃 되었습니다.', null, '확인', () {
        Navigator.pop(context);
        Navigator.pushNamed(context, LoginViewRoute);
      }, true
    );
  }

  /// 문의하기.
  contactUs() async {
    String? encodeQueryParameters(Map<String, String> params) {
      return params.entries
          .map((MapEntry<String, String> e) =>
      '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');
    }

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      query: encodeQueryParameters(<String, String>{
        'subject': '여행 갈까요 - 문의',
        'body': '문의 내용: ',
      }),
    );

    launchUrl(emailLaunchUri);
  }

  @override
  Widget build(BuildContext context) {
    /*Logger logger = Logger();
    logger.e("add 신 실행됨....");*/
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '설정',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: Container(
            padding: EdgeInsets.only(top: 15, left: 15, right: 15),
            width: double.infinity,
            height: double.infinity,
            color: Colors.black.withAlpha(200),
            child: Container(
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(150, 255, 255, 255),
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 3.0), //(x,y)
                      blurRadius: 3.0,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    SettingItem(
                        title: '이 그룹에서 나가기(Logout)', icon: Icons.logout_rounded,
                        action: () => logoutDialog(),
                    ),
                    SettingItem(
                      title: '문의하기(Contact us)', icon: Icons.mail_outline_rounded,
                      action: () => contactUs(),
                    ),
                  ],
                )
            )
        ),
      ),
    );
  }
}

/// 공지 아이템
class SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback action;

  const SettingItem({
    Key? key, required this.title, required this.icon, required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(left: 10, right: 10, top: 10),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 3.0, //그림자 깊이
      child: InkWell(
        onTap: action,
        child: Container(
            padding: EdgeInsets.all(5),
            width: double.infinity,
            margin: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(icon, color: Colors.black),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 10),
                      width: 1,
                      height: 20, // 수직 선의 길이
                      color: Colors.grey, // 수직 선의 색상
                    ),
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis, // 또는 TextOverflow.clip
                      maxLines: 1, // 개행을 방지하기 위해 1줄로 제한
                    ),
                    Container(height: 5),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  child: Icon(Icons.arrow_right, color: Colors.black),
                )
              ],
            )
        ),
      ),
    );
  }
}