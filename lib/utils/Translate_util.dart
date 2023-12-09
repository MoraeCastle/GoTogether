import 'package:dio/dio.dart';
import 'package:go_together/utils/string.dart';

/// 번역기 기능
class TranslateUtil {
  static Future<String> translateText(String startLang, String endLang, String value) async {
    final dio = Dio();
    final response = await dio.post(
      'https://openapi.naver.com/v1/papago/n2mt',
      data: {
        'source': startLang, // 원본 언어 코드 (예: 한국어)
        'target': endLang, // 번역 언어 코드 (예: 영어)
        'text': value,
      },
      options: Options(
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'X-Naver-Client-Id': SystemData.naverClientID,
          'X-Naver-Client-Secret': SystemData.naverSecretID,
        },
      ),
    );

    if (response.statusCode == 200) {
      final data = response.data;
      final translatedText = data['message']['result']['translatedText'];

      return translatedText;
    } else {
      return '번역 실패: ${response.statusCode}';
    }
  }
}