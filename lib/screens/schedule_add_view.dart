import 'package:bot_toast/bot_toast.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 일정추가 씬
class ScheduleAddView extends StatefulWidget {
  const ScheduleAddView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleAddView();
}

class _ScheduleAddView extends State<ScheduleAddView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black.withAlpha(200),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              BotToast.showText(text: '저장되었습니다.');
            },
            icon: Icon(Icons.save),
          ),
        ],
        shadowColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          '일정 추가',
          style: const TextStyle(color: Colors.white, fontSize: 17),
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
                    color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                child:Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment),
                            SizedBox(width: 5),
                            Text('기본 정보')
                          ],
                        ),
                      ],
                    ),
                    Container(
                      width: 500,
                      child: Divider(color: Color.fromARGB(100, 0, 0, 0), thickness: 1.0)),
                    // 시간 선택기
                    showPicker(
                      isInlinePicker: true,
                      elevation: 1,
                      value: Time.fromTimeOfDay(TimeOfDay.now(), 0),
                      onChange: (p0) {

                      },
                      width: double.infinity,
                      height: 400,
                      showCancelButton: true,
                      hideButtons: true,
                      dialogInsetPadding: EdgeInsets.only(bottom: 10),
                      minuteInterval: TimePickerInterval.FIVE,
                      iosStylePicker: true,
                      is24HrFormat: false,
                    ),
                    const SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true, //<-- SEE HERE
                          fillColor: Color.fromARGB(150, 255, 255, 255),
                          labelText: '일정명',
                          hintText: '내용 입력',
                          labelStyle: TextStyle(
                              color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                child:Column(
                  children: [
                    Row(
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
                          style: TextStyle(fontWeight: FontWeight.normal, fontSize: 11),
                        ),
                      ],
                    ),
                    Container(
                        width: 500,
                        child: Divider(color: Color.fromARGB(100, 0, 0, 0), thickness: 1.0)),
                    SizedBox(
                      width: double.infinity,
                      height: 350,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Stack(
                          children: [
                            GoogleMap(
                              zoomControlsEnabled: false,
                              mapType: MapType.normal,
                              initialCameraPosition: CameraPosition(target: LatLng(0, 0)),
                              onMapCreated: (controller) {
                                // if (!_controller.isCompleted) _controller.complete(controller);
                              },
                            ),
                            // 검색
                            Positioned(
                                right: 20,
                                bottom: 80,
                                child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.search,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Navigator.pushNamed(context, AddScheduleRoute);
                                      },
                                    ),
                                  ),
                                )
                            ),
                            // GPS
                            Positioned(
                                right: 20,
                                bottom: 20,
                                child: SizedBox(
                                  width: 45,
                                  height: 45,
                                  child: CircleAvatar(
                                    radius: 30,
                                    backgroundColor: Colors.white,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.gps_fixed,
                                        color: Colors.black,
                                      ),
                                      onPressed: () {
                                        // Navigator.pushNamed(context, AddScheduleRoute);
                                      },
                                    ),
                                  ),
                                )
                            ),
                          ],
                        )
                      ),
                    ),
                  ]
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
