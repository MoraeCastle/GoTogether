import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/models/Chat.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/screens/chat_screen.dart';
import 'package:go_together/screens/etc_screen.dart';
import 'package:go_together/screens/map_screen.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:badges/badges.dart' as badges;
import 'package:firebase_database/firebase_database.dart';

/// 메인 씬
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DataClass(), // DataClass 인스턴스를 생성하여 제공
      child: Scaffold(
        // body: TabBarWidget(),
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
            CustomDialog.doubleButton(
              context, Icons.exit_to_app, '나가기',
                '앱을 종료하시겠습니까?', null, '네', () {
                    SystemNavigator.pop();
              }, '아니오', () {
                    Navigator.pop(context);
              }, true
            );
          },
          child: TabBarWidget()
        ),
      ),
    );
  }
}

class TabBarWidget extends StatefulWidget {
  const TabBarWidget({Key? key}) : super(key: key);

  @override
  State<TabBarWidget> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<TabBarWidget>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late DataClass _countProvider;
  bool isTravel = false;

  @override
  void initState() {
    BotToast.showLoading();

    super.initState();
    setTravelDate();
  }

  /// 오류로 인한 나가기.
  Future<bool> finishDialog() async {
    return (await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          Navigator.pop(context);
        },
        child: AlertDialog(
          title: Container(
            alignment: Alignment.center,
            child: const Text('오류'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 60),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '서버에 문제가 있습니다.\n나중에 다시 시도해주세요.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.info_outline_rounded),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () async {
                  await SystemUtil.resetDeviceSetting();
                  SystemNavigator.pop();
                },
                child: const Text('종료')),
          ],
        ),
      ),
    ));
  }

  /// 여행 데이터 불러오기...
  setTravelDate() async {
    SharedPreferences prefs = await _prefs;
    String travelCode = prefs.getString(SystemData.travelCode) ?? "";
    String userCode = prefs.getString(SystemData.userCode) ?? "";
    
    _countProvider = Provider.of<DataClass>(context, listen: false);

    BotToast.closeAllLoading();

    // 비회원모드 판별
    if (travelCode.isNotEmpty) {
      ref = FirebaseDatabase.instance.ref();
      var snapshot = await ref.child('travel/$travelCode').get();
      if (snapshot.exists) {
        var result = snapshot.value;
        if (result != null) {
          var travel = Travel.fromJson(result);

          _countProvider.travel = travel;

          listenTravelChange(travelCode, userCode);
          listenChatChange(travelCode, userCode);
        } else {
          // 데이터가 null이라면 처리할 로직을 여기에 추가하세요.
          BotToast.showText(text: "여행 데이터 불러오기 오류...");
          finishDialog();
        }
      } else {
        // 여행 데이터 불러오기 오류...
        // BotToast.showText(text: "???");
        finishDialog();
      }
    }

    setState(() {
      isTravel = travelCode.isNotEmpty;
    });
  }

  /// 여행 데이터 변경 감지
  void listenTravelChange(String travelCode, String userCode) {
    DatabaseReference ref =
      FirebaseDatabase.instance.ref('travel/$travelCode');
    ref.onValue.listen((DatabaseEvent event) {

      var result = event.snapshot.value;
      if (result != null) {
        Travel travel = Travel.fromJson(result);
        _countProvider = Provider.of<DataClass>(context, listen: false);
        _countProvider.travel = travel;

        if (travel.getUserList().keys.contains(userCode)) {
          _countProvider.currentUser = travel.getUserList()[userCode]!;
        }

        if (travel.getSchedule().isNotEmpty) {
          _countProvider.sortedDayList = SystemUtil.getSortedDayKeyList(travel.getSchedule().first.getRouteMap().keys);

          // 선택된 일정이 없다면 저장.
          if (_countProvider.targetDayKey.isEmpty) {
            String dayKey = "";
            for (String day in travel.getSchedule().first.getRouteMap().keys) {
              if (dayKey.compareTo(day) < 0) {
                if (travel.getSchedule().first.getRouteMap()[day]!.isNotEmpty) {
                  dayKey = day;
                }
              }
            }

            if (dayKey.isNotEmpty) {
              _countProvider.targetDayKey = dayKey;
              _countProvider.targetRoute = travel.getSchedule().first.getRouteMap()[dayKey]!.first;
            }
          }
        }

        BotToast.showText(text: "여행 데이터 로드됨");
      } else {
        BotToast.showText(text: "서버에 오류가 있습니다.");
      }
    });
  }

  /// 여행 데이터 변경 감지
  void listenChatChange(String travelCode, String userCode) {
    DatabaseReference ref =
    FirebaseDatabase.instance.ref('chat/$travelCode');
    ref.onValue.listen((DatabaseEvent event) {
      var result = event.snapshot.value;
      if (result != null) {
        var chat = Chat.fromJson(result);

        Provider.of<DataClass>(context, listen: false).allUnreadCount =
            NetworkUtil.getAllUnreadCount(chat.getRoomList(), userCode);
      }
    });
  }

  // 탭 정의.
  late TabController tabController = TabController(
    length: 3,
    vsync: this,
    initialIndex: 0,
    // tabController.addListener(() { })
    // tabController.indexIsChanging;
    // tabController.length;
    // tabController.previousIndex;
    // tabController.index = 2;
    // tabController.animateTo(5);

    /// 탭 변경 애니메이션 시간
    animationDuration: const Duration(milliseconds: 200),
  );

  final List<Widget> _widgetOptions = [
    MapView(),
    const ChatView(),
    const EtcView()
    // Placeholder(),
  ];

  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference ref = FirebaseDatabase.instance.ref();

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("TabBarScreen"),
      // ),
      // 하단 탭까지 바디를 늘릴것인지?
      extendBody: true,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: isTravel ? _tabBar() : null,
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        controller: tabController,
        children: _widgetOptions,
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      // color: Colors.white,
      height: 70,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.only(left: 10, right: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.grey,
            offset: Offset(0.0, 3.0), //(x,y)
            blurRadius: 6.0,
          ),
        ],
      ),
      child: TabBar(
        controller: tabController,
        // 탭 항목.
        tabs: [
          Tab(text: '지도', icon: Icon(Icons.map)),
          Tab(
            text: '채팅',
            icon: badges.Badge(
              showBadge: context.watch<DataClass>().allUnreadCount != 0,
              badgeStyle: badges.BadgeStyle(
                badgeColor: Colors.orange,
                borderRadius: BorderRadius.circular(4),
                elevation: 5,
              ),
              position: badges.BadgePosition.topEnd(top: -12, end: -12),
              badgeContent: Text(
                context.watch<DataClass>().allUnreadCount.toString(),
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold
                ),
              ),
              child: Icon(Icons.chat),
            ),
          ),
          Tab(text: '기타', icon: Icon(Icons.account_circle)),
        ],
        // 글씨체 설정
        labelColor: Colors.black,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        unselectedLabelColor: Colors.grey,
        unselectedLabelStyle:
            const TextStyle(fontSize: 8, fontWeight: FontWeight.normal),
        // 탭 클릭 시의 스타일
        overlayColor: MaterialStatePropertyAll(Colors.blue.shade100),
        splashBorderRadius: BorderRadius.circular(30),
        // 인디케이터. 선택 작대기
        indicator: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey, width: 3.0),
          ),
        ),
        indicatorColor: Colors.black,
        indicatorSize: TabBarIndicatorSize.label,
        // indicatorWeight: 3,
        // padding: const EdgeInsets.all(10),
        labelPadding: const EdgeInsets.all(0),
        // 탭 클릭
        onTap: (value) async {
          // await ref.set({
          //   "name": "John",
          //   "age": 18,
          //   "address": {"line1": "100 Mountain View"}
          // });
        },
      ),
    );
  }
}
