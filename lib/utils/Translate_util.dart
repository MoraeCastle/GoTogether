import 'package:dio/dio.dart';
import 'package:go_together/utils/string.dart';
import 'package:translator/translator.dart';

/// 번역기 기능
class TranslateUtil {
  static Map<String, String> countryCode = {
    '한국어' : 'ko',
    '일본어' : 'ja',
    '중국어(간체)' : 'zh-CN',
    '중국어(번체)' : 'zh-TW',
    '힌디어' : 'hi',
    '영어' : 'en',
    '스페인어' : 'es',
    '프랑스어' : 'fr',
    '독일어' : 'de',
    '포루트갈어' : 'pt',
    '베트남어' : 'vi',
    '인도네시아어' : 'id',
    '페르시아어' : 'fa',
    '아랍어' : 'ar',
    '미얀마어' : 'mm',
    '태국어' : 'th',
    '러시아어' : 'ru',
    '이탈리아어' : 'it',
  };

  static GoogleTranslator translator = GoogleTranslator();

  /// 번역기(임시)
  static Future<String> translate(String startLang, String endLang, String value) async {
    var result = await translator.translate(
      value,
      from: startLang,
      to: endLang
    );

    return result.text;
  }

  /// 파파고. 요금문제로 폐기.
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