import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/models/data.dart';
import 'package:go_together/providers/schedule_provider.dart';
import 'package:go_together/utils/string.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScheduleEditView extends StatefulWidget {
  const ScheduleEditView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleEditView> {
  List<Widget> userList = [];
  TextEditingController noticeController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    noticeController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    noticeController.text = context.watch<ScheduleClass>().travel.getNotice();
    
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(200),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// 타이틀
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home_filled),
                            SizedBox(width: 5),
                            Text('여행명'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 인원 리스트
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                      TextField(
                        onChanged: (value) {
                          Provider.of<ScheduleClass>(context, listen: false).travel.setTitle(value);
                        },
                        enabled: context.watch<ScheduleClass>().isGuide,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(150, 255, 255, 255),
                          // labelText: context.watch<ScheduleClass>().travel.getTitle(),
                          hintText: context.watch<ScheduleClass>().travel.getTitle(),
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    /*Text(
                        context.watch<ScheduleClass>().travel.getUserList().length.toString()
                            + ' 명'),*/
                  ),
                ],
              ),
            ),
            /// 인원리스트
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 5),
                            Text('인원 리스트'),
                          ],
                        ),
                        Text(
                          context.watch<ScheduleClass>().travel.getUserList().length.toString()
                              + ' 명',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 인원 리스트
                  GridView.count(
                    childAspectRatio: 3 / 1,
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 5,
                    crossAxisSpacing: 5,
                    children: getUserItemList(
                      context.watch<ScheduleClass>().travel.getUserList(),
                        context.watch<ScheduleClass>().isGuide),
                  ),
                ],
              ),
            ),
            /// 그룹 공지사항
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment),
                            SizedBox(width: 5),
                            Text('공지사항'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 공지사항
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 350,
                      child: TextField(
                        maxLines: null,
                        controller: noticeController,
                        enabled: context.watch<ScheduleClass>().isGuide,
                        onChanged: (value) {
                          Provider.of<ScheduleClass>(context, listen: false).travel.setNotice(value);
                        },
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(150, 255, 255, 255),
                          // labelText: context.watch<ScheduleClass>().travel.getNotice(),
                          alignLabelWithHint: true,
                          hintText: '내용 입력',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    /*Text(
                        context.watch<ScheduleClass>().travel.getUserList().length.toString()
                            + ' 명'),*/
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상태 변경
  Future<bool> changeAuthUser(String userCode) async {
    var travelCode = context.read<ScheduleClass>().travel.getTravelCode();

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();

    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);

      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == userCode) {
          user.setAuthority(describeEnum(UserType.user));

          break;
        }
      }

      await ref.child('travel/$travelCode').set(travel.toJson());

      userList = [];

      setState(() {
        userList = getUserItemList(travel.getUserList(), context.read<ScheduleClass>().isGuide);
      });

      return true;
    } else {
      return false;
    }
  }

  /// 유저상태 변경 팝업
  Future<bool> finishDialog(User targetUser) async {
    return (await showDialog(
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
            child: const Text('인원 추가'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  targetUser.getName() + ' 님을 파티에 추가하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.person_add),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () async {
                  bool result = await changeAuthUser(targetUser.getUserCode());

                  if (!result) {
                    BotToast.showText(text: '서버 오류입니다. 나중에 다시 시도해주세요...');
                  }
                  Navigator.pop(context);
                },
                child: const Text('추가')),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소')),
          ],
        ),
      ),
    ));
  }

  List<Widget> getUserItemList(Map<String, User> dataList, bool isGuide) {
    userList.clear();

    for (User user in dataList.values) {
      // 가이드는 맨 첫번쨰로...
      if (user.getAuthority() == describeEnum(UserType.guide)) {
        userList.insert(0, UserItem(
          user: user,
          action: () {
            ///
          }, longAction: () {

          },
          isMe: user.getUserCode() == context.read<ScheduleClass>().user.getUserCode(),
        ));
      } else {
        userList.add(
          UserItem(
            user: user,
            action: () {
              BotToast.showText(text: "클릭...");
            }, longAction: () {
              if (isGuide) {
                finishDialog(user);
              }
          },
          isMe: user.getUserCode() == context.read<ScheduleClass>().user.getUserCode(),
        ));
      }
    }

    return userList;
  }
}

// 인원목록 아이템
class UserItem extends StatefulWidget {
  final User user;
  final VoidCallback action;
  final VoidCallback longAction;
  final bool isMe;

  const UserItem(
      {Key? key,
    required this.user,
    required this.action, required this.longAction, required this.isMe})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _UserItem();
}

class _UserItem extends State<UserItem> {
  @override
  Widget build(BuildContext context) {
    bool isGuide = widget.user.getAuthority() == describeEnum(UserType.guide);

    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          //모서리를 둥글게 하기 위해 사용
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 4.0, //그림자 깊이
        child: InkWell(
          onTap: widget.action,
          onLongPress: widget.longAction,
          child: SizedBox(
            width: double.infinity,
            height: 35,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isGuide ? Colors.yellow.withAlpha(150) : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: widget.isMe ? Border.all(
                      color: Colors.black,
                      width: 3,
                    ) : null
                  ),
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: 50,
                            child: CachedNetworkImage(
                              imageUrl: Data.profileImage,
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.contain),
                                ),
                              ),
                              placeholder: (context, url) => Center(
                                child: Icon(Icons.account_circle),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                          Positioned(
                            // top: 5,
                              child: Visibility(
                                visible: isGuide,
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 20,
                                  height: 20,
                                  child: Image.asset(
                                    'assets/images/crown_color.png',
                                  ),
                                ),
                              )
                          ),
                        ],
                      ),
                      Text(
                        widget.user.getName(),
                        style: TextStyle(
                            fontWeight: isGuide ? FontWeight.bold : FontWeight.normal
                        ),
                      ),
                    ],
                  ),
                ),
                Visibility(
                    visible: context.watch<ScheduleClass>().isGuide && widget.user.getAuthority() == describeEnum(UserType.common),
                    child: Container(
                      decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      width: double.infinity,
                      height: double.infinity,
                      child: const Text(
                        textAlign: TextAlign.center,
                        '꾹 탭해서 인원추가',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    )
                ),
              ],
            )
          ),
        ),
    );
  }
}