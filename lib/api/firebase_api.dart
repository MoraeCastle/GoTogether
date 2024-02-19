import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_together/main.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/notification.dart';
import 'package:go_together/utils/string.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 백그라운드 알림이 도착 했을 때. 알림을 탭하지 않아도 작동됨.
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  Logger logger = Logger();
  // logger.e('Title: ${message.notification?.title}');
  // logger.e('Body: ${message.notification?.body}');
  // logger.e('Payload: ${message..data}');
  logger.e('백그라운드 메세지 도착...');
}

/// 포그라운드 알림이 도착 했을 때. 알림을 탭하지 않아도 작동됨.
Future<void> handleForegroundMessage(RemoteMessage message) async {
  Logger logger = Logger();
  logger.e('포그라운드 메세지 도착...');

  FlutterLocalNotification.showNotification(
      message.notification?.title,
      message.notification?.title,
      message.notification?.body
  );
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  /// 알림을 탭한 경우.
  Future<void> handleMessage(RemoteMessage? message) async {
    if (message == null) return;

    Logger logger = Logger();
    logger.e('알림 클릭.');

    // 채팅 읽음상태 갱신.
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SystemData.chatUnread, true);
  }

  Future initPushNotifications() async {
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true
    );

    // 앱이 종료된 상태에서 열릴 때.
    FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
    // 앱이 백그라운드에서 열릴 때.
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
    // 알림이 도착하면 작동됨.
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
    // 앱이 켜진 상태에서 받을 때.
    if (Platform.isAndroid) {
      // 아이폰의 경우 포그라운드는 자동...
      FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    }
  }

  /// FCM 초기화.
  Future<void> initNotifications(BuildContext context) async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();

    if(Platform.isAndroid) {
      await Permission.ignoreBatteryOptimizations.request();
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      final fcmToken = await _firebaseMessaging.getToken();

      Logger logger = Logger();
      logger.e('Token: ${fcmToken!}');

      // 기기 내에 토큰값 저장.
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(SystemData.fcmToken, fcmToken ?? '');

      initPushNotifications();
    } else {
      BotToast.showText(text: '알림 권한은 앱 설정에서 허용할 수 있습니다.');
    }
  }
}