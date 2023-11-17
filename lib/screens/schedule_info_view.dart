import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:rounded_expansion_tile/rounded_expansion_tile.dart';

import '../providers/schedule_provider.dart';
import '../utils/system_util.dart';

class ScheduleInfoView extends StatefulWidget {
  const ScheduleInfoView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleInfoView> {
  DateTime _selectedDay = DateTime.now();
  late DateTime _focusedDay = DateTime.now();

  /// 선택한 날짜 기기에 저장.
  Future<void> setSelectDay(DateTime dateTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String date = dateTime.year.toString() + "-"
        + dateTime.month.toString() + "-"
        + dateTime.day.toString();

    await prefs.setString(SystemData.selectDate, date);
  }

  @override
  void initState() {
    super.initState();

    // 가장 첫 번째 일차로 지정.
    Logger logger = Logger();
    logger.e(_selectedDay.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(15),
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withAlpha(200),
        child: SingleChildScrollView(
            child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 5),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 5),
                      Text('여행일')
                    ],
                  ),
                  Consumer<ScheduleClass>(
                    // Consumer를 활용해서 provider에 접근하여 데이터를 받아올 수 있다
                      builder: (context, provider, child) {
                        String sdf = '';
                        return Text(
                            provider.travel.getDate() == "" ? '조회 중...' :
                            SystemUtil.changePrintDate(provider.travel.getDate()) + " (" +
                          SystemUtil.getTravelDay(provider.travel.getDate()).toString() + "일)", // count를 화면에 출력
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        );
                      }),
                  // Text(
                  //   '23.06.24 ~ 23.07.01',
                  //   style: TextStyle(fontWeight: FontWeight.bold),
                  // ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: TableCalendar(
                locale: 'ko_KR',
                rangeStartDay: context.watch<ScheduleClass>().getDateTime(0),
                rangeEndDay: context.watch<ScheduleClass>().getDateTime(1),
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                // focusedDay: DateTime.now(),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // BotToast.showText(text: context.read<ScheduleClass>().travel.getDate());
                  if (SystemUtil.isDateInSchedule(context.read<ScheduleClass>().travel.getDate(), selectedDay)) {
                    setSelectDay(selectedDay);

                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay; // update `_focusedDay` here as well
                    });
                  } else {
                    BotToast.showText(text: '범위 내에 일차를 선택하세요.');
                  }
                },
              ),
            ),
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              color: Colors.grey,
              margin: EdgeInsets.only(bottom: 5),
              child: RoundedExpansionTile(
                rotateTrailing: false,
                trailing: const SizedBox(
                  child: Text(
                    '탭 해서 일정 선택',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                title: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(15)),
                    child: const Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.event_note),
                                  SizedBox(width: 5),
                                  Text('일정 상세'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
                children: [
                  Container(
                      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Column(
                        children: [
                          // 구분선
                          const SizedBox(
                              width: 500,
                              child: Divider(color: Color.fromARGB(50, 0, 0, 0), thickness: 1.0)),
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                                border: Border.all(color: Color.fromARGB(100, 0, 0, 0))
                            ),
                            child: SfCalendar(
                              dataSource: _getCalendarDataSource(),
                              view: CalendarView.day,
                              /*appointmentTextStyle: TextStyle(
                          backgroundColor: Colors.yellow,
                          color: Colors.red
                        ),*/
                              // cellBorderColor: Colors.green,
                              backgroundColor: Colors.grey,
                              viewHeaderStyle: const ViewHeaderStyle(
                                backgroundColor: Colors.grey,
                                dateTextStyle: TextStyle(
                                  color: Colors.black,
                                ),
                                dayTextStyle: TextStyle(
                                  color: Colors.black,
                                ),

                              ),
                              showCurrentTimeIndicator: false,
                              minDate: DateTime(2023, 1, 1, 0, 1),
                              maxDate: DateTime(2052, 12, 31, 23, 59),
                              scheduleViewSettings: const ScheduleViewSettings(
                                dayHeaderSettings: DayHeaderSettings(
                                    dayFormat: 'EEEE',
                                    width: 70,
                                    dayTextStyle: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.black,
                                    ),
                                    dateTextStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.red,
                                    )),
                              ),
                              viewHeaderHeight: 0,
                              headerHeight: 0,
                              headerStyle: const CalendarHeaderStyle(
                                  backgroundColor: Color.fromARGB(70, 0, 0, 0),
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(
                                      color: Color.fromARGB(225, 255, 255, 255),
                                      fontWeight: FontWeight.bold)
                              ),
                              todayHighlightColor: Colors.black,
                              todayTextStyle: const TextStyle(
                                  color: Colors.white
                              ),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ),
            // 일정상세
            Visibility(
              visible: false,
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(15)),
                child: SizedBox(
                  width: double.infinity,
                  height: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GoogleMap(
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: CameraPosition(target: LatLng(0, 0)),
                      onMapCreated: (controller) {
                        // if (!_controller.isCompleted) _controller.complete(controller);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        )));
  }
}

/// 테스트 데이터
_AppointmentDataSource _getCalendarDataSource() {
  List<Appointment> appointments = <Appointment>[];
  appointments.add(Appointment(
    startTime: DateTime.now(),
    endTime: DateTime.now().add(Duration(minutes: 10)),
    subject: 'Meeting',
    color: Colors.blue,
    startTimeZone: '',
    endTimeZone: '',
  ));

  return _AppointmentDataSource(appointments);
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source){
    appointments = source;
  }
}
