import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:random_text_reveal/random_text_reveal.dart';
import '../utils/system_util.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

/// 유저추가 씬
class AddUserView extends StatefulWidget {
  const AddUserView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _AddUserView();
}

class _AddUserView extends State<AddUserView> {
  // 그룹정보 입력 여부
  bool isAllTyped = false;

  bool isDateCheck = false;
  bool isGeneratedCode = false;

  Color checkValueColor = const Color.fromARGB(255, 159, 195, 255);

  // 그룹명 입력 컨트롤러
  TextEditingController groupNameController = TextEditingController();

  String groupCode = '';

  // 그룹코드 위젯
  final GlobalKey<RandomTextRevealState> globalKey = GlobalKey();

  XFile? _imageFile; // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)
  final ImagePicker _picker =
      ImagePicker(); // 카메라/갤러리에서 사진 가져올 때 사용함 (image_picker)

  // 다음으로 넘어가기
  VoidCallback createGroupAction = () {
    BotToast.showText(text: '그룹을 생성합니다...');
  };

  // 다음 버튼 활성화 체크
  void setAllTypeState() {
    setState(() {
      // 변경값 알려주기
      isAllTyped = isDateCheck &&
          groupNameController.value.text.isNotEmpty &&
          groupCode.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();

    groupCode = SystemUtil.generateGroupCode();
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
                              SizedBox(
                                height: 25,
                              ),
                              TextField(
                                controller: TextEditingController(),
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
                    Container(
                      padding: const EdgeInsets.all(50),
                      height: 150,
                      width: double.infinity,
                      child: ElevatedButton(
                          onPressed: isAllTyped ? createGroupAction : null,
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 139, 174, 255),
                              elevation: 5),
                          child: const Text(
                            '그룹 생성',
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
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: <Widget>[
            Text(
              '프로필 등록',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.camera,
                    size: 50,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: Text(
                    '카메라',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(
                    Icons.photo_library,
                    size: 50,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  label: Text(
                    '갤러리',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
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
