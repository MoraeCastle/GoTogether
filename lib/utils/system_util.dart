// 앱 내 주요 기능관련 클래스.
import 'dart:math';

class SystemUtil {
  // 그룹코드 생성.
  static String generateGroupCode() {
    // 코드문자 리스트.
    var random = Random();
    var travelIdTable = [
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

    StringBuffer result = StringBuffer();
    result.write('T-');

    for (int i = 0; i < 5; i++) {
      result.write(travelIdTable[random.nextInt(travelIdTable.length - 1)]);
    }

    return result.toString();
  }
}
