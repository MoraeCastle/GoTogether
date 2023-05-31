import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

/// 그룹생성 씬
class CreateGroupView extends StatefulWidget {
  const CreateGroupView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CreateGroupView();
}

class _CreateGroupView extends State<CreateGroupView> {
  // 마지막 씬 여부
  bool isLastScene = false;

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
                  child: isLastScene ? _CreateGroupCode() : _GroupInfo(),
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
                            backgroundColor: Color.fromARGB(255, 139, 174, 255),
                            elevation: 5),
                        child: Text(
                          isLastScene ? '생성' : '다음',
                          style: TextStyle(fontSize: 20, color: Colors.black),
                        )),
                  ),
                ))
          ],
        ));
  }
}

// 그룹 생성 화면
class _GroupInfo extends StatelessWidget {
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
                    Container(
                      margin: const EdgeInsets.all(15),
                      width: double.infinity,
                      // height: 150,
                      // color: Colors.blue,
                      // child: SfDateRangePicker(),
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
              child: Text('뽈롱'),
            ))
          ],
        ));
  }
}
