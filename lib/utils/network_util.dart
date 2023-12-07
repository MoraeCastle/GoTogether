// 앱 내 주요 기능관련 클래스.
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/Room.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 통신 관련
class NetworkUtil {
  /// 이 유저가 가이드인지?
  static Future<bool> isGuild(Travel travel) async {
    Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    var userStr = prefs.getString(SystemData.userCode) ?? "";

    for (String userItem in travel.getUserList().keys) {
      if (userItem == userStr && travel.getUserList()[userItem]!.getAuthority() == describeEnum(UserType.guide)) {
        return true;
      }
    }

    return false;
  }

  /// 채팅방 입장
  static Future<bool> joinChatRoom(String travelCode, User user, String roomName) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('chat/$travelCode').get();

    if (snapshot.exists) {
      var result = snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        for (Room room in chat.getRoomList()) {
          if (room.getTitle() == roomName) {
            room.getUserMap()[user.getUserCode()] = 0;

            await ref.child('chat/$travelCode').set(chat.toJson());
            return true;
          }
        }

        return false;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 채팅방 생성(공지)
  static Future<void> createNoticeChatRoom(String travelCode, User user) async {
    Logger logger = Logger();
    logger.e("채팅방 생성");

    final ref = FirebaseDatabase.instance.ref();

    Chat chat = Chat();
    Room _newRoom = Room();
    _newRoom.setTitle(SystemData.noticeName);
    _newRoom.setState(1);
    _newRoom.setUserMap({
      user.userCode : 0,
    });

    chat.getRoomList().add(_newRoom);

    await ref.child('chat/$travelCode').set(chat.toJson());
  }
}