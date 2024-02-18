import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:go_together/utils/string.dart';
import 'package:logger/logger.dart';

import '../main.dart';

class FlutterLocalNotification {
  FlutterLocalNotification._();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // 모든 알림 삭제.
  static Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  static init() async {
    AndroidInitializationSettings androidInitializationSettings =
    const AndroidInitializationSettings('mipmap/ic_launcher');

    DarwinInitializationSettings iosInitializationSettings =
    const DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: iosInitializationSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotificationResponse
    );
  }

  //! Foreground 상태(앱이 열린 상태에서 받은 경우)
  static void onDidReceiveNotificationResponse(NotificationResponse notificationResponse) async {
    //! Payload(전송 데이터)를 Stream에 추가합니다.
    Logger logger = Logger();
    String payload = notificationResponse.payload ?? "";
    switch (notificationResponse.notificationResponseType) {
      case NotificationResponseType.selectedNotification:
        logger.e('selectedNotification');
        if (notificationResponse.payload != null ||
            notificationResponse.payload!.isNotEmpty) {
          logger.e('로컬 알림: 받음');

          // StreamBuilder 위젯 호출하기.
          streamController.add(payload);
        }        break;
      case NotificationResponseType.selectedNotificationAction:
        logger.e('selectedNotificationAction');

        // if (notificationResponse.actionId == navigationActionId) {
        //   // selectNotificationStream.add(notificationResponse.payload);
        // }
        break;
    }
  }

  static requestNotificationPermission() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true
    );
  }

  static Future<void> showNotification(String? chID, String? title, String? body) async {
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(chID ?? 'id', 'channelName',
        channelDescription: 'description',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: false
    );

    NotificationDetails notificationDetails =
      NotificationDetails(
        android: androidNotificationDetails,
        iOS: DarwinNotificationDetails(badgeNumber: 1)
      );

    await flutterLocalNotificationsPlugin.show(
        0, title, body, notificationDetails, payload: SystemData.chatStreamStr);
  }
}