import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:dio/dio.dart';
import 'package:geocoding/geocoding.dart';
import 'package:go_together/utils/string.dart';
import 'package:logger/logger.dart';
import 'package:xml/xml.dart';
import 'package:html/parser.dart';

/// 공공 데이터 포털 유틸
class OpenDataUtil {
  static Logger logger = Logger();

  /// HTML 태그 제거.
  static String parseHtmlString(String htmlString) {
    final document = parse(htmlString);
    final String parsedString = parse(document.body!.text).documentElement!.text;

    return parsedString;
  }

  /// 국가코드에 따른 국가데이터 가져오기
  static Country getCountryData(String countryCode) {
    return CountryPickerUtils.getCountryByIsoCode(countryCode);
  }

  /// 국가코드에 따른 국가 대표위치 가져오기.
  static Future<Location> getLocationToName(Country data) async {
    // 해당 국가이름으로 위치 조회....(geocoding)
    List<Location> locations = await locationFromAddress(
      data.name,
      localeIdentifier: "en_EN",
    );

    return locations[0];
  }

  /// 국가 기본정보 가져오기.
  static Future<CountryNormalInfo> getDefaultInfo(Country data) async {
    logger.e('getDefaultInfo');
    final dio = Dio();
    final response = await dio.get(
      'http://apis.data.go.kr/1262000/CountryBasicService/getCountryBasicList?ServiceKey='
          '${SystemData.openDataAPIKey}&isoCode1='
          '${data.iso3Code}',
    );

    if (response.statusCode == 200) {
      logger.e('GET >> ${response.data}');
      return CountryNormalInfo.fromXml(response.data.toString());
    } else {
      return CountryNormalInfo(
        id: 0,
        continent: '',
        countryEnName: '',
        countryName: '',
        imgUrl: '',
        resultCode: '',
        resultMsg: '',
        wrtDt: '',
        basicContent: '',
      );
    }
  }

  /// 국가 사건/사고정보 가져오기.
  static Future<WarningContentItem> getWarningInfo(Country data) async {
    final dio = Dio();
    final response = await dio.get(
      'http://apis.data.go.kr/1262000/CountryAccidentService2/CountryAccidentService2?serviceKey='
          '${SystemData.openDataAPIKey}&cond[country_iso_alp2::EQ]='
          '${data.isoCode}',
      // '${data.isoCode}&returnType=XML',
    );

    Map<String, dynamic> json = response.data;

    if (response.statusCode == 200) {
      return WarningContentItem.fromJson(json['data'][0]);
    } else {
      return WarningContentItem(
        wrtDt: '',
        continentCd: '',
        continentEngNm: '',
        continentNm: '',
        countryEngNm: '',
        countryIsoAlp2: '',
        countryNm: '',
        dangMapDownloadUrl: '',
        flagDownloadUrl: '',
        mapDownloadUrl: '',
        news: '',
      );
    }
  }

  /// 국가 안전정보 가져오기.
  static Future<List<SafeItem>> getSafeInfo(String searchTitle) async {
    final dio = Dio();
    final response = await dio.get(
      'http://apis.data.go.kr/1262000/CountrySafetyService/getCountrySafetyList?ServiceKey='
          '${SystemData.openDataAPIKey}&numOfRows=10&pageNo=1&title='
          '${searchTitle}',
    );

    if (response.statusCode == 200) {
      SafeInfo safeInfo = SafeInfo.fromXml(response.data);

      return safeInfo.items;
    } else {
      return [];
    }
  }
}

/// 국가 기본정보
class CountryNormalInfo {
  String resultCode;
  String resultMsg;
  String continent;
  String countryEnName;
  String countryName;
  int id;
  String imgUrl;
  String wrtDt;
  String basicContent; // 추가된 부분

  CountryNormalInfo({
    required this.resultCode, // 반환상태
    required this.resultMsg,  // 내용
    required this.continent,  // 대륙
    required this.countryEnName,  // 나리명(영문)
    required this.countryName,  // 나라명
    required this.id, // 고유 키값
    required this.imgUrl, // 국기 플래그
    required this.wrtDt,  // 마지막 업데이트
    required this.basicContent, // 추가된 부분
  });

  factory CountryNormalInfo.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final header = document.rootElement.findElements('header').single;
    final body = document.rootElement.findElements('body').single;
    final item = body.findElements('items').single.findElements('item').single;
    final basic = item.findElements('basic').single;

