import 'package:flutter/material.dart';
import 'package:go_together/screens/etc_screen.dart';
import 'package:go_together/screens/map_screen.dart';

import 'chatRoom_screen.dart';

import 'package:firebase_database/firebase_database.dart';

/// 메인 씬
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends State<HomeView>
    with SingleTickerProviderStateMixin {
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
    const ChatRoomView(),
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
      bottomNavigationBar: _tabBar(),
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
          Tab(text: '채팅', icon: Icon(Icons.chat)),
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
