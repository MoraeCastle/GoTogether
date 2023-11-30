// 앱 내 주요 기능관련 클래스.
import 'dart:io';
import 'dart:math';

import 'package:bot_toast/bot_toast.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SystemUtil {
  static List<String> codeTable = [
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '0'
  ];

  /// 기기 고유값 가져오기
  static Future<String?> getDeviceCode() async {
    var deviceInfo = DeviceInfoPlugin();

    if (Platform.isIOS) { // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;

      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;

      return androidDeviceInfo.id; // unique ID on Android
    } else {
      var webDevice = await deviceInfo.webBrowserInfo;

      return webDevice.product;
    }
  }

  // 기기 내에 여행정보 저장.
  static Future<void> saveTravel(Travel data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SystemData.trvelCode, data.travelCode);
  }

  /// 기기 내에 유저정보 저장.
  static Future<void> saveUser(User data) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SystemData.userCode, data.getUserCode());
    await prefs.setString(SystemData.userName, data.getName());
  }

  /// 기기값 초기화.
  static Future<void> resetDeviceSetting() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(SystemData.userCode);
    prefs.remove(SystemData.userName);
  }

  /// 그룹코드 생성.
  static String generateGroupCode() {
    // 코드문자 리스트.
    var random = Random();

    StringBuffer result = StringBuffer();
    result.write('T-');

    for (int i = 0; i < 5; i++) {
      result.write(codeTable[random.nextInt(codeTable.length - 1)]);
    }

    return result.toString();
  }

  /// 유저코드 생성.
  static String generateUserCode() {
    // 코드문자 리스트.
    var random = Random();

    StringBuffer result = StringBuffer();

    for (int i = 0; i < 4; i++) {
      result.write(codeTable[random.nextInt(codeTable.length - 1)]);
    }

    return result.toString();
  }

  /// 시작일, 종료일 데이터를 문자열로 받는다.
  /// ex. xxxx-xx-xx,xxxx-xx-xx
  static String getTravelDate(DateTime? startDate, DateTime? endDate) {
    return "${startDate.toString().split(' ')[0]},${endDate.toString().split(' ')[0]}";
  }

  /// 날짜를 받고 차이 일수를 반환합니다.
  static int getTravelDay(String date) {
    var dataArray = date.split(',');

    if (dataArray.length == 2) {
      DateTime startDate = DateTime.parse(dataArray[0]);
      DateTime endDate = DateTime.parse(dataArray[1]);

      return endDate.difference(startDate).inDays + 1;
    } else {
      return 0;
    }
  }

  /// 해당 날짜가 범위 안에 있는지 판별합니다.
  static bool isDateInSchedule(String dateStr, DateTime target) {
    if (dateStr.isEmpty) return false;

    DateTime startDate = changeDateTime(dateStr, 0);
    DateTime endDate = changeDateTime(dateStr, 1);
    startDate = DateTime(startDate.year, startDate.month, startDate.day - 1);
    endDate = DateTime(endDate.year, endDate.month, endDate.day + 1);

    return startDate.isBefore(target) && endDate.isAfter(target);
  }

  /// 시간을 받아서 DateTime으로 변환합니다.
  static DateTime changeDateTimeFromClock(DateTime date, String clock) {
    // "오전" 또는 "오후"를 제거하고 시간과 분을 추출
    List<String> components = clock.split(' ');

    // 일부 기기는 24시간으로 설정되면 오전 오후 없음.
    String timeWithoutPeriod = components.length > 1 ? components[1] : components[0];
    List<String> timeComponents = timeWithoutPeriod.split(':');
    // 시간과 분을 정수로 변환
    int hour = int.parse(timeComponents[0]);
    int minute = int.parse(timeComponents[1]);
    // "오후"일 경우 시간을 조정
    if (components[0] == "오후") {
      hour = (hour + 12) % 24;
    }

    // TimeOfDay 객체 생성
    TimeOfDay timeOfDay = TimeOfDay(hour: hour, minute: minute);
    date = DateTime(date.year, date.month, date.day, timeOfDay.hour, timeOfDay.minute);

    return date;
  }

  /// 날짜를 받아서 DateTime으로 변환합니다.
  static DateTime changeDateTime(String dateRange, int isStartDay) {
    DateTime resultDate = DateTime(2023, 1, 1);

    if (dateRange.isNotEmpty) {
      String date = isStartDay == 0 ? dateRange.split(",")[0] : dateRange.split(",")[1];
      List<int> dateList = date.split("-").toList().map(int.parse).toList();

      resultDate = DateTime(dateList[0], dateList[1], dateList[2]);
    }

    return resultDate;
  }

  /// DateTime을 String으로 변환합니다.(자릿수채움)
  static String changePrintDateOnlyDate(DateTime date) {
    String result = date.year.toString() + "-"
        + date.month.toString().padLeft(2, '0') + "-"
        + date.day.toString().padLeft(2, '0');

    return result;
  }

  /// HH:MM 날짜 비교
  static bool isDateSame(DateTime time, String timeStr) {
    return timeStr
        == "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  /// 날짜를 받아서 출력용 데이터로 변환합니다.
  static String changePrintDate(String date) {
    String resultDate = '';

    var dataArray = date.split(',');

    if (dataArray.length == 2) {
      // DateTime startDate = DateTime.parse(dataArray[0]);
      // DateTime endDate = DateTime.parse(dataArray[1]);

      return dataArray[0].substring(2, dataArray[0].length) + ' ~ '
       + dataArray[1].substring(2, dataArray[0].length);
    } else {
      return '';
    }
  }

  /// 문자방식의 위치(LatLng) 값을 원래 데이터로 변환합니다.
  static LatLng convertStringPosition(String position) {
    LatLng answer = LatLng(0, 0);

    if (position.isEmpty) return answer;

    List<String> array = position.split(",");

    if (array.length != 2) return answer;
    return LatLng(double.parse(array[0]), double.parse(array[1]));
  }

  /// 위치 선택 초기화
  static void resetTargetPosition() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(SystemData.selectPosition);
  }
}

/// 대문자 형식
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: capitalize(newValue.text),
      selection: newValue.selection,
    );
  }

  String capitalize(String value) {
    if (value.trim().isEmpty) return "";

    return value.toUpperCase();
  }
}
