// 앱 내 주요 기능관련 클래스.
import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
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
import 'package:image_picker/image_picker.dart';
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

  /// 전체 채팅방 중 읽지않은 메세지 수를 불러옵니다.
  static int getAllUnreadCount(List<Room> roomList, String userCode) {
    int result = 0;

    for (Room room in roomList) {
      if (room.getUserMap().keys.contains(userCode)) {
        int count = 0;
        count = room.getMessageList().length - room.getUserMap()[userCode]!;

        result += count;
      }
    }

    return result;
  }

  /// 공지방 프로필 이미지 가져오기.
  /// 추후 이미지 교체를 위해 구현.
  static Future<String> getNoticeProfileURL() async {
    final storageRef = FirebaseStorage.instance.ref();
    final result = await storageRef.child("System/room_notice.png");

    try {
      final listResult = await result.listAll();
      final imageUrl = await result.getDownloadURL();

      return imageUrl;
    } on FirebaseException catch (e) {
      // print("Failed with error '${e.code}': ${e.message}");
      // 오류의 경우 빈 문자열...
      return "";
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
    await deleteImage(travelCode, userCode);

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

  /// 미디어 관련
  ///
  ///
  /// 이미지 업로드
  /// 다운로드 링크가 반환됩니다.
  static Future<String> uploadImage(String travelCode, String userCode, XFile? image) async {
    if (image != null) {
      try {
        //현재 시간 저장
        final now = DateTime.now();
        File? selectedImage;
        selectedImage = File(image.path);

        // 이름 분리
        String imageType = "";
        List<String> imageName = image.name.split('.');
        if (imageName.length > 1) {
          imageType = imageName[imageName.length - 1];
          imageType = '.' + imageType;
        }

        //참조 생성
        final storageRef = FirebaseStorage.instance.ref();
        var ref = storageRef.child('$travelCode/$userCode' + imageType);

        String downloadURL = "";

        // 참조에 파일 저장
        // 상태에 따라. 아직은 완료되기만 구분. == 결과가 비어있으면 오류.
        await ref.putFile(selectedImage);
        downloadURL = await ref.getDownloadURL();

        return downloadURL;
      } catch (e) {
        return "";
      }
    } else {
      return "";
    }
  }
  /// 이미지 삭제.
  /// 모든 이미지가 삭제됩니다.
  static Future<bool> deleteImage(String travelCode, String userCode) async {
    try {
      // firebase
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('travel/$travelCode').get();

      var result = snapshot.value;
      if (result != null) {
        var travel = Travel.fromJson(result);

        for (User user in travel.getUserList().values) {
          if (user.getUserCode() == userCode) {
            user.setProfileURL('');

            break;
          }
        }

        await ref.child('travel/$travelCode').set(travel.toJson());
      }

      // storage
      final storageRef = FirebaseStorage.instance.ref().child(travelCode);
      final listResult = await storageRef.listAll();

      for (var item in listResult.items) {
        //  유저 코드 탐색
        if (item.name.contains(userCode)) {
          await storageRef.child(item.name).delete();
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}