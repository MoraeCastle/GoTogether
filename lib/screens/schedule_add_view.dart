import 'dart:async';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Schedule.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:time_range_picker/time_range_picker.dart';

import '../utils/string.dart';
import '../utils/system_util.dart';
// import 'package:google_maps_place_picker_mb/google_maps_place_picker.dart';

/// 일정추가 씬
class ScheduleAddView extends StatefulWidget {
  const ScheduleAddView({Key? key, required this.arguments}) : super(key: key);

  final String arguments;

  @override
  State<StatefulWidget> createState() => _ScheduleAddView();
}

class _ScheduleAddView extends State<ScheduleAddView> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  LatLng selectPosition = LatLng(0, 0);
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};

  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime =
      TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 3)));

  Logger logger = Logger();

  RouteItem routeItem = RouteItem();

  DatabaseReference ref = FirebaseDatabase.instance.ref("travel");


  @override
  void initState() {
    super.initState();
  }

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  /// 특정 위치로 카메라 이동
  _targetPosition(LatLng position) async {
    GoogleMapController controller = await getController();
    controller.moveCamera(CameraUpdate.newLatLngZoom(position, 17));
  }

  _getTargetPosition() async {
    final SharedPreferences prefs = await _prefs;
    var targetPosition = prefs.getString(SystemData.selectPosition) ?? "";

    selectPosition = SystemUtil.convertStringPosition(targetPosition);

    BotToast.showText(text: selectPosition.toString());

    // 초기화.
    await prefs.remove(SystemData.selectPosition);
  }

  Future<bool> backPress() async {
    return (await showDialog(
            context: context,
            // barrierDismissible: false,
            builder: (context) => AlertDialog(
                  title: Container(
                    alignment: Alignment.center,
                    child: const Text('안내'),
                  ),
                  content: Container(
                    alignment: Alignment.center,
                    constraints: const BoxConstraints(maxHeight: 60),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '입력한 내용이 사라집니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.normal),
                        ),
                      ],
                    ),
                  ),
                  icon: const Icon(Icons.info_outline_rounded),
                  actions: [
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                          //Navigator.pushNamed(context, ScheduleRoute);
                        },
                        child: const Text('네')),
                    OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('아니오')),
                  ],
                ))) ??
        false;
  }

  /// 일정 저장
  Future<void> saveSchedule() async {
    //BotToast.showText(text: routeItem.getRouteName() + ", " + routeItem.getPosition());

    if (routeItem.getRouteName().isEmpty) {
      BotToast.showText(text: '일정을 입력해주세요.');
    } else if (routeItem.getPosition().isEmpty) {
      BotToast.showText(text: '장소를 지정해주세요.');
    } else {
      // 일정 저장.
      final SharedPreferences prefs = await _prefs;
      var travelCode = prefs.getString(SystemData.trvelCode) ?? "";
      var selectDate = widget.arguments;

      // 생성된 그룹 코드를 DB에 조회...
      final snapshot = await ref.child(travelCode).get();
      if (snapshot.exists) {
        var result = snapshot.value;
        if (result != null) {
          var travel = Travel.fromJson(result);

          if (travel.getSchedule().isEmpty) {
            travel.getSchedule().add(Schedule());
          }
          // logger.d(travel.toJson().toString());
          logger.d(selectDate);

          routeItem.setStartTime(_startTime.format(context));
          routeItem.setEndTime(_endTime.format(context));
          travel.getSchedule()[0].addRoute(selectDate, routeItem);

          await ref.child(travelCode).set(travel.toJson()).whenComplete(() {
            BotToast.showText(text: '일정이 추가되었습니다.');

            Navigator.pop(context);
          }).onError((error, stackTrace) {
            BotToast.showText(text: '서버에 오류가 있습니다.');
          });

        } else {
          // Handle the case where 'result' is null.
        }
      } else {
        // BotToast.showText(text: '4');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    /*Logger logger = Logger();
    logger.e("add 신 실행됨....");*/
    return WillPopScope(
      onWillPop: () => backPress(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () => backPress(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () {
                saveSchedule();
              },
              icon: const Icon(Icons.save),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '일정 추가',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(15),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(200),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(15),
                  margin: EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.schedule),
                              SizedBox(width: 5),
                              Text('시간')
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(
                          width: 500,
                          child: Divider(
                              color: Color.fromARGB(100, 0, 0, 0),
                              thickness: 1.0)),
                      SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 20, right: 20, top: 5, bottom: 5),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30,
                                        right: 30,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(230),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Column(
                                      children: [
                                        Text(
                                          '시작',
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withAlpha(150),
                                              fontSize: 13),
                                        ),
                                        Text(
                                          _startTime.format(context),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.arrow_right),
                                  Container(
                                    padding: const EdgeInsets.only(
                                        left: 30,
                                        right: 30,
                                        top: 10,
                                        bottom: 10),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(230),
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Column(
                                      children: [
                                        Text(
                                          '종료',
                                          style: TextStyle(
                                              color:
                                                  Colors.black.withAlpha(150),
                                              fontSize: 13),
                                        ),
                                        Text(
                                          _endTime.format(context),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // 시간 선택기
                            TimeRangePicker(
                              hideButtons: true,
                              hideTimes: true,
                              rotateLabels: false,
                              paintingStyle: PaintingStyle.fill,
                              backgroundColor: Colors.black.withAlpha(50),
                              toText: '종료',
                              fromText: '시작',
                              labels: [
                                "12 AM",
                                "3",
                                "6 AM",
                                "9",
                                "12 PM",
                                "3",
                                "6 PM",
                                "9"
                              ].asMap().entries.map((e) {
                                return ClockLabel.fromIndex(
                                    idx: e.key, length: 8, text: e.value);
                              }).toList(),
                              start: _startTime,
                              end: _endTime,
                              ticks: 10,
                              strokeColor: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.5),
                              ticksColor: Theme.of(context).primaryColor,
                              labelOffset: 20,
                              padding: 60,
                              onStartChange: (start) {
                                setState(() {
                                  _startTime = start;
                                });
                              },
                              onEndChange: (end) {
                                setState(() {
                                  _endTime = end;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextField(
                          onChanged: (value) {
                            routeItem.setRouteName(value);
                          },
                          decoration: const InputDecoration(
                            filled: true,
                            //<-- SEE HERE
                            fillColor: Color.fromARGB(150, 255, 255, 255),
                            labelText: '일정명',
                            hintText: '내용 입력',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                                  BorderSide(width: 1, color: Colors.grey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 5),
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15)),
                    child: Column(children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on),
                              SizedBox(width: 5),
                              Text('위치')
                            ],
                          ),
                          Text(
                            '일정의 위치를 지정하세요',
                            style: TextStyle(
                                fontWeight: FontWeight.normal, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(
                          width: 500,
                          child: Divider(
                              color: Color.fromARGB(100, 0, 0, 0),
                              thickness: 1.0)),
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Stack(
                              children: [
                                GoogleMap(
                                  zoomControlsEnabled: false,
                                  mapType: MapType.normal,
                                  initialCameraPosition:
                                      CameraPosition(target: selectPosition),
                                  onMapCreated: (controller) {
                                    if (!_controller.isCompleted) {
                                      _controller.complete(controller);
                                    }
                                  },
                                  markers: markers,
                                ),
                                // 터치 이벤트
                                GestureDetector(
                                  onTap: () async {
                                    //Navigator.push(context, MaterialPageRoute(builder: (context) => MapSelectView()));
                                    // 만약 위치가 있다면 해당 위치로 저장.(보류)

                                    Navigator.pushNamed(
                                            context, MapSelectViewRoute)
                                        .then(
                                      (value) async {
                                        await _getTargetPosition();

                                        setState(() {
                                          if (selectPosition !=
                                              const LatLng(0, 0)) {
                                            final Marker marker = Marker(
                                              markerId: const MarkerId(
                                                  "selectMarker"),
                                              position: selectPosition,
                                              icon: BitmapDescriptor
                                                  .defaultMarker,
                                            );

                                            _targetPosition(selectPosition);

                                            routeItem.setPosition(
                                                "${selectPosition.latitude},${selectPosition.longitude}");

                                            markers.clear();
                                            markers.add(marker);
                                          } else {
                                            markers.clear();

                                            routeItem.setPosition("");
                                          }
                                        });
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    alignment: Alignment.center,
                                    color: selectPosition == const LatLng(0, 0)
                                        ? Colors.black.withAlpha(150)
                                        : Colors.black.withAlpha(0),
                                    child: selectPosition == const LatLng(0, 0)
                                        ? const Text(
                                            '탭 하여 위치 지정',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          )
                                        : null,
                                  ),
                                )
                              ],
                            )),
                      ),
                    ])),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
