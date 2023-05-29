import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';

/// 채팅방 씬
class EtcView extends StatelessWidget {
  const EtcView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            child: const Text(
              '기타',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    // 프로필
                    Container(
                        width: double.infinity,
                        height: 100,
                        margin: const EdgeInsets.all(5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
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
                            Container(
                              width: double.infinity,
                              child: Text('프로필'),
                            ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  Flexible(
                                      flex: 10,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: const AssetImage(
                                                'assets/images/profile_back.png'),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          Container(width: 10),
                                          Text(
                                            '...',
                                            style: TextStyle(fontSize: 20),
                                          )
                                        ],
                                      )),
                                  Flexible(
                                      flex: 2,
                                      child: Container(
                                        child: Switch(
                                          value: false,
                                          onChanged: (value) {},
                                        ),
                                      )),
                                ],
                              ),
                            ))
                          ],
                        )),
                    GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        children: [
                          EtcMenuItem(
                            icon: Icons.assignment,
                            title: '공지사항',
                            action: () {
                              BotToast.showText(text: '미구현 기능입니다...');
                            },
                          ),
                          EtcMenuItem(
                              icon: Icons.translate,
                              title: '번역기',
                              action: () {
                                BotToast.showText(text: '미구현 기능입니다...');
                              }),
                          EtcMenuItem(
                              icon: Icons.travel_explore,
                              title: '국가정보',
                              action: () {
                                BotToast.showText(text: '미구현 기능입니다...');
                              }),
                          EtcMenuItem(
                              icon: Icons.settings,
                              title: '설정',
                              action: () {
                                BotToast.showText(text: '미구현 기능입니다...');
                              }),
                        ]),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 메뉴이동 아이콘
class EtcMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback action;
  final bool? isEnabled;

  const EtcMenuItem(
      {Key? key,
      required this.icon,
      required this.title,
      this.isEnabled,
      required this.action})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EtcMenuItem();
}

class _EtcMenuItem extends State<EtcMenuItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: widget.action,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 55,
              color: Colors.black.withAlpha(150),
            ),
            Container(height: 15),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
