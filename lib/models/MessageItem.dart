import 'package:chatview/chatview.dart';

import 'Chat.dart';

// 채팅 객체
class MessageItem {
  late int id;
  late String createdAt;
  late String message;
  late String sendBy;
  late Map<String, String> reactionMap;
  late int replyMessageId;
  late String status;
  late String messageType;
  late int voiceMessageDuration;

  MessageItem() {
    id = 0;
    createdAt = "";
    message = "";
    sendBy = "";
    reactionMap = {};
    replyMessageId = 0;
    status = "";
    messageType = "";
    voiceMessageDuration = 0;
  }

  // Getter and Setter
  setId(int data) {
    id = data;
  }

  int getId() {
    return id;
  }

  setCreatedAt(String data) {
    createdAt = data;
  }

  String getCreatedAt() {
    return createdAt;
  }

  setMessage(String data) {
    message = data;
  }

  String getMessage() {
    return message;
  }

  setSendBy(String data) {
    sendBy = data;
  }
  String getSendBy() {
    return sendBy;
  }

  setReactionMap(Map<String, String> data) {
    reactionMap = data;
  }

  Map<String, String> getReactionMap() {
    return reactionMap;
  }

  Reaction getChatReaction() {
    return Reaction(
      reactions: getReactionMap().keys.toList(),
      reactedUserIds: getReactionMap().values.toList(),
    );
  }

  setReplyMessageId(int data) {
    replyMessageId = data;
  }
  int getReplyMessageId() {
    return replyMessageId;
  }

  setStatus(String data) {
    status = data;
  }
  String getStatus() {
    return status;
  }
  MessageStatus getChatStatus() {
    /// 임시...
    return MessageStatus.read;
  }

  setMessageType(String data) {
    messageType = data;
  }

  String getMessageType() {
    return messageType;
  }

  MessageType getChatType() {
    if (message.contains("http")) {
      return MessageType.image;
    }
    return MessageType.text;
  }

  setVoiceMessageDuration(int data) {
    voiceMessageDuration = data;
  }

  int getVoiceMessageDuration() {
    return voiceMessageDuration;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt,
      'message': message,
      'sendBy': sendBy,
      'reactionMap': reactionMap,
      'replyMessageId': replyMessageId,
      'status': status,
      'messageType': messageType,
      'voiceMessageDuration': voiceMessageDuration,
    };
  }

  // Map을 사용하여 fromJson 메서드 작성
  factory MessageItem.fromJson(json) {
    var item = MessageItem();
    item.id = json['id'] ?? 0;
    item.createdAt = json['createdAt'] ?? "";
    item.message = json['message'] ?? "";
    item.sendBy = json['sendBy'] ?? "";
    item.reactionMap = Map<String, String>.from(json['userMap'] ?? {});
    item.replyMessageId = json['replyMessageId'] ?? 0;
    item.status = json['status'] ?? "";
    item.messageType = json['messageType'] ?? "";
    item.voiceMessageDuration = json['voiceMessageDuration'] ?? 0;

    return item;
  }
}
