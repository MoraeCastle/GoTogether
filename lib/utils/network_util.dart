// 앱 내 주요 기능관련 클래스.
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/main.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/models/Room.dart';
import 'package:go_together/models/RouteItem.dart';
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
    /*Logger logger = Logger();
    logger.e("채팅방 생성");*/

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

  /// 유저 이름 변경
  static Future<bool> changeUserName(String travelCode, String userCode, String newCode) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();

    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);

      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == userCode) {
          user.setName(newCode);
          break;
        }
      }

      await ref.child('travel/$travelCode').set(travel.toJson());

      return true;
    } else {
      return false;
    }
  }

  /// 공지 쓰기
  static Future<void> writeNotice(
      String noticeCode, String title, String url, String writeTime, String limit
      ) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('chat/').get();
    var noticeItem = Notice();

    var result = snapshot.value;
    if (result != null) {
      /*Logger logger = Logger();
      logger.e(result.toString());*/

      noticeItem.setNoticeCode(noticeCode);
      noticeItem.setTitle(title);
      noticeItem.setUrl(url);
      noticeItem.setUpdateTime(writeTime);
      noticeItem.setTimeLimit(limit);

      /*var travel = Notice.fromJson(result);

      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == userCode) {
          user.setName(newCode);
          break;
        }
      }
*/
      await ref.child('notice/').child(noticeItem.getNoticeCode()).set(noticeItem.toJson());
    } else {
    }
  }

  /// 공지 가져오기
  static Future<Map<String, Notice>> getNoticeList() async {
    Map<String, Notice> noticeMap = {};

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('notice/').get();

    var result = snapshot.value as Map?;
    if (result != null) {
      // Logger logger = Logger();

      for (String code in result.keys) {
        noticeMap[code] = Notice.fromJson(result[code]);
      }

      /*var travel = Notice.fromJson(result);

      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == userCode) {
          user.setName(newCode);
          break;
        }
      }

      await ref.child('travel/$travelCode').set(travel.toJson());*/

      return noticeMap;
    } else {
      return {};
    }
  }

  /// 로그아웃(탈퇴)
  static Future<bool> logout(String travelCode, String userCode) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();

    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);
      travel.deleteUser(userCode);

      await ref.child('travel/$travelCode').set(travel.toJson());

      // 채팅목록에서 제외하기.
      bool chatState = false;
      chatState = await exitALLChatRoom(travelCode, userCode);

      return chatState;
    } else {
      return false;
    }
  }

  /// 모든 채팅방 나가기
  /// 규칙: 채팅 내용은 남겨져 있음. 인원만 삭제
  static Future<bool> exitALLChatRoom(String travelCode, String userCode) async {
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('chat/$travelCode').get();

    if (snapshot.exists) {
      var result = snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        for (Room room in chat.getRoomList()) {
          if (room.getUserMap().keys.contains(userCode)) {
            room.deleteUser(userCode);
          }
        }

        await ref.child('chat/$travelCode').set(chat.toJson());
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }

  /// 일정 관련 메소드
  /// 
  /// 
  /// 
  /// 일정 삭제
  static Future<bool> removeSchedule(String travelCode, String day, String title, String startTime, String endTime) async {
    bool answer = false;
    
    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();

    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);

      var schedule = travel.getSchedule();

      if (schedule.isNotEmpty) {
        Map<String, List<RouteItem>> routeMap = schedule.first.getRouteMap();

        if (routeMap.containsKey(day)) {
          if (routeMap[day] != null) {
            RouteItem? target;
            for (RouteItem data in routeMap[day]!) {
              if (data.getRouteName() == title) {
                if (data.getStartTime() == startTime && data.getEndTime() == endTime) {
                  target = data;
                  break;
                }
              }
            }

            if (target != null && target.position.isNotEmpty) {
              routeMap[day]!.remove(target);

              await ref.child('travel/$travelCode').set(travel.toJson());
              
              answer = true;
            }
          }
        }
      }
    }

    return answer;
  }
}