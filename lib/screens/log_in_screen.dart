import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_together/service/routing_service.dart';

/// 로그인 씬
class LoginView extends StatelessWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController editingController = TextEditingController();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 242, 255),
      body: Container(
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
                      TextField(
                        controller: editingController,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '코드 입력',
                          contentPadding: EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.black, width: 1.0),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        style: const TextStyle(),
                      ),
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
                      // 비회원으로 접속
                      RowItemButton(
                        padding: EdgeInsets.only(bottom: 10),
                        backColor: Color.fromARGB(255, 218, 218, 218),
                        imageName: "none_black",
                        buttonText: "비회원으로 이용하기",
                        action: () => {BotToast.showText(text: '3')},
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
    );
  }

  // 입력된 그룹으로 접속하기
  void login(BuildContext context, String travleCode) {
    BotToast.showLoading();
    BotToast.showText(text: "$travleCode 입력");

    showDialog(
        context: context,
        // barrierDismissible: false,
        builder: (context) => AlertDialog(
              title: Container(
                alignment: Alignment.center,
                child: const Text('안내'),
              ),
              content: Container(
                height: 100,
                alignment: Alignment.center,
                child: const Text('그룹을 찾았습니다.\n입장하시겠습니까?'),
              ),
              actions: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, HomeViewRoute);
                    },
                    child: Text('네')),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: Text('아니오')),
              ],
            ));

    BotToast.closeAllLoading();
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
