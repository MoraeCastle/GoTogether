import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 로그인 씬
class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginView();
}

class _LoginView extends State<LoginView> {
  bool isGroupWaiting = false;
  String travelCode = "";
  String userCode = "";

  @override
  Widget build(BuildContext context) {
    TextEditingController editingController = TextEditingController();

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
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Image.asset(
                      'assets/images/suitcase.png',
                      width: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Column(
                      children: [
                        isGroupWaiting ? Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "방장의 허가를 기다리는 중입니다...",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                    overflow: TextOverflow.visible,
                                    maxLines: 1,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              height: 80,
                              child: RowItemButton(
                                padding: EdgeInsets.only(bottom: 10),
                                backColor: Color.fromARGB(255, 158, 174, 255),
                                imageName: "refresh_black",
                                buttonText: "새로고침 하기",
                                action: checkWaiting,
                              ),
                            )
                          ],
                        ) : Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "여행 코드로 그룹에 참여하세요",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            // 코드 입력
                            Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1.0),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10) // POINT
                                  ),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(left: 20, right: 20),
                                  child: Row(
                                    children: [
                                      const Text(
                                        'T -',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: TextFormField(
                                          inputFormatters: [UpperCaseTextFormatter()],
                                          controller: editingController,
                                          // textCapitalization: TextCapitalization.characters,
                                          decoration: const InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            hintText: '코드 입력',
                                            contentPadding: EdgeInsets.only(),
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                          ),
                                          style: const TextStyle(),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                            const Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "※ 재시작 시 자동로그인 됩니다.",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ),
                            // 입력한 코드로 로그인
                            RowItemButton(
                              padding: EdgeInsets.only(bottom: 10),
                              backColor: Color.fromARGB(255, 194, 204, 255),
                              imageName: "login_black",
                              buttonText: "입력한 코드로 로그인",
                              action: () {
                                login(context, editingController.value.text);
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                            ),
                            // 새 그룹 만들기
                            RowItemButton(
                              padding: EdgeInsets.only(bottom: 10),
                              backColor: Color.fromARGB(255, 158, 174, 255),
                              imageName: "group_add_black",
                              buttonText: "새 그룹 만들기",
                              action: () => {
                                // Navigator.pop(context),
                                Navigator.pushNamed(context, CreateGroupRoute),
                                // Navigator.pushNamed(context, AddUserRoute),
                              },
                            ),
                          ],
                        ),
                        // 비회원으로 접속
                        RowItemButton(
                          padding: EdgeInsets.only(bottom: 10),
                          backColor: Color.fromARGB(255, 218, 218, 218),
                          imageName: "none_black",
                          buttonText: "비회원으로 이용하기",
                          action: () => noIdModeDialog(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
      ),
    );
  }

  @override
  void initState() {
    BotToast.showLoading();

    super.initState();

    // 무단 조작 방지
    Future.delayed(const Duration(seconds: 1), () {
      checkUserStatus();
    });
  }

  /// 상태 확인
  Future<void> checkUserStatus() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    travelCode = prefs.getString(SystemData.travelCode) ?? "";
    userCode = prefs.getString(SystemData.userCode) ?? "";

    // 뭔가 사용자값이 있다면 상태 체크.
    if (travelCode.isNotEmpty && userCode.isNotEmpty) {
      checkWaiting();
    } else {
      BotToast.closeAllLoading();
    }
  }

  /// 내 상태가 common이 아닐 경우 바로 메인홈으로 진입합니다.
  /// 이 기능은 자동 로그인과 같습니다.
  Future<void> checkWaiting() async {
    bool check = false;
    User targetUser = User();

    // DB 탐색
    DatabaseReference ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();
    BotToast.closeAllLoading();

    if (snapshot.exists) {
      var result = snapshot.value;
      if (result != null) {
        var travel = Travel.fromJson(result);

        for (User user in travel.getUserList().values) {
          if (user.getUserCode() == userCode) {
            check = user.getAuthority() == describeEnum(UserType.common);
            targetUser = user;
            break;
          }
        }
      } else {
        //
      }
    } else {
      BotToast.showText(text: '조회된 여행이 없습니다...');
    }

    if (check) {
      BotToast.showText(text: '방장이 허락하지 않은 상태입니다.');

      setState(() {
        isGroupWaiting = check;
      });
    } else if (targetUser.getUserCode().isNotEmpty){
      // 메인으로 이동.
      Navigator.pop(context);
      Navigator.pushNamed(context, HomeViewRoute);
    } else {
      // 인원목록에 없음 => 탈퇴된 것.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => PopScope(
          canPop: false,
          onPopInvoked: (didPop) {
            if (didPop) return;
            Navigator.pop(context);
          },
        child: AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: const Text('안내'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '입장이 거절되었습니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.group_remove),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () async {
                  await SystemUtil.resetDeviceSetting();
                  SystemNavigator.pop();
                },
                child: const Text('확인')),
          ],
        ),
      ),);
    }
  }

  // 입력된 그룹으로 접속하기
  Future login(BuildContext context, String travelCode) async {
    if (travelCode.isNotEmpty) {
      // T- 코드 방지
      if (!travelCode.contains("T-")) travelCode = "T-$travelCode";

      BotToast.showLoading();

      // DB 탐색
      DatabaseReference ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('travel/$travelCode').get();
      BotToast.closeAllLoading();

      if (snapshot.exists) {
        var result = snapshot.value;
        if (result != null) {
          var travel = Travel.fromJson(result);

          // ignore: use_build_context_synchronously
          showDialog(
              context: context,
              // barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: Container(
                  alignment: Alignment.center,
                  child: const Text('안내'),
                ),
                content: Container(
                  alignment: Alignment.center,
                  constraints: const BoxConstraints(maxHeight: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(
                            color: Color.fromARGB(255, 194, 204, 255),
                            borderRadius: BorderRadius.circular(15)),
                        child: Text(
                          travel.getTitle(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                      ),
                      Text(
                        '방을 찾았습니다. 입장하시겠습니까?',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                ),
                icon: Icon(Icons.priority_high),
                actions: [
                  OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                      ),
                      onPressed: () async {
                        // 데이터 저장
                        await SystemUtil.saveTravel(travel);

                        // 인원이 없다면 내가 가이드.
                        if (travel.getUserList().isEmpty) {
                          // 기기 내에 데이터 저장.
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.setBool(SystemData.travelState, true);

                          Navigator.pop(context);
                          Navigator.pushNamed(context, AddUserRoute);
                        } else {
                          // 디바이스 코드로 중복접근 확인
                          var deviceCode = await SystemUtil.getDeviceCode();

                          var result = travel.getUserList().values
                              .any((element) => element.getDeviceCode() == deviceCode);

                          if (result) {
                            // 이 유저로 메인 입장.
                            User targetUser = User();
                            for (User user in travel.getUserList().values) {
                              if (user.getDeviceCode() == deviceCode) {
                                targetUser = user;
                                break;
                              }
                            }

                            if (targetUser.getName().isEmpty) {
                              BotToast.showText(text: '서버에 오류가 있습니다. 잠시 후 다시 시도해주세요.');
                            } else {
                              await SystemUtil.saveUser(targetUser);

                              Navigator.pop(context);
                              Navigator.pushNamed(context, HomeViewRoute);
                            }
                          } else {
                            // 이 그룹은 처음임.
                            Navigator.pop(context);
                            Navigator.pushNamed(context, AddUserRoute);
                          }
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
              ));
        } else {
          //
        }
      } else {
        BotToast.showText(text: '조회된 여행이 없습니다...');
      }
    } else {
      BotToast.showText(text: '여행 코드를 입력해주세요...');
    }
  }

  // 비회원 모드
  void noIdModeDialog(BuildContext context) {
    showDialog(
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
                      '비회원 모드는 맵 이용만 가능합니다.\n입장하시겠습니까?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.priority_high),
              actions: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: () async {
                      // 메인에서는 여행코드가 비어있다면 비회원모드로 시작해야 함.
                      await SystemUtil.saveTravel(Travel());

                      // 데이터 저장
                      Navigator.pop(context);
                      Navigator.pushNamed(context, HomeViewRoute);
                    },
                    child: const Text('네')),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('아니오')),
              ],
            ));
  }
}

// 커스텀 버튼
class RowItemButton extends StatelessWidget {
  final EdgeInsets padding;
  final Color backColor;
  final String imageName;
  final String buttonText;
  final VoidCallback action;
  final bool? isBold;

  const RowItemButton({
    Key? key,
    required this.padding,
    required this.backColor,
    required this.imageName,
    required this.buttonText,
    required this.action,
    this.isBold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: OutlinedButton(
        onPressed: action,
        style: OutlinedButton.styleFrom(
          elevation: 10,
          backgroundColor: backColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(15),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                alignment: Alignment.center,
                width: 50,
                height: 25,
                child: Image.asset(
                  'assets/images/$imageName.png',
                ),
              ),
              Container(
                width: 180,
                alignment: Alignment.center,
                child: Text(
                  buttonText,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: isBold! ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
