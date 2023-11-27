import 'package:flutter/material.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/providers/schedule_provider.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScheduleEditView extends StatefulWidget {
  const ScheduleEditView({super.key});

  @override
  State<StatefulWidget> createState() => _ScheduleInfoView();
}

class _ScheduleInfoView extends State<ScheduleEditView> {
  List userList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha(200),
      child: SingleChildScrollView(
        child: Column(
          children: [
            /// 타이틀
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.home_filled),
                            SizedBox(width: 5),
                            Text('여행명'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 인원 리스트
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child:
                      TextField(
                        onChanged: (value) {
                          Provider.of<ScheduleClass>(context, listen: false).travel.setTitle(value);
                        },
                        enabled: false,
                        decoration: InputDecoration(
                          filled: true,
                          //<-- SEE HERE
                          fillColor: Color.fromARGB(150, 255, 255, 255),
                          labelText: context.watch<ScheduleClass>().travel.getTitle(),
                          hintText: '내용 입력',
                          labelStyle: TextStyle(color: Colors.black),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                            BorderSide(width: 1, color: Colors.grey),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    /*Text(
                        context.watch<ScheduleClass>().travel.getUserList().length.toString()
                            + ' 명'),*/
                  ),
                ],
              ),
            ),
            /// 인원리스트
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person),
                            SizedBox(width: 5),
                            Text('인원 리스트'),
                          ],
                        ),
                        Text(
                          context.watch<ScheduleClass>().travel.getUserList().length.toString()
                              + ' 명',
                          style: TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 인원 리스트
                  GridView.count(
                      childAspectRatio: 3 / 1,
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 5,
                      crossAxisSpacing: 5,
                      children: getUserList(context.watch<ScheduleClass>().travel.getUserList()),
                  ),
                ],
              ),
            ),
            /// 그룹 공지사항
            Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.only(top: 15, bottom: 0),
              decoration: BoxDecoration(
                  color: Colors.grey, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  // 인원 수
                  Container(
                    width: double.infinity,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assignment),
                            SizedBox(width: 5),
                            Text('공지사항'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // 구분선
                  Container(
                      width: 500,
                      child: Divider(color: Colors.black, thickness: 1.0)),
                  // 공지사항
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.grey
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 350,
                      child: Expanded(
                        child:  TextField(
                          maxLines: null,
                          enabled: false,
                          onChanged: (value) {
                            Provider.of<ScheduleClass>(context, listen: false).travel.setNotice(value);
                          },
                          textAlignVertical: TextAlignVertical.top,
                          expands: true,
                          decoration: InputDecoration(
                            filled: true,
                            //<-- SEE HERE
                            fillColor: Color.fromARGB(150, 255, 255, 255),
                            labelText: '',
                            hintText: '내용 입력',
                            labelStyle: TextStyle(color: Colors.black),
                            focusedBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                              BorderSide(width: 1, color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
                              borderSide:
                              BorderSide(width: 1, color: Colors.grey),
                            ),
                            border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.all(Radius.circular(10.0)),
                            ),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      )
                    ),
                    /*Text(
                        context.watch<ScheduleClass>().travel.getUserList().length.toString()
                            + ' 명'),*/
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> getUserList(Map<String, User> dataList) {
    userList.clear();

    for (User user in dataList.values) {
      userList.add(UserItem(userId: user.getUserCode(), userName: user.getName(), profileUrl: ""));
    }

    return List.generate(
      userList.length,
          (index) => userList[index],
    );
  }
}

// 인원목록 아이템
class UserItem extends StatelessWidget {
  final String userId;
  final String userName;
  final String profileUrl;

  const UserItem({
    super.key,
    required this.userId,
    required this.userName,
    required this.profileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          //모서리를 둥글게 하기 위해 사용
          borderRadius: BorderRadius.circular(5.0),
        ),
        elevation: 4.0, //그림자 깊이
        child: SizedBox(
          width: double.infinity,
          height: 35,
          child: Container(
              padding:
              const EdgeInsets.only(top: 5, bottom: 5, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CachedNetworkImage(
                    imageUrl: profileUrl,
                    imageBuilder: (context, imageProvider) => Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => Center(
                      child: Icon(Icons.account_circle),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Text(userName),
                ],
              )),
        ));
  }
}