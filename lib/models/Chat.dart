// 채팅 데이터베이스 객체
import 'package:go_together/models/Room.dart';

class Chat {
  late List<Room> roomList;

  Chat() {
    roomList = [];
  }

  void setRoomList(List<Room> data) {
    this.roomList = data;
  }
  List<Room> getRoomList() {
    return roomList;
  }

  Map<String, dynamic> toJson() {
    return {
      'roomList': roomList?.map((s) => s.toJson())?.toList() ?? [],
    };
  }

  factory Chat.fromJson(json) {
    // factory Chat.fromJson(Map<String, dynamic> json) {
    final chat = Chat();
    var data = (json['roomList'] as List<dynamic>? ?? [])
        .map((item) => Room.fromJson(Map<String, dynamic>.from(item)))
        .toList();
    chat.setRoomList(data);
    return chat;
  }
}
