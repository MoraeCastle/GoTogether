import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class ScheduleInfoView extends StatefulWidget {
  const ScheduleInfoView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleInfoView> {
  DateTime _selectedDay = DateTime.now();
  late DateTime _focusedDay = DateTime.now();
  List userList = [
    UserItem(userId: "", userName: "하나", profileUrl: ""),
    UserItem(userId: "", userName: "둘", profileUrl: ""),
    UserItem(userId: "", userName: "셋", profileUrl: ""),
  ];

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
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today),
                      SizedBox(width: 5),
                      Text('여행일')
                    ],
                  ),
                  Text(
                    '23.06.24 ~ 23.07.01',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: TableCalendar(
                locale: 'ko_KR',
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                // focusedDay: DateTime.now(),
                focusedDay: _selectedDay,
                selectedDayPredicate: (day) {
                  return isSameDay(_selectedDay, day);
                },
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay =
                        focusedDay; // update `_focusedDay` here as well
                  });
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 15),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 5),
                            Text('0' + ' 명'),
                          ],
                        ),
                        Text(
                          '꾹 눌러서 삭제',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 인원 리스트
                  GridView.count(
                      childAspectRatio: 3 / 1,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      children: List.generate(
                        userList.length,
                        (index) => userList[index],
                      )),
                ],
              ),
            ),
          ],
        )));
  }
}

// 인원목록 아이템
class UserItem extends StatelessWidget {
  final String userId;
  final String userName;
  final String profileUrl;

  const UserItem({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          //모서리를 둥글게 하기 위해 사용
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 4.0, //그림자 깊이
        child: SizedBox(
          width: double.infinity,
          height: 35,
          child: Container(
              padding:
                  const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(profileUrl),
                  ),
                  Text(userName),
                ],
              )),
        ));
  }
}
