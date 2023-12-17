import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:provider/provider.dart';

/// 채팅방 씬
class EtcView extends StatefulWidget {
  const EtcView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EtcViewState();

}

class _EtcViewState extends State<EtcView> {
  TextEditingController userNameController = TextEditingController();
  bool profileRadioState = false;

  @override
  Widget build(BuildContext context) {
    Travel travel = context.watch<DataClass>().travel;
    User targetUser = context.watch<DataClass>().currentUser;
    userNameController.text = "";

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
                        height: 120,
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
                        child: InkWell(
                          onTap: () {
                            // BotToast.showText(text: 'text');
                            CustomDialog.doubleButton(
                              context, Icons.edit, '이름 변경', "이름을 변경하려면 아래 내용을 입력해주세요.",
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: TextField(
                                  controller: userNameController,
                                  /*onChanged: (value) {
                                    userItem.setName(value);

                                    setState(() {
                                      isNameEdited = value.isNotEmpty;
                                    });
                                  },*/
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: targetUser.getName(),
                                    contentPadding: EdgeInsets.only(
                                        left: 14.0, bottom: 8.0, top: 8.0),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Colors.black, width: 1.0),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  style: const TextStyle(),
                                ),
                              ), '저장', () {
                                // 입력 액션
                                if (userNameController.text.isNotEmpty && userNameController.text != targetUser.getName()) {
                                  // 유저 이름 저장 처리...
                                  NetworkUtil.changeUserName(
                                      travel.getTravelCode(), targetUser.getUserCode(), userNameController.text);
                                }
                                Navigator.pop(context);
                              },
                              '취소', () {
                                Navigator.pop(context);
                            }, false);
                          },
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
                                                  !profileRadioState ? targetUser.getName() : targetUser.getUserCode(),
                                                  style: TextStyle(fontSize: 20),
                                                )
                                              ],
                                            )),
                                        Flexible(
                                            flex: 2,
                                            child: Container(
                                              child: Column(
                                                children: [
                                                  Text(
                                                    '고유 코드',
                                                    style: TextStyle(fontSize: 11),
                                                  ),
                                                  Switch(
                                                    value: profileRadioState,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        profileRadioState = value;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              )
                                            )),
                                      ],
                                    ),
                                  ))
                            ],
                          ),
                        )),
                    GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        children: [
                          EtcMenuItem(
                            icon: Icons.assignment,
                            title: '공지사항',
                            action: () async {
                              var noticeMap = await NetworkUtil.getNoticeList();

                              Navigator.pushNamed(context, NoticeListViewRoute, arguments: noticeMap);
                            },
                          ),
                          EtcMenuItem(
                              icon: Icons.translate,
                              title: '번역기',
                              action: () {
                                // BotToast.showText(text: '미구현 기능입니다...');
                                Navigator.pushNamed(context, TranslatorViewRoute);
                              }),
                          EtcMenuItem(
                              icon: Icons.travel_explore,
                              title: '국가정보',
                              action: () {
                                // 일정이 비어있을경우 미조회.
                                var country = context.read<DataClass>().travel.getCountry();
                                if (country.isEmpty) {
                                  CustomDialog.oneButton(
                                    context, Icons.info_outline_rounded, '안내', '아직 여행지가 추가되지 않았습니다.'
                                      , null, '확인', () {
                                      Navigator.pop(context);
                                    }, false
                                  );
                                } else {
                                  Navigator.pushNamed(context, CountryInfoViewRoute, arguments: country);
                                }
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
              color: Colors.black.withAlpha(200),
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