    return CountryNormalInfo(
      resultCode: header.findElements('resultCode').single.text,
      resultMsg: header.findElements('resultMsg').single.text,
      continent: item.findElements('continent').single.text,
      countryEnName: item.findElements('countryEnName').single.text,
      countryName: item.findElements('countryName').single.text,
      id: int.parse(item.findElements('id').single.text),
      imgUrl: item.findElements('imgUrl').single.text,
      wrtDt: item.findElements('wrtDt').single.text,
      basicContent: OpenDataUtil.parseHtmlString(basic.text), // 추가된 부분
    );
  }
}

/// 국가 사건/사고 정보
class WarningItem {
  final int currentCount;
  final List<WarningContentItem> data;
  final int numOfRows;
  final int pageNo;
  final int resultCode;
  final String resultMsg;
  final int totalCount;

  WarningItem({
    required this.currentCount,
    required this.data,
    required this.numOfRows,
    required this.pageNo,
    required this.resultCode,
    required this.resultMsg,
    required this.totalCount,
  });

  factory WarningItem.fromJson(Map<String, dynamic> json) {
    return WarningItem(
      currentCount: json['currentCount'],
      data: (json['data'] as List).map((item) => WarningContentItem.fromJson(item)).toList(),
      numOfRows: json['numOfRows'],
      pageNo: json['pageNo'],
      resultCode: json['resultCode'],
      resultMsg: json['resultMsg'],
      totalCount: json['totalCount'],
    );
  }
}

class WarningContentItem {
  final String continentCd;
  final String continentEngNm;
  final String continentNm;
  final String countryEngNm;
  final String countryIsoAlp2;
  final String countryNm;
  final String dangMapDownloadUrl;
  final String flagDownloadUrl;
  final String mapDownloadUrl;
  final String news;
  final String wrtDt;

  WarningContentItem({
    required this.continentCd,  // 대륙코드
    required this.continentEngNm, // 대륙명(영문)
    required this.continentNm,  // 대륙명
    required this.countryEngNm, // 국가명(영문)
    required this.countryIsoAlp2, // ISO코드(2자리)
    required this.countryNm,  // 국가명
    required this.dangMapDownloadUrl, // 위험지도경로
    required this.flagDownloadUrl, // 국기다운로드링크
    required this.mapDownloadUrl, // 지도다운로드경로
    required this.news, // 뉴스
    required this.wrtDt,  // 작성일
  });

  factory WarningContentItem.fromJson(Map<String, dynamic> json) {
    return WarningContentItem(
      continentCd: json['continent_cd'],
      continentEngNm: json['continent_eng_nm'],
      continentNm: json['continent_nm'],
      countryEngNm: json['country_eng_nm'],
      countryIsoAlp2: json['country_iso_alp2'],
      countryNm: json['country_nm'],
      dangMapDownloadUrl: json['dang_map_download_url'],
      flagDownloadUrl: json['flag_download_url'],
      mapDownloadUrl: json['map_download_url'],
      news: OpenDataUtil.parseHtmlString(json['news']),
      wrtDt: json['wrt_dt'],
    );
  }
}

/// 국가 안전정보
class SafeInfo {
  late String resultCode;
  late String resultMsg;
  late List<SafeItem> items;

  SafeInfo.fromXml(String xmlString) {
    final document = XmlDocument.parse(xmlString);
    final response = document.rootElement;
    final header = response.findElements('header').first;
    final body = response.findElements('body').first;

    resultCode = header.findElements('resultCode').first.text;
    resultMsg = header.findElements('resultMsg').first.text;

    items = body.findElements('items').expand((items) {
      return items.findElements('item').map((item) => SafeItem.fromXml(item));
    }).toList();
  }
}

class SafeItem {
  late String content;
  late String countryEnName;
  late String countryName;
  late String fileUrl;
  late String id;
  late String title;
  late String wrtDt;

  SafeItem.fromXml(XmlElement element) {
    content = OpenDataUtil.parseHtmlString(element.findElements('content').first.text);
    countryEnName = element.findElements('countryEnName').first.text;
    countryName = element.findElements('countryName').first.text;
    fileUrl = element.findElements('fileUrl').first.text;
    id = element.findElements('id').first.text;
    title = element.findElements('title').first.text;
    wrtDt = element.findElements('wrtDt').first.text;
  }
}