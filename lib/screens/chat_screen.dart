import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/Room.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 채팅목록 씬
class ChatView extends StatefulWidget {
  const ChatView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatView();
}

class _ChatView extends State<ChatView> {
  List<Widget> roomWidgetList = [];
  String travelCode = "";

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    listenTravelChange();
  }

  /// 기기내 저장값 가져오기
  Future<void> getDeviceData() async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    travelCode = prefs.getString(SystemData.trvelCode) ?? "";
  }

  /// 여행 데이터 변경 감지
  Future<void> listenTravelChange() async {
    await getDeviceData();

    DatabaseReference ref = FirebaseDatabase.instance.ref('chat/$travelCode');
    ref.onValue.listen((DatabaseEvent event) {
      var result = event.snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        roomWidgetList = [];

        setState(() {
          for (Room room in chat.getRoomList()) {
            roomWidgetList.add(
                ChatRoomItem(roomData: room)
            );
          }
        });
      } else {
        BotToast.showText(text: "데이터가 없습니다...");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataClass>(context);

    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            child: const Text(
              '채팅방',
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
                  children: roomWidgetList,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// 채팅방 아이템
class ChatRoomItem extends StatefulWidget {
  final Room roomData;

  const ChatRoomItem(
      {Key? key,
        required this.roomData,})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatRoomItem();
}

class _ChatRoomItem extends State<ChatRoomItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
          onPressed: () async {
            // 이 채팅방의 내용대로 기기값 저장.
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString(SystemData.chatTitle, widget.roomData.getTitle());
            await prefs.setInt(SystemData.chatUserCount, widget.roomData.getUserMap().keys.length);
            await prefs.setStringList(SystemData.chatUserList, widget.roomData.getUserMap().keys.toList());

            String userCode = "";
            String userName = "";
            userCode = prefs.getString(SystemData.userCode) ?? "";
            userName = prefs.getString(SystemData.userName) ?? "";

            Navigator.pushNamed(context, ChatRoomRoute,
              arguments: {
                'userCode' : userCode,
                'userName' : userName,
              });
          },
          style: ElevatedButton.styleFrom(
            elevation: 5,
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          child: Container(
            width: double.infinity,
            height: 85,
            margin: const EdgeInsets.all(5),
            child: Stack(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          const AssetImage('assets/images/profile_back.png'),
                      backgroundColor: Colors.grey[200],
                    ),
                    Container(width: 15),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.roomData.getTitle(),
                          style: TextStyle(fontSize: 25, color: Colors.black),
                        ),
                        Container(height: 5),
                        Text(
                          widget.roomData.getMessageList().isEmpty ? ""
                              : widget.roomData.getMessageList().last.getMessage(),
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    )
                  ],
                ),
                Positioned(
                  right: 0,
                  top: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.roomData.getMessageList().isEmpty
                            ? "새 채팅방" : SystemUtil.getTodayStr(DateTime.parse(widget.roomData.getMessageList().last.createdAt)),
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 10,
                  child: Row(
                    children: [
                      Icon(Icons.person, size: 18),
                      Text(
                        "${widget.roomData.getUserMap().length}",
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
