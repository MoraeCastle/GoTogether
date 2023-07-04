import 'package:bot_toast/bot_toast.dart';
import 'package:go_together/screens/schedule_edit_view.dart';
import 'package:go_together/screens/schedule_info_view.dart';
import 'package:flutter/material.dart';
import 'package:toggle_switch/toggle_switch.dart';

// 일정 씬.
class ScheduleView extends StatefulWidget {
  const ScheduleView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleView();
}

class _ScheduleView extends State<ScheduleView>
    with SingleTickerProviderStateMixin {
  late int toggleIndex = 0;
  late TabController tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: 0,

    /// 탭 변경 애니메이션 시간
    animationDuration: const Duration(milliseconds: 500),
  );

  @override
  void initState() {
    super.initState();

    // 탭 전환 시 토글에도 변경내용 적용하기.
    tabController.addListener(() {
      setState(() {
        toggleIndex = tabController.index;
      });
    });
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ToggleSwitch(
                customWidths: [35, 35],
                initialLabelIndex: toggleIndex,
                cornerRadius: 20.0,
                activeFgColor: Colors.white,
                inactiveBgColor: Colors.grey,
                inactiveFgColor: Colors.white,
                totalSwitches: 2,
                icons: const [
                  Icons.info,
                  Icons.edit_calendar_sharp,
                ],
                iconSize: 20.0,
                borderWidth: 1.0,
                borderColor: const [Colors.blueGrey],
                activeBgColors: const [
                  [Colors.blue],
                  [Colors.pink]
                ],
                onToggle: (index) {
                  print('switched to: $index');
                  tabController.animateTo(index!);
                },
              ),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '일정관리',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: DefaultTabController(
          length: 2,
          child: TabBarView(
            controller: tabController,
            children: const [
              ScheduleInfoView(),
              ScheduleEditView(),
            ],
          ),
        ));
  }
}
