import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/providers/schedule_provider.dart';
import 'package:go_together/screens/schedule_edit_view.dart';
import 'package:go_together/screens/schedule_info_view.dart';
import 'package:flutter/material.dart';
import 'package:go_together/utils/string.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toggle_switch/toggle_switch.dart';

// 일정 씬.
class ScheduleView extends StatelessWidget {
  const ScheduleView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => ScheduleClass(),
        child: const Scaffold(
          body: ScheduleWidget(),
        ));
    // return ProxyProvider<Counter, Translations>(
    //   update: (_, counter, __) => Translations(counter.value),
    // );
  }
}

class ScheduleWidget extends StatefulWidget {
  const ScheduleWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ScheduleWidget();
}

class _ScheduleWidget extends State<ScheduleWidget>
    with SingleTickerProviderStateMixin {
  late int toggleIndex = 0;
  late TabController tabController = TabController(
    length: 2,
    vsync: this,
    initialIndex: 0,

    /// 탭 변경 애니메이션 시간
    animationDuration: const Duration(milliseconds: 500),
  );
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();
  var logger = Logger();
  Travel travelData = Travel();

  @override
  void initState() {
    super.initState();

    logger.d("initState...");

    // 탭 전환 시 토글에도 변경내용 적용하기.
    tabController.addListener(() {
      setState(() {
        toggleIndex = tabController.index;
      });
    });

    setTrevelDate();
  }

  setTrevelDate() async {
    SharedPreferences prefs = await _prefs;
    String travelCode = prefs.getString(SystemData.trvelCode) ?? "";

    ref = FirebaseDatabase.instance.ref();
    var snapshot = await ref.child('travel/$travelCode').get();

    if (snapshot.exists) {
      var result = snapshot.value;
      var travel = Travel.fromJson(result);
      travelData = travel;

      Provider.of<ScheduleClass>(context, listen: false).travel = travelData;

      logger.d("데이터가 저장되었습니다...");
    } else {
      // 여행 데이터 불러오기 오류...
      logger.d("데이터가 저장 오류.");
    }
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    logger.d('빌드...');
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () {
              BotToast.showText(text: "토글 선택....");
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ToggleSwitch(
                customWidths: const [35, 35],
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
          title: Consumer<ScheduleClass>(
              // Consumer를 활용해서 provider에 접근하여 데이터를 받아올 수 있다
              builder: (context, provider, child) {
            return Text(
              '${'일정관리(' + provider.travel.getTravelCode()})', // count를 화면에 출력
              style: const TextStyle(color: Colors.white, fontSize: 17),
            );
          }),
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
