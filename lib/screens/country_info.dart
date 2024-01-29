import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:chatview/chatview.dart';
import 'package:country_pickers/country.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/open_data_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 여행지 정보 목록 씬
class CountryInfoView extends StatefulWidget {
  const CountryInfoView({Key? key, required this.arguments}) : super(key: key);
  final String arguments;

  @override
  State<StatefulWidget> createState() => _CountryInfoViewState();
}

class _CountryInfoViewState extends State<CountryInfoView> {
  var logger = Logger();
  String targetCountry = "KR";
  // 검색용...
  String searchCode = "";

  Completer<GoogleMapController> _controller = Completer();
  Set<Circle> _circles = Set();
  late Country countryData;

  CountryNormalInfo? normalInfo;
  WarningContentItem? warningContent;
  List<SafeItem> safeNoticeList = [];
  List<Widget> safeItemList = [];

  bool dataSet = false;
  LatLng countryLocation = LatLng(0, 0);

  @override
  void initState() {
    super.initState();
    targetCountry = widget.arguments;
    searchCode = targetCountry[0].toLowerCase() + targetCountry[1];

    searchCountry(targetCountry);
  }

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  /// 국가를 조회합니다.
  /// 조회내용: 기본정보
  Future<void> searchCountry(String code) async {
    // 지도 최신화.
    countryData = OpenDataUtil.getCountryData(code);

    var location = await OpenDataUtil.getLocationToName(countryData);
    GoogleMapController controller = await getController();
    controller.moveCamera(CameraUpdate.newLatLngZoom(LatLng(location.latitude, location.longitude), 3));

    _addCircle(LatLng(location.latitude, location.longitude));

    // 기본정보 가져오기
    normalInfo = await OpenDataUtil.getDefaultInfo(countryData);
    warningContent = await OpenDataUtil.getWarningInfo(countryData);
    safeNoticeList = await OpenDataUtil.getSafeInfo(normalInfo!.countryName);

    for (SafeItem item in safeNoticeList) {
      // 빈 항목들은 제외.
      if (item.content.length < 10) continue;

      safeItemList.add(
        SafeItemWidget(
          item: item,
          onTap: () {
            CustomDialog.showSimpleDialog(
              context,
              '안전 정보',
              Column(
                children: [
                  Visibility(
                    visible: item.fileUrl.isNotEmpty,
                    child: Column(
                      children: [
                        Image.network(
                          item.fileUrl,
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                      : null,
                                ),
                              );
                            }
                          },
                          errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                            return Text('Error loading image: $error');
                          },
                        ),
                        const SizedBox(height: 15),
                      ],
                    )
                  ),
                  Text(
                    item.content,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.normal
                    ),
                  ),
                ],
              ),
            );
          },
        )
      );
    }

    dataSet = true;

    setState(() {

    });
  }

  void _addCircle(LatLng position) {
    setState(() {
      _circles.add(Circle(
        circleId: CircleId('korea_circle'),
        center: position, // Seoul, South Korea (you can set your desired location)
        radius: 500000, // Set the radius as per your requirement
        fillColor: Colors.blue.withOpacity(0.2), // Set your desired fill color
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                CustomDialog.oneButton(
                  context, Icons.info_outline_rounded, '안내', '외교부에서 제공한 데이터입니다.'
                    , null, '확인', () {
                    Navigator.pop(context);
                  }, false
                );
              },
              icon: const Icon(
                  Icons.info_outline_rounded,
                color: Colors.white,
              ),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '여행지 정보',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(200),
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(150, 255, 255, 255),
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 3.0), //(x,y)
                  blurRadius: 3.0,
                ),
              ],
            ),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                          width: double.infinity,
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                // 내부 스크롤......
                                Container(
                                    width: double.infinity,
                                    height: 200,
                                    margin: EdgeInsets.all(10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black87,
                                          offset: Offset(0.0, 1.0),
                                          blurRadius: 3.0,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      children: [
                                        GoogleMap(
                                          zoomControlsEnabled: false,
                                          zoomGesturesEnabled: false,
                                          circles: _circles,
                                          onMapCreated: (controller) {
                                            if (!_controller.isCompleted) _controller.complete(controller);
                                          },
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(37.5665, 126.9780), // Seoul, South Korea (you can set your desired location)
                                            zoom: 3.0,
                                          ),
                                        ),
                                        Positioned(
                                          right: 5,
                                          top: 5,
                                          child: Visibility(
                                            visible: dataSet,
                                            child: OutlinedButton(
                                              onPressed: () {
                                                CustomDialog.showSimpleDialogImg(
                                                  context,
                                                  '위험경보 지역',
                                                  warningContent!.dangMapDownloadUrl,
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                  backgroundColor: Colors.black.withAlpha(200),
                                                  padding: EdgeInsets.only(left: 12, right: 12)
                                              ),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Icons.warning_rounded,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  SizedBox(width: 5),
                                                  Text(
                                                    '여행경보',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(12.0), // 테두리의 둥근 정도를 조절
                                        child: Image.network(
                                          normalInfo?.imgUrl ?? '',
                                          height: 100,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                        flex: 3,
                                        child: Container(
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.white.withAlpha(180),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          margin: EdgeInsets.only(right: 15),
                                          // color: Colors.black,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                normalInfo?.countryName ?? '',
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                normalInfo?.countryEnName ?? '',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Column(
                                    children: [
                                      CountryViewItem(
                                        icon: Icons.info_outline,
                                        backColor: Colors.white.withAlpha(100),
                                        title: '기본 정보',
                                        onTap: () {
                                          CustomDialog.showSimpleDialogTxt(
                                              context, '기본 정보', normalInfo!.basicContent);
                                        },
                                      ),
                                      CountryViewItem(
                                        icon: Icons.info_outline,
                                        backColor: Colors.white.withAlpha(100),
                                        title: '주의 사항',
                                        onTap: () {
                                          CustomDialog.showSimpleDialogTxt(
                                              context, '주의 사항', warningContent!.news);
                                        },
                                      ),
                                      // 안전정보
                                      Container(
                                        padding: EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withAlpha(100),
                                          border: Border.all(
                                              color: Colors.grey,
                                              width: 3
                                          ),
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              '안전 정보',
                                              style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text('최근 10개의 안전정보입니다.'),
                                              ],
                                            ),
                                            Column(
                                                children: safeItemList
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ),
                ),
                Visibility(
                  visible: !dataSet,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            '데이터를 불러오고 있습니다...'
                          ),
                        ],
                      ),
                    ),
                  )
                ),
              ],
            )
          )
        ),
      ),
    );
  }
}

/// 공지 아이템
class CountryViewItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final Color backColor;
  final VoidCallback onTap;

  const CountryViewItem({
    Key? key, required this.icon, required this.title, required this.onTap, required this.backColor
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountryViewItem();
}

class _CountryViewItem extends State<CountryViewItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 80,
      child: OutlinedButton(
        onPressed: widget.onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: widget.backColor,
          elevation: 10,
          side: const BorderSide(
              color: Colors.grey,
              width: 3
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SafeItemWidget extends StatelessWidget {
  final SafeItem item;
  final VoidCallBack onTap;

  SafeItemWidget({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
        side: const BorderSide(
          color: Colors.grey,
          width: 1,
        ),
      ),
      elevation: 1.0, //그림자 깊이
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(5),
          width: double.infinity,
          margin: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis, // 또는 TextOverflow.clip
                maxLines: 1, // 개행을 방지하기 위해 1줄로 제한
              ),
              Container(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    item.wrtDt,
                    style: TextStyle(fontSize: 15),
                  )
                ],
              )
            ],
          )
        ),
      ),
    );
  }
}