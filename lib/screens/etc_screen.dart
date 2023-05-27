import 'package:flutter/material.dart';

/// 채팅방 씬
class EtcView extends StatelessWidget {
  const EtcView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(15),
            child: const Text(
              '기타',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(10),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Container(
                        width: double.infinity,
                        height: 100,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              offset: Offset(0.0, 3.0), //(x,y)
                              blurRadius: 3.0,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text('프로필'),
                            ),
                            Expanded(
                                child: Padding(
                              padding: EdgeInsets.only(left: 10, right: 10),
                              child: Row(
                                children: [
                                  Flexible(
                                      flex: 10,
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 25,
                                            backgroundImage: const AssetImage(
                                                'assets/images/profile_back.png'),
                                            backgroundColor: Colors.grey[200],
                                          ),
                                          Container(width: 10),
                                          Text(
                                            '이름',
                                            style: TextStyle(fontSize: 20),
                                          )
                                        ],
                                      )),
                                  Flexible(
                                      flex: 2,
                                      child: Container(
                                        child: Switch(
                                          value: false,
                                          onChanged: (value) {},
                                        ),
                                      )),
                                ],
                              ),
                            ))
                          ],
                        )),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
