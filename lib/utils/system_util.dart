// 앱 내 주요 기능관련 클래스.
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
