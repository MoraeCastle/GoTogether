import 'package:flutter/material.dart';

/// 채팅방 씬
class ChatRoomView extends StatelessWidget {
  const ChatRoomView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: const SingleChildScrollView(
                padding: EdgeInsets.all(10),
              ),
            ),
          )
        ],
      ),
    );
  }
}
