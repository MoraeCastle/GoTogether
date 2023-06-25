// 앱 내 주요 기능관련 클래스.
import 'dart:math';

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

  // 그룹코드 생성.
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

  // 유저코드 생성.
  static String generateUserCode() {
    // 코드문자 리스트.
    var random = Random();

    StringBuffer result = StringBuffer();

    for (int i = 0; i < 4; i++) {
      result.write(codeTable[random.nextInt(codeTable.length - 1)]);
    }

    return result.toString();
  }

  // 시작일, 종료일 데이터를 문자열로 받는다.
  // ex. xxxx-xx-xx,xxxx-xx-xx
  static String getTravelDate(DateTime? startDate, DateTime? endDate) {
    return "${startDate.toString().split(' ')[0]},${endDate.toString().split(' ')[0]}";
  }
}
