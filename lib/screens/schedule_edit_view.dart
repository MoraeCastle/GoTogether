import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class ScheduleEditView extends StatefulWidget {
  const ScheduleEditView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleEditView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(200),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    // 인원 수
                    const SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.event_note),
                              SizedBox(width: 5),
                              Text('일정 현황'),
                            ],
                          ),
                          Text(
                            '탭 해서 일정 선택',
                            style: TextStyle(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    // 구분선
                    const SizedBox(
                        width: 500,
                        child: Divider(color: Colors.black, thickness: 1.0)),
                    SizedBox(
                      height: 550,
                        child: SfCalendar(
                        dataSource: _getCalendarDataSource(),
                        view: CalendarView.timelineMonth,
                        // timeSlotViewSettings: const TimeSlotViewSettings(
                        //   allDayPanelColor: Colors.yellow
                        // ),
                        // resourceViewSettings: ResourceViewSettings(
                        // ),
                        backgroundColor: Colors.white,
                        // blackoutDatesTextStyle: TextStyle(
                        //   color: Colors.black
                        // ),
                            viewHeaderStyle: const ViewHeaderStyle(
                                backgroundColor: Colors.blue,
                              dateTextStyle: TextStyle(
                                color: Colors.black,
                              ),
                              dayTextStyle: TextStyle(
                                color: Colors.black,
                              ),

                            ),
                          minDate: DateTime(2023, 1, 1, 0, 1),
                          maxDate: DateTime(2052, 12, 31, 23, 59),
                        scheduleViewSettings: const ScheduleViewSettings(
                          // appointmentTextStyle: TextStyle(
                          //   color: Colors.black
                          // ),
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
                            monthHeaderSettings: MonthHeaderSettings(
                                monthFormat: 'yy년 MMMM',
                                height: 70,
                                textAlign: TextAlign.left,
                                backgroundColor: Color.fromARGB(70, 0, 0, 0),
                                monthTextStyle: TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400)),
                            weekHeaderSettings: WeekHeaderSettings(
                                startDateFormat: 'dd MMM ',
                                endDateFormat: 'dd MMM, yy',
                                height: 50,
                                textAlign: TextAlign.left,
                                backgroundColor: Color.fromARGB(0, 0, 0, 0),
                                weekTextStyle: TextStyle(
                                  color: Color.fromARGB(100, 0, 0, 0),
                                  fontWeight: FontWeight.w400,
                                  fontSize: 15,
                                ))),
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
                    // MothDayView(
                    //   scrollPhysics: const NeverScrollableScrollPhysics(),
                    //   locale: 'ko_KR',
                    //   shrinkWrap: true,
                    //   taskCardColor: const Color.fromARGB(255, 26, 43, 72),
                    //   taskTitleColor: Colors.white,
                    //   mothCardColor: Colors.black,
                    //   taskSubtitleColor: Colors.blueAccent,
                    //   tasks: [
                    //     Task(
                    //       date: DateTime(2022, 2, 1, 1),
                    //       title: "Teste 01",
                    //       subtitle: "teste 01",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 1, 2, 30),
                    //       title: "Teste 02",
                    //       subtitle: "teste 02",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 26, 3),
                    //       title: "Teste 03",
                    //       subtitle: "teste 03",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 5, 4),
                    //       title: "Teste 04",
                    //       subtitle: "teste 04",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 2, 5),
                    //       title: "Teste 05",
                    //       subtitle: "teste 05",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 3, 3),
                    //       title: "Teste Dia 6",
                    //       subtitle: "teste dia 6",
                    //     ),
                    //     Task(
                    //       date: DateTime(2022, 1, 2, 5),
                    //       title: "Teste Dia 07",
                    //       subtitle: "teste dia 07",
                    //     ),
                    //   ],
                    // ),
                  ],
                )),
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  const SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.edit_calendar),
                            SizedBox(width: 5),
                            Text('일정 수정'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  const SizedBox(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  Wrap(
                    children: [Container()],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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