import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatview/chatview.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/Room.dart';
import 'package:go_together/models/data.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/network_util.dart';
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
  String userCode = "";

  String noticeURL = Data.profileImage;

  Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    listenTravelChange();
  }

  /// 기기내 저장값 가져오기
  Future<void> getDeviceData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    travelCode = prefs.getString(SystemData.travelCode) ?? "";
    userCode = prefs.getString(SystemData.userCode) ?? "";
  }

  getSystemSetting() async {
    noticeURL = await NetworkUtil.getNoticeProfileURL();
  }

  /// 여행 데이터 변경 감지
  Future<void> listenTravelChange() async {
    await getDeviceData();
    await getSystemSetting();

    DatabaseReference ref = FirebaseDatabase.instance.ref('chat/$travelCode');
    ref.onValue.listen((DatabaseEvent event) {
      var result = event.snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        roomWidgetList = [];

        setState(() {
          for (Room room in chat.getRoomList()) {
            if (room.getState() == 1) {
              room.setProfile(noticeURL);
            }

            int unReadCount = 0;
            if (room.getUserMap().keys.contains(userCode)) {
              unReadCount = room.getMessageList().length - room.getUserMap()[userCode]!;
            }

            roomWidgetList.add(
                ChatRoomItem(
                  roomData: room,
                  unReadCount: unReadCount,
                  onTap: () async {
                    // 이 채팅방의 내용대로 기기값 저장.
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    prefs.setString(SystemData.chatTitle, room.getTitle());
                    prefs.setInt(SystemData.chatUserCount, room.getUserMap().keys.length);
                    prefs.setStringList(SystemData.chatUserList, room.getUserMap().keys.toList());

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
                )
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      children: roomWidgetList,
                    ),
                  ),
                  Visibility(
                    visible: roomWidgetList.isEmpty,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                              '데이터 로딩중...'
                          ),
                        ],
                      ),
                    )
                  ),
                ],
              )
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
  final VoidCallBack onTap;
  final int unReadCount;

  const ChatRoomItem(
      {Key? key,
        required this.roomData, required this.onTap, required this.unReadCount,})
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
          onPressed: widget.onTap,
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
                    Expanded(
                      flex: 1,
                      /*child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                        const AssetImage('assets/images/profile_back.png'),
                        backgroundColor: Colors.grey[200],
                      ),*/
                      child: Material(
                        color: Colors.transparent,
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5.0),
                          child: AspectRatio(
                            aspectRatio: 1 / 1,
                            child: widget.roomData.getProfile().isEmpty ?
                            AspectRatio(
                              aspectRatio: 1 / 1,
                              child: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(100),
                                  border: Border.all(
                                      color: Colors.grey,
                                      width: 3
                                  ),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Icon(
                                  Icons.phone,
                                  color: Colors.grey,
                                  size: 35,
                                ),
                              ),
                            ) :
                            CachedNetworkImage(
                              imageUrl: widget.roomData.getProfile(),
                              imageBuilder: (context, imageProvider) => Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: DecorationImage(
                                      image: imageProvider, fit: BoxFit.fitHeight),
                                ),
                              ),
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) => Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(width: 15),
                    Expanded(
                      flex: 5,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.roomData.getTitle(),
                            style: TextStyle(fontSize: 25, color: Colors.black),
                            overflow: TextOverflow.ellipsis, //
                            maxLines: 1,
                          ),
                          Container(height: 5),
                          Text(
                            widget.roomData.getMessageList().isEmpty ? ""
                                : widget.roomData.getMessageList().last.getMessage(),
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          )
                        ],
                      )
                    ),
                  ],
                ),
                Positioned(
                  right: 0,
                  bottom: 10,
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
                  top: 0,
                  bottom: 0,
                  child: Visibility(
                    visible: widget.unReadCount != 0,
                    child: Center(
                      child: Container(
                        // padding: EdgeInsets.all(8),
                        padding: EdgeInsets.only(top:3, bottom: 3, left: 8, right: 8),
                        decoration: BoxDecoration(
                          // shape: BoxShape.circle,
                            borderRadius: BorderRadius.circular(20), // 둥근 모서리 반경 설정
                            color: Colors.orange
                        ),
                        child: Text(
                          widget.unReadCount.toString(),
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ),
                  )
                ),
                Positioned(
                  right: 0,
                  top: 3,
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
