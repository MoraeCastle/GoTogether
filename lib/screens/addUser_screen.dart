import 'package:bot_toast/bot_toast.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/User.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// 유저추가 씬
class AddUserView extends StatefulWidget {
  const AddUserView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddUserView();
}

class _AddUserView extends State<AddUserView> {
  Color checkValueColor = const Color.fromARGB(255, 159, 195, 255);

  // 그룹명 입력 컨트롤러
  TextEditingController userNameController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String userName = '';
  bool isNameEdited = false;
  bool travelState = false;
  String travelCode = "";

  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker =
      ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)

  User userItem = User();

  // 저장된 여행코드로 유저 추가하기.
  insertUserData() async {
    final SharedPreferences prefs = await _prefs;
    travelCode = prefs.getString(SystemData.trvelCode) ?? "";
    travelState = prefs.getBool(SystemData.travelState) ?? false;

    userItem.setAuthority(travelState
        ? describeEnum(UserType.guide)
        : describeEnum(UserType.common));

    userItem.setUserCode(SystemUtil.generateUserCode());

    // 고유코드 넣기.
    var deviceCode = await SystemUtil.getDeviceCode() ?? "";
    userItem.setDeviceCode(deviceCode);

    if (travelCode.isEmpty) {
      // 여행 코드를 못 불러옴.
      BotToast.showText(text: "여행 코드 불러오기 실패...");
      Navigator.pop(context);
    } else {
      final ref = FirebaseDatabase.instance.ref();
      final snapshot = await ref.child('travel/$travelCode').get();

      // ref.onValue.listen((event) {
      //   Travel travelData = Travel.fromJson(snapshot.value);
      var result = snapshot.value;

      BotToast.showText(text: result.toString());

      if (result != null) {
        var travel = Travel.fromJson(result);

        // 유저 코드 중복 검사
        bool codeCheck = true;
        int exitCount = 0;

        while (codeCheck) {
          userItem.setUserCode(SystemUtil.generateUserCode());
          // 일치하는 코드가 없으면 탈출.
          codeCheck = travel.getUserList().containsKey(userItem.getUserCode());

          ++exitCount;
          if (exitCount > 50) {
            BotToast.showText(text: '서버에 오류가 있습니다. 잠시 후 다시 시도해 주세요.');
            return;
          }
        }

        travel.addUser(userItem);

        await ref.child('travel/$travelCode').set(travel.toJson());
        await SystemUtil.saveUser(userItem);

        // 이제 씬 이동.
        if (userItem.getAuthority() == describeEnum(UserType.guide)) {
          // 공지방 생성
          NetworkUtil.createNoticeChatRoom(travel.getTravelCode(), userItem);

          Navigator.pop(context);
          Navigator.pushNamed(context, HomeViewRoute);
        } else {
          // 방장이 허용해주기 전까지 대기.
          Navigator.pop(context);
          Navigator.popUntil(context, ModalRoute.withName(LoginViewRoute));
          Navigator.pushNamed(context, LoginViewRoute);
        }
      } else {
        //
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 234, 242, 255),
        body: Stack(
          children: [
            Column(
              children: [
                Container(
                    margin: const EdgeInsets.only(top: 30),
                    width: double.infinity,
                    height: 50,
                    alignment: Alignment.bottomLeft,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 15, bottom: 5),
                      child: Text(
                        '당신은 누구인가요?',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    )),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                          margin: const EdgeInsets.all(10),
                          padding: const EdgeInsets.all(50),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(10),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            children: [
                              imageProfile(),
                              const SizedBox(
                                height: 25,
                              ),
                              TextField(
                                controller: userNameController,
                                onChanged: (value) {
                                  userItem.setName(value);

                                  setState(() {
                                    isNameEdited = value.isNotEmpty;
                                  });
                                },
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Colors.white,
                                  hintText: '이름 입력',
                                  contentPadding: EdgeInsets.only(
                                      left: 14.0, bottom: 8.0, top: 8.0),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.black, width: 1.0),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                ),
                                style: const TextStyle(),
                              ),
                            ],
                          )),
                    ),
                    // 유저 추가 이벤트
                    Container(
                      padding: const EdgeInsets.all(50),
                      height: 150,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: isNameEdited
                              ? () {
                                  insertUserData();
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 139, 174, 255),
                              elevation: 5),
                          child: const Text(
                            '추가하기',
                            style: TextStyle(fontSize: 20, color: Colors.black),
                          )),
                    ),
                  ],
                ))
              ],
            ),
          ],
        ));
  }

  Widget imageProfile() {
    return Center(
      child: Stack(
        children: <Widget>[
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey,
            backgroundImage: _imageFile == null
                ? const AssetImage('assets/images/profile_back.png')
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ).image,
          ),
          Positioned(
              bottom: 10,
              right: 10,
              child: InkWell(
                onTap: () {
                  showModalBottomSheet(
                      context: context, builder: ((builder) => bottomSheet()));
                },
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.black,
                  size: 30,
                ),
              ))
        ],
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
        height: 100,
        width: MediaQuery.of(context).size.width,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Wrap(
          children: <Widget>[
            const Text(
              '프로필 사진 선택',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 25, right: 25),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 159, 195, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 10, top: 10)),
                    icon: const Icon(
                      Icons.camera,
                      size: 35,
                    ),
                    onPressed: () {
                      takePhoto(ImageSource.camera);
                    },
                    label: const Text(
                      '카메라',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 159, 195, 255),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        padding: const EdgeInsets.only(
                            left: 25, right: 25, bottom: 10, top: 10)),
                    icon: const Icon(
                      Icons.photo_library,
                      size: 35,
                    ),
                    onPressed: () {
                      takePhoto(ImageSource.gallery);
                    },
                    label: const Text(
                      '갤러리',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            )
          ],
        ));
  }

  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }
}
