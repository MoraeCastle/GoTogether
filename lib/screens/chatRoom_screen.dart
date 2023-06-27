import 'package:flutter/material.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:provider/provider.dart';

/// 채팅방 씬
class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataClass>(context);

    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            child: Text(
              '채팅방' + data.travel.getTitle(),
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
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    ChatRoomItem(),
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

// 채팅방 아이템
class ChatRoomItem extends StatefulWidget {
  //final ChatRoom roomData;

  const ChatRoomItem({
    Key? key,
    //required this.roomData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ChatRoomItem();
}

class _ChatRoomItem extends State<ChatRoomItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
          onPressed: () {},
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
                          '채팅방 이름',
                          style: TextStyle(fontSize: 25),
                        ),
                        Container(height: 5),
                        Text(
                          '내용',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 15, right: 5),
                      child: Text(
                        '시간',
                        style: TextStyle(fontSize: 15),
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
