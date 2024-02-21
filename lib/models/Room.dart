import 'package:chatview/chatview.dart';
import 'package:go_together/models/MessageItem.dart';

// 채팅방 객체
class Room {
  late String title; // 채팅방 이름 + 인원숫자(겹치는 채팅방 방지)
  late String profile; // 방 프로필 네트워크 이미지링크
  late Map<String, int> userMap; // 유저리스트, 체크카운터의 값을 가진다.
  late List<MessageItem> messageList; // 대화 리스트
  late int state; // 채팅방 상태 (1이면 공지)
  late List<String> currentPeople; // 현재 방에 있는 인원.

  Room() {
    title = "";
    profile = "";
    userMap = {};
    messageList = [];
    state = 0;
    currentPeople = [];
  }

  void setTitle(String data) {
    this.title = data;
  }
  String getTitle() {
    return title;
  }

  void setProfile(String data) {
    this.profile = data;
  }
  String getProfile() {
    return profile;
  }

  void setUserMap(Map<String, int> data) {
    this.userMap = data;
  }
  Map<String, int> getUserMap() {
    return userMap;
  }
  void deleteUser(String userCode) {
    userMap.removeWhere((key, value) => key == userCode);
  }

  void setMessageList(List<MessageItem> data) {
    this.messageList = data;
  }
  List<MessageItem> getMessageList() {
    return messageList;
  }

  void setState(int data) {
    this.state = data;
  }
  int getState() {
    return state;
  }

  // 현재 채팅방에 있는 인원상태 관련
  void setCurrentPeople(List<String> data) {
    currentPeople = data;
  }
  List<String> getCurrentPeople() {
    return currentPeople;
  }
  void addCurrent(String user) {
    if (!currentPeople.contains(user)) {
      currentPeople.add(user);
    }
  }
  void removeCurrent(String user) {
    if (currentPeople.contains(user)) {
      currentPeople.removeWhere((target) => target == user);
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'profile': profile,
      'userMap': userMap,
      'messageList': messageList?.map((s) => s.toJson())?.toList() ?? [],
      'state': state,
      'currentPeople': currentPeople,
    };
  }

  factory Room.fromJson(json) {
    final room = Room();
    room.title = json['title'] ?? "";
    room.profile = json['profile'] ?? "";
    room.userMap = Map<String, int>.from(json['userMap'] ?? {});
    room.messageList = (json['messageList'] as List<dynamic>?)
        ?.map((messageJson) => MessageItem.fromJson(messageJson))
        .toList() ??
        [];
    room.state = json['state'] ?? 0;
    room.currentPeople = json['currentPeople'] != null
        ? List<String>.from(json['currentPeople'])
        : <String>[];

    return room;
  }

  // 답글에 해당하는 항목을 가져옵니다.
  ReplyMessage getReplyMessage(int targetMessageId, String sendBy) {
    ReplyMessage result = const ReplyMessage();

    for (MessageItem item in getMessageList()) {
      if (item.getId() == targetMessageId) {

        result = ReplyMessage(
          message: item.getMessage(),
          replyTo: item.sendBy,
          replyBy: sendBy,
          messageId: item.getId().toString(),
        );
        break;
      }
    }

    return result;
  }

  /// 출력용 chatview 메세지 객체 리스트를 반환합니다.
  List<Message> getChatList() {
    if (getMessageList().isEmpty) return [];

    List<Message> resultList = [];

    Message newChat;
    for (MessageItem item in getMessageList()) {
      newChat = Message(
        id: item.getId().toString(),
        createdAt: DateTime.parse(item.getCreatedAt()),
        message: item.getMessage(),
        sendBy: item.getSendBy(),
        messageType: item.getChatType(),
        replyMessage: getReplyMessage(item.getReplyMessageId(), item.getSendBy()),
        reaction: item.getChatReaction(),
        // 임시로 모두 읽음처리..
        status: MessageStatus.read,
      );

      resultList.add(newChat);
    }

    return resultList;
  }
}
