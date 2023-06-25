import 'package:animations/animations.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:random_text_reveal/random_text_reveal.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../utils/system_util.dart';

/// 그룹생성 씬
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGroupView();
}

class _CreateGroupView extends State<CreateGroupView> {
  // 마지막 씬 여부
  bool isLastScene = false;

  // 그룹정보 입력 여부
  bool isTypeInfo = false;

  // 날짜 입력 컨트롤러
  DateRangePickerController dateController = DateRangePickerController();
  // 그룹명 입력 컨트롤러
  TextEditingController groupNameController = TextEditingController();

  // 다음 버튼 활성화 체크
  void setAllTypeState() {
    isTypeInfo = dateController.selectedRange!.startDate != null &&
        dateController.selectedRange!.endDate != null &&
        groupNameController.value.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 242, 255),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                    child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 300),
                  reverse: true,
                  transitionBuilder: (child, animation, secondaryAnimation) {
                    return SharedAxisTransition(
                        animation: animation,
                        secondaryAnimation: secondaryAnimation,
                        transitionType: SharedAxisTransitionType.horizontal,
                        child: child);
                  },
                  child: isLastScene
                      ? _CreateGroupCode(
                          resetCode: () {
                            setState(() {
                              BotToast.showText(text: '코드를 다시 생성합니다');
                              // isTypeInfo = false;
                            });
                          },
                          finishAction: () {
                            // BotToast.showText(text: '끝이다잉222');
                            setState(() {
                              isTypeInfo = true;
                            });
                          },
                        )
                      : _GroupInfo(
                          dateController: dateController,
                          textController: groupNameController,
                          textCallback: (value) {
                            setState(() {
                              setAllTypeState();
                            });
                          },
                          dateCallback: (value) {
                            setState(() {
                              setAllTypeState();
                            });
                          },
                        ),
                )),
              ],
            ),
            // 다음 씬으로 이동
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(left: 50, right: 50, bottom: 25),
                  child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Visibility(
                        // visible: MediaQuery.of(context).viewInsets.bottom == 0,
                        visible: isLastScene
                            ? false
                            : MediaQuery.of(context).viewInsets.bottom == 0 &&
                                isTypeInfo,
                        child: ElevatedButton(
                            onPressed: () {
                              if (isLastScene) {
                              } else {
                                setState(() {
                                  isLastScene = !isLastScene;
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Color.fromARGB(255, 139, 174, 255),
                                elevation: 5),
                            child: Text(
                              isLastScene ? '생성' : '다음',
                              style:
                                  TextStyle(fontSize: 20, color: Colors.black),
                            )),
                      )),
                ))
          ],
        ));
  }
}

// 그룹 생성 화면
class _GroupInfo extends StatelessWidget {
  final TextEditingController textController;
  final ValueSetter<bool> textCallback;
  final ValueSetter<PickerDateRange> dateCallback;
  final DateRangePickerController dateController;

  const _GroupInfo({
    Key? key,
    required this.textCallback,
    required this.dateCallback,
    required this.textController,
    required this.dateController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 30),
                width: double.infinity,
                height: 50,
                alignment: Alignment.bottomLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    '그룹을 생성합니다.',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                  ),
                )),
            Expanded(
                child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 50),
                child: Column(
                  children: [
                    // 1번
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '여행일 선택',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
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
                      padding: EdgeInsets.all(15),
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
                          dateCallback(dateController.selectedRange!);
                        },
                        selectionMode: DateRangePickerSelectionMode.range,
                        initialSelectedRange: null,
                      ),
                      // child: Text('sdfsd'),
                    ),
                    // 2번
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15, right: 15, top: 30, bottom: 15),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            margin: EdgeInsets.only(right: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '그룹명 입력',
                                style: TextStyle(
                                    fontSize: 22, fontWeight: FontWeight.bold),
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
                      padding: EdgeInsets.all(15),
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
                        controller: textController,
                        onChanged: (value) {
                          textCallback(value.isNotEmpty);
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
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.grey, width: .5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        style: const TextStyle(),
                      ),
                      // child: Text('sdfsd'),
                    ),
                  ],
                ),
              ),
            ))
          ],
        ));
  }
}

// 코드 생성 화면
class _CreateGroupCode extends StatelessWidget {
  String groupCode = SystemUtil.generateGroupCode();
  GlobalKey<RandomTextRevealState> globalKey = GlobalKey();

  final VoidCallback resetCode;
  final VoidCallback finishAction;

  _CreateGroupCode({
    Key? key,
    required this.resetCode,
    required this.finishAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          children: [
            Container(
                margin: const EdgeInsets.only(top: 30),
                width: double.infinity,
                height: 50,
                alignment: Alignment.bottomLeft,
                child: const Padding(
                  padding: EdgeInsets.only(left: 15),
                  child: Text(
                    '이 그룹 코드는...',
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.normal),
                  ),
                )),
            Expanded(
                child: Center(
                    child: Container(
              width: 200,
              height: 130,
              child: ElevatedButton(
                  onPressed: () => resetCode(),
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Color.fromARGB(255, 245, 245, 245),
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
                        onFinished: () => finishAction(),
                        randomString: '.',
                        text: groupCode,
                        duration: const Duration(milliseconds: 1000),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                        curve: Curves.easeIn,
                      ),
                      Container(
                        margin: EdgeInsets.only(bottom: 15),
                        alignment: Alignment.bottomCenter,
                        child: Text('다시 생성하려면 탭 하세요'),
                      )
                    ],
                  )),
            )))
          ],
        ));
  }
}
// 코드 입력
// TextFormField(
//   inputFormatters: [UpperCaseTextFormatter()],
//   controller: editingController,
//   // textCapitalization: TextCapitalization.characters,
//   decoration: const InputDecoration(
//     filled: true,
//     fillColor: Colors.white,
//     hintText: '코드 입력',
//     contentPadding: EdgeInsets.only(
//         left: 14.0, bottom: 8.0, top: 8.0),
//     enabledBorder: OutlineInputBorder(
//       borderSide:
//           BorderSide(color: Colors.black, width: 1),
//       borderRadius: BorderRadius.all(Radius.circular(10)),
//     ),
//     focusedBorder: OutlineInputBorder(
//       borderSide:
//           BorderSide(color: Colors.black, width: 1.0),
//       borderRadius: BorderRadius.all(Radius.circular(10)),
//     ),
//   ),
//   style: const TextStyle(),
// ),