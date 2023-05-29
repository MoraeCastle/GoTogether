import 'chat.dart';

// 채팅방 객체
class ChatRoom {
  bool alive; // 활성화 여부
  List<Chat> chatList; // 채팅 리스트
  String lastCheckTime; // 마지막 확인 시간
  String newChatItem; // 채팅 갱신 시간
  // String recentMessage;
  String recentMassage; // 최근 메세지 내용
  String roomName; // 채팅방 이름
  String style; // 스타일
  Map<String, int> item;

  ChatRoom(this.alive, this.chatList, this.lastCheckTime, this.newChatItem,
      this.recentMassage, this.roomName, this.style, this.item);
}
