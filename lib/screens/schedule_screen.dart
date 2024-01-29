import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/providers/schedule_provider.dart';
import 'package:go_together/screens/schedule_add_view.dart';
import 'package:go_together/screens/schedule_edit_view.dart';
import 'package:go_together/screens/schedule_info_view.dart';
import 'package:flutter/material.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
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
  String travelCode = "";
  String currentUserCode = "";

  @override
  void initState() {
    BotToast.showLoading();

    super.initState();

    // 탭 전환 시 토글에도 변경내용 적용하기.
    tabController.addListener(() {
      setState(() {
        toggleIndex = tabController.index;
      });
    });

    listenTravelChange();
  }

  /// 여행 데이터 적용
  setTravelDate(Travel data, User userData) async {
    // BotToast.showText(text: "여행 데이터 로드됨222");
    Provider.of<ScheduleClass>(context, listen: false).travel = data;
    Provider.of<ScheduleClass>(context, listen: false).user = userData;
    Provider.of<ScheduleClass>(context, listen: false).guidCheck = await NetworkUtil.isGuild(data);

    /// 임시!!!
    if (tabController.index == 1) tabController.index = 0;
  }

  /// 여행 데이터 변경 감지
  Future<void> listenTravelChange() async {
    SharedPreferences prefs = await _prefs;
    travelCode = prefs.getString(SystemData.travelCode) ?? "";
    currentUserCode = prefs.getString(SystemData.userCode) ?? "";

    DatabaseReference ref = FirebaseDatabase.instance.ref('travel/$travelCode');

    ref.onValue.listen((DatabaseEvent event) {
      var result = event.snapshot.value;
      if (result != null) {
        Travel travel = Travel.fromJson(result);
        User targetUser = User();

        for (User user in travel.getUserList().values) {
          if (user.getUserCode() == currentUserCode) {
            targetUser = user;
            break;
          }
        }

        if (targetUser.getUserCode().isEmpty) {
          // BotToast.showText(text: "현재 유저를 확인할 수 없습니다.");
          Navigator.pop(context);
        } else {
          setTravelDate(travel, targetUser);
        }
      } else {
        // 'result'가 null인 경우를 처리하세요.
      }
    });
  }

  /// 여행 세부설정 저장
  Future<void> saveDetailSetting() async {
    if (travelCode.isEmpty) {
      BotToast.showText(text: '여행 데이터 오류...');
      return;
    }

    BotToast.showLoading();

    var snapshot = await ref.child('travel/$travelCode').get();
    if (snapshot.exists) {
      var result = snapshot.value;
      if (result != null) {
        var travel = Travel.fromJson(result);

        travel.setTitle(context.read<ScheduleClass>().travel.getTitle());
        travel.setNotice(context.read<ScheduleClass>().travel.getNotice());

        await ref.child('travel/$travelCode').set(travel.toJson()).whenComplete(() {
          BotToast.showText(text: '저장했습니다.');
        }).onError((error, stackTrace) {
          BotToast.showText(text: '서버에 오류가 있습니다.');
        });
      }
      BotToast.closeAllLoading();
    } else {
      BotToast.closeAllLoading();
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

    // 탭 이동 시 기본적으로 일정 씬 내 지도 닫기.
    tabController.addListener(() {
      Provider.of<ScheduleClass>(context, listen: false).detailViewVisible = false;
      // BotToast.showText(text: tabController.index.toString());
    });

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () {
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
                  // print('switched to: $index');
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
              '${'일정관리(' + provider.travel.getTravelCode()})',
              // count를 화면에 출력
              style: const TextStyle(color: Colors.white, fontSize: 17),
            );
          }),
        ),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
            Navigator.pop(context);
          },
          child: Stack(
            children: [
              DefaultTabController(
                length: 2,
                child: TabBarView(
                  controller: tabController,
                  children: const [
                    ScheduleInfoView(),
                    ScheduleEditView(),
                  ],
                ),
              ),
              Visibility(
                visible: context.watch<ScheduleClass>().isGuide,
                child: Positioned(
                    right: 25,
                    bottom: 25,
                    child: SizedBox(
                      width: 65,
                      height: 65,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: IconButton(
                          icon: Icon(
                            tabController.index == 0 ? Icons.add : Icons.save_outlined,
                            color: Colors.black,
                          ),
                          onPressed: () {
                            if (tabController.index == 0) {
                              SystemUtil.resetTargetPosition();

                              Navigator.pushNamed(context, AddScheduleRoute,
                                  arguments: SystemUtil.changePrintDateOnlyDate(
                                      context.read<ScheduleClass>().selectDate));
                            } else {
                              saveDetailSetting();
                            }
                          },
                        ),
                      ),
                    )),
              ),
            ],
          )),
        );
  }
}
