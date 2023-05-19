import 'package:flutter/material.dart';

/// 메인 씬
class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: Center(
  //       child: Stack(
  //         children: [],
  //       ),
  //     ),
  //   );
  // }

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<HomeView> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(
      length: 2,
      vsync: this, //vsync에 this 형태로 전달해야 애니메이션이 정상 처리됨
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TabPage',
        ),
      ),
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(),
            ),
            child: TabBar(
              tabs: [
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text(
                    'Tab1',
                  ),
                ),
                Container(
                  height: 80,
                  alignment: Alignment.center,
                  child: Text(
                    'Tab2',
                  ),
                ),
              ],
              indicator: BoxDecoration(
                gradient: LinearGradient(
                  //배경 그라데이션 적용
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blueAccent,
                    Colors.pinkAccent,
                  ],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.black,
              controller: _tabController,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  color: Colors.yellow[200],
                  alignment: Alignment.center,
                  child: Text(
                    'Tab1 View',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
                Container(
                  color: Colors.green[200],
                  alignment: Alignment.center,
                  child: Text(
                    'Tab2 View',
                    style: TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
