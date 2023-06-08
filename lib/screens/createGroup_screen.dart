import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:random_text_reveal/random_text_reveal.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/Travel.dart';
import '../service/routing_service.dart';
import '../utils/system_util.dart';

/// 그룹생성 씬
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGroupView();
}

class _CreateGroupView extends State<CreateGroupView> {
  // 그룹정보 입력 여부
  bool isAllTyped = false;
  bool isDateCheck = false;
  bool isGeneratedCode = false;
  Color checkValueColor = const Color.fromARGB(255, 159, 195, 255);
  String groupCode = '.......';

  // 그룹코드 위젯
  final GlobalKey<RandomTextRevealState> globalKey = GlobalKey();

  // 날짜 입력 컨트롤러
  DateRangePickerController dateController = DateRangePickerController();
  // 그룹명 입력 컨트롤러
  TextEditingController groupNameController = TextEditingController();

  DatabaseReference ref = FirebaseDatabase.instance.ref("travel/");
  Travel travelItem = Travel();

  // 그룹 추가.
  Future<void> insertGroup(Travel travel) async {
    await ref.child(travel.travelCode).set(travel.toJson());
  }

  // 다음 버튼 활성화 체크
  void setAllTypeState() {
    setState(() {
      // 변경값 알려주기
      isAllTyped = isDateCheck &&
          groupNameController.value.text.isNotEmpty &&
          isGeneratedCode;
    });
  }

  @override
  void initState() {
    super.initState();

    //groupCode = SystemUtil.generateGroupCode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 242, 255),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 30),
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.bottomLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 5),
                      child: Text(
                        '그룹을 생성합니다',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: SingleChildScrollView(
                        // padding: const EdgeInsets.only(bottom: 50),
                        child: Column(
                      children: [
                        // 1번
                        Padding(
                          padding: const EdgeInsets.all(15),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isDateCheck
                                      ? checkValueColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 3.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '1',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '여행일 선택',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '달력에서 여행하는 기간을 선택하세요',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 3.0), //(x,y)
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: SfDateRangePicker(
                            controller: dateController,
                            onSelectionChanged: (date) {
                              travelItem.setDate(SystemUtil.getTravelDate(
                                  dateController.selectedRange!.startDate,
                                  dateController.selectedRange!.endDate));

                              isDateCheck =
                                  (dateController.selectedRange!.startDate !=
                                          null &&
                                      dateController.selectedRange!.endDate !=
                                          null);
                              setAllTypeState();
                            },
                            selectionMode: DateRangePickerSelectionMode.range,
                            initialSelectedRange: null,
                          ),
                          // child: Text('sdfsd'),
                        ),
                        // 2번
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 30, bottom: 15),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: groupNameController.text.isNotEmpty
                                      ? checkValueColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 3.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '2',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '그룹명 입력',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '방 입장시 알아볼 수 있는 그룹명을 입력하세요',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 3.0), //(x,y)
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: TextField(
                            controller: groupNameController,
                            onChanged: (value) {
                              travelItem.setTitle(value);

                              setAllTypeState();
                            },
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: '그룹명 입력...',
                              contentPadding: EdgeInsets.only(
                                  left: 14.0, bottom: 8.0, top: 8.0),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: .5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.grey, width: .5),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                              ),
                            ),
                            style: const TextStyle(),
                          ),
                          // child: Text('sdfsd'),
                        ),
                        // 3번
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 30, bottom: 15),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 10),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isGeneratedCode
                                      ? checkValueColor
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 3.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '3',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '그룹 코드 생성',
                                    style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    '팀원들을 초대할 수 있는 코드를 생성하세요',
                                    style: TextStyle(
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.all(15),
                          padding: const EdgeInsets.all(15),
                          height: 130,
                          // color: Colors.blue,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                offset: Offset(0.0, 3.0), //(x,y)
                                blurRadius: 3.0,
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                              onPressed: () {
                                isGeneratedCode = true;

                                groupCode = SystemUtil.generateGroupCode();

                                travelItem.setTravelCode(groupCode);

                                setState(() {
                                  globalKey.currentState?.play();
                                });

                                setAllTypeState();
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.grey,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  RandomTextReveal(
                                      key: globalKey,
                                      // onFinished: () => finishAction(),
                                      randomString: '.',
                                      text: groupCode,
                                      duration: const Duration(seconds: 1),
                                      style: const TextStyle(
                                        fontSize: 36,
                                        color: Colors.black87,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      initialText: '.......',
                                      shouldPlayOnStart: false,
                                      curve: Curves.easeIn),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 5),
                                    alignment: Alignment.bottomCenter,
                                    child: const Text('탭 해서 그룹코드 생성'),
                                  )
                                ],
                              )),
                        ),
                        Container(
                          padding: const EdgeInsets.all(50),
                          height: 150,
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: isAllTyped
                                  ? () {
                                      BotToast.showText(text: '그룹을 생성합니다...');
                                      Navigator.pushNamed(
                                          context, AddUserRoute);

                                      insertGroup(travelItem);
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 139, 174, 255),
                                  elevation: 5),
                              child: const Text(
                                '그룹 생성',
                                style: TextStyle(
                                    fontSize: 20, color: Colors.black),
                              )),
                        ),
                      ],
                    )),
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
