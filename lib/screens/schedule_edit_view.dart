import 'package:flutter/material.dart';
import 'package:schedule_widget/schedule_widget.dart';

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
      padding: EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(200),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.all(15),
                margin: EdgeInsets.only(bottom: 15),
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
                    MothDayView(
                      scrollPhysics: const NeverScrollableScrollPhysics(),
                      locale: 'ko_KR',
                      shrinkWrap: true,
                      taskCardColor: const Color.fromARGB(255, 26, 43, 72),
                      taskTitleColor: Colors.white,
                      mothCardColor: Colors.black,
                      taskSubtitleColor: Colors.blueAccent,
                      tasks: [
                        Task(
                          date: DateTime(2022, 2, 1, 1),
                          title: "Teste 01",
                          subtitle: "teste 01",
                        ),
                        Task(
                          date: DateTime(2022, 1, 1, 2),
                          title: "Teste 02",
                          subtitle: "teste 02",
                        ),
                        Task(
                          date: DateTime(2022, 1, 26, 3),
                          title: "Teste 03",
                          subtitle: "teste 03",
                        ),
                        Task(
                          date: DateTime(2022, 1, 5, 4),
                          title: "Teste 04",
                          subtitle: "teste 04",
                        ),
                        Task(
                          date: DateTime(2022, 1, 2, 5),
                          title: "Teste 05",
                          subtitle: "teste 05",
                        ),
                        Task(
                          date: DateTime(2022, 1, 3, 3),
                          title: "Teste Dia 6",
                          subtitle: "teste dia 6",
                        ),
                        Task(
                          date: DateTime(2022, 1, 2, 5),
                          title: "Teste Dia 07",
                          subtitle: "teste dia 07",
                        ),
                      ],
                    ),
                  ],
                )),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: const Column(
                children: [
                  // 인원 수
                  SizedBox(
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
                  SizedBox(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
