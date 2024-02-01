import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Schedule.dart';
import 'package:go_together/utils/string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import '../providers/schedule_provider.dart';
import '../utils/system_util.dart';

class ScheduleInfoView extends StatefulWidget {
  const ScheduleInfoView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleInfoView> {
  // DateTime _selectedDay = DateTime.now();
  DateTime? _selectedDay;
  late DateTime _focusedDay = DateTime.now();
  final GlobalKey<ExpansionTileCardState> detailCard = GlobalKey();
  bool isDetailTarget = false;

  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = {};

  CalendarController calendarController = CalendarController();
  ScrollController scrollController = ScrollController();

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  /// 특정 위치로 카메라 이동
  _targetPosition(LatLng position) async {
    GoogleMapController controller = await getController();
    controller.moveCamera(CameraUpdate.newLatLngZoom(position, 17));

    final Marker marker = Marker(
      markerId: const MarkerId(
          "selectMarker"),
      position: position,
      icon: BitmapDescriptor
          .defaultMarker,
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  /// 선택한 날짜 기기에 저장.
  Future<void> setSelectDay(DateTime dateTime) async {
    Provider.of<ScheduleClass>(context, listen: false).selectDate = dateTime;

    calendarController.displayDate = dateTime;
  }

  @override
  void initState() {
    super.initState();

    BotToast.closeAllLoading();

    // 가장 첫 번째 일차로 지정.
    Logger logger = Logger();
    logger.e(_selectedDay.toString());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void setState(VoidCallback fn) {
    // TODO: implement setState
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(4.0)),
      ),
    );

    return Container(
      padding: EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(200),
      child: SingleChildScrollView(
        controller: scrollController,
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
                      provider.travel.getDate() == ""
                          ? '조회 중...'
                          : SystemUtil.changePrintDate(
                                  provider.travel.getDate()) +
                              " (" +
                              SystemUtil.getTravelDay(provider.travel.getDate())
                                  .toString() +
                              "일)", // count를 화면에 출력
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
                focusedDay: context.watch<ScheduleClass>().selectDate,
                selectedDayPredicate: (day) {
                  return isSameDay(
                      context.watch<ScheduleClass>().selectDate, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  // BotToast.showText(text: context.read<ScheduleClass>().travel.getDate());
                  if (SystemUtil.isDateInSchedule(
                      context.read<ScheduleClass>().travel.getDate(),
                      selectedDay)) {
                    setSelectDay(selectedDay);

                    setState(() {
                      //_selectedDay = selectedDay;
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
                  borderRadius: BorderRadius.circular(15)),
              color: Colors.grey,
              margin: EdgeInsets.only(bottom: 5),
              child:
              ExpansionTileCard(
                onExpansionChanged: (value) {
                  Provider.of<ScheduleClass>(context, listen: false).tileCheck = value;

                  if (value) {
                    calendarController.displayDate = context.read<ScheduleClass>().selectDate;
                  }
                },
                expandedTextColor: Colors.black,
                baseColor: Colors.grey,
                expandedColor: Colors.grey,
                key: detailCard,
                trailing: const SizedBox(
                  child: Text(
                    '탭 해서 일정 선택',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
                // leading: const CircleAvatar(child: Text('A')),
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
                // subtitle: const Text('I expand!'),
                children: <Widget>[
                  Container(
                      padding: const EdgeInsets.only(
                          left: 10, right: 10, bottom: 10),
                      margin: const EdgeInsets.only(bottom: 5),
                      child: Column(
                        children: [
                          // 구분선
                          const SizedBox(
                              width: 500,
                              child: Divider(
                                  color: Color.fromARGB(50, 0, 0, 0),
                                  thickness: 1.0)),
                          /// 스케줄 창
                          Container(
                            height: 400,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: Color.fromARGB(100, 0, 0, 0))),
                            child: SfCalendar(
                              view: CalendarView.schedule,
                              controller: calendarController,
                              onSelectionChanged: (calendarSelectionDetails) {
                                //BotToast.showText(text: calendarSelectionDetails.date.toString());
                              },
                              onTap: (details) {
                                // 지도 출력여부.
                                Provider.of<ScheduleClass>(context, listen: false).detailViewVisible
                                  = details.targetElement == CalendarElement.appointment;

                                // 만약 일정을 선택한다면?
                                if (details.targetElement == CalendarElement.appointment) {
                                  // I want to access the appointment details like eventName, from, to, background, isAllDay etc. if I tap over an event

                                  final Appointment appointmentDetails = details.appointments![0];
                                  // BotToast.showText(text: appointmentDetails.startTime.toString());

                                  // 같은 데이터인 경우 하단 구글맵 위치 최신화.
                                  for (Schedule schedule in context.read<ScheduleClass>().travel.getSchedule()) {
                                    for (List<RouteItem> list in schedule.getRouteMap().values) {
                                      for (RouteItem item in list) {
                                        if (SystemUtil.isDateSame(appointmentDetails.startTime, item.startTime)
                                        && appointmentDetails.subject == item.routeName) {
                                          _targetPosition(SystemUtil.convertStringPosition(item.position));
                                          break;
                                        }
                                      }
                                    }
                                  }

                                  // 스크를 맨 밑으로.
                                  scrollController.animateTo(
                                    scrollController.position.maxScrollExtent, 
                                    duration: Duration(milliseconds: 500), 
                                    curve: Curves.easeInOut,
                                  );
                                }
                                // 그냥 창 클릭 시
                                //BotToast.showText(text: calendarTapDetails.date.toString());
                              },
                              viewNavigationMode: ViewNavigationMode.none,
                              dataSource: _getCalendarDataSource(context
                                  .watch<ScheduleClass>()
                                  .travel
                                  .getSchedule()),
                              // 상세일정 디자인
                              appointmentBuilder: (context, item) {
                                final Appointment appointment =
                                    item.appointments.first;

                                return Card(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    //모서리를 둥글게 하기 위해 사용
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  elevation: 2.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        appointment.subject,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold
                                        ),
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.schedule,
                                            size: 15,
                                          ),
                                          SizedBox(width: 5),
                                          Text(getTime(appointment.startTime, appointment.endTime)),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                              appointmentTextStyle: TextStyle(
                                  // backgroundColor: Colors.yellow,
                                  color: Colors.black
                              ),
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
                              showCurrentTimeIndicator: true,
                              minDate: DateTime(2023, 1, 1, 0, 1),
                              maxDate: DateTime(2052, 12, 31, 23, 59),
                              scheduleViewSettings: const ScheduleViewSettings(
                                // 일정이 없는 날은 삭제
                                hideEmptyScheduleWeek: true,
                                // 아이템 높이 및 텍스트 세팅.
                                appointmentItemHeight: 70,
                                // appointmentTextStyle: TextStyle(),
                                // 날짜 디자인
                                dayHeaderSettings: DayHeaderSettings(
                                  dayFormat: 'EEEE',
                                  width: 70,
                                  dayTextStyle: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.black,
                                  ),
                                  dateTextStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  )
                                ),
                                monthHeaderSettings: MonthHeaderSettings(
                                  height: 0,
                                )
                              ),
                              viewHeaderHeight: 0,
                              headerHeight: 0,
                              headerStyle: const CalendarHeaderStyle(
                                backgroundColor: Color.fromARGB(70, 0, 0, 0),
                                textAlign: TextAlign.center,
                                textStyle: TextStyle(
                                  color: Color.fromARGB(225, 255, 255, 255),
                                  fontWeight: FontWeight.bold,
                                )
                              ),
                              todayHighlightColor: Colors.black,
                              todayTextStyle:const TextStyle(color: Colors.white),
                            ),
                          )
                        ],
                      )),
                ],
              ),
            ),
            // 일정상세
            Visibility(
              visible: context.watch<ScheduleClass>().isDetailViewVisible,
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15)),
                child: SizedBox(
                  width: double.infinity,
                  height: 350,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: GoogleMap(
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition:
                          CameraPosition(target: LatLng(0, 0)),
                      onMapCreated: (controller) {
                        if (!_controller.isCompleted) _controller.complete(controller);
                      },
                      markers: markers,
                    ),
                  ),
                ),
              ),
            ),
          ],
        )
      )
    );
  }

  /// 상세일정 출력용
  String getTime(DateTime startTime, DateTime endTime) {
    return "${
      DateFormat('hh').format(startTime)
      }:${
        DateFormat('mm').format(startTime)
        } ~ ${
          DateFormat('hh').format(endTime)
          }:${
            DateFormat('mm').format(endTime)
            }";
  }

  /// 테스트 데이터
  _AppointmentDataSource _getCalendarDataSource(List<Schedule> data) {
    List<Appointment> appointments = <Appointment>[];
    DateTime date = context.read<ScheduleClass>().selectDate;
    String dateKey = date.toString().split(" ")[0];

    if (dateKey.isEmpty) return _AppointmentDataSource([]);

    for (Schedule item in data) {
      if (item.getRouteMap().containsKey(dateKey)) {
        for (RouteItem item in item.getRouteMap()[dateKey]!) {
          appointments.add(Appointment(
            startTime: SystemUtil.changeDateTimeFromClock(date, item.startTime),
            endTime: SystemUtil.changeDateTimeFromClock(date, item.endTime),
            subject: item.routeName,
            color: Colors.white.withAlpha(150),
            startTimeZone: '',
            endTimeZone: '',
          ));
        }
      }
    }

    return _AppointmentDataSource(appointments);
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
