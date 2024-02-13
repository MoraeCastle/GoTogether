import 'package:bot_toast/bot_toast.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

/// 채팅방 씬
class EtcView extends StatefulWidget {
  const EtcView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _EtcViewState();

}

class _EtcViewState extends State<EtcView> {
  TextEditingController userNameController = TextEditingController();
  bool profileRadioState = false;

  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Widget bottomSheet() {
    return Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Wrap(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '프로필 사진 선택',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: () {
                  deleteProfile();
                },
                child: Visibility(
                  visible: context.read<DataClass>().currentUser.getProfileURL().isNotEmpty,
                  child: Text(
                    '기본 이미지로 변경',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey
                    ),
                  ),
                )
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 10, top: 10)
                  ),
                  icon: const Icon(
                    Icons.photo_camera,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.camera);
                  },
                  label: const Text(
                    '카메라',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: const EdgeInsets.only(
                        left: 25, right: 25, bottom: 10, top: 10),
                  ),
                  icon: const Icon(
                    Icons.photo_library,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () {
                    takePhoto(ImageSource.gallery);
                  },
                  label: const Text(
                    '갤러리',
                    style: TextStyle(fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 프로필 삭제.
  deleteProfile() async {
    BotToast.showLoading();

    Travel travel = context.read<DataClass>().travel;
    User targetUser = context.read<DataClass>().currentUser;

    bool answer = false;
    answer = await NetworkUtil.deleteImage(travel.getTravelCode(), targetUser.getUserCode());

    BotToast.showText(text: answer ? '기본 프로필로 번경되었습니다.' : '네트워크에 오류가 있습니다.');

    Navigator.pop(context);
    BotToast.closeAllLoading();
  }

  // 사진선택 결과.
  takePhoto(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });

    BotToast.showLoading();

    Travel travel = context.read<DataClass>().travel;
    User targetUser = context.read<DataClass>().currentUser;

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/${travel.getTravelCode()}').get();
    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);
      User target = User();
      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == targetUser.getUserCode()) {
          target = user;
          break;
        }
      }

      if (target.getUserCode().isNotEmpty) {
        String profileURL = "";
        profileURL = await NetworkUtil.uploadImage(travel.getTravelCode(), targetUser.getUserCode(), _imageFile);

        if (profileURL.isNotEmpty) {
          target.setProfileURL(profileURL);

          await ref.child('travel/${travel.getTravelCode()}').set(travel.toJson());

          BotToast.showText(text: '프로필이 변경되었습니다.');
        }
      }
    }

    Navigator.pop(context);
    BotToast.closeAllLoading();
  }

  @override
  Widget build(BuildContext context) {
    Travel travel = context.watch<DataClass>().travel;
    User targetUser = context.watch<DataClass>().currentUser;
    userNameController.text = "";

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
                    // 프로필
                    Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.all(5),
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
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.person,
                                      size: 15,
                                    ),
                                    SizedBox(width: 2),
                                    Text(
                                      '프로필',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '탭해서 정보 수정',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  children: [
                                    Flexible(
                                        flex: 2,
                                        child: InkWell(
                                          onTap: () {
                                            showModalBottomSheet(
                                              context: context,
                                              builder: ((builder) => bottomSheet()),
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(15),
                                                  topRight: Radius.circular(15),
                                                ),
                                              ),
                                            );
                                          },
                                          child: Material(
                                            color: Colors.transparent,
                                            elevation: 5,
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(5.0),
                                              child: SizedBox.fromSize(
                                                size: Size.fromRadius(35),
                                                child: targetUser.getProfileURL().isEmpty ?
                                                AspectRatio(
                                                  aspectRatio: 1 / 1,
                                                  child: Container(
                                                    padding: EdgeInsets.all(10),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      border: Border.all(
                                                          color: Colors.grey,
                                                          width: 3
                                                      ),
                                                      borderRadius: BorderRadius.circular(5),
                                                    ),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Colors.grey,
                                                      size: 35,
                                                    ),
                                                  ),
                                                ) :
                                                CachedNetworkImage(
                                                  imageUrl: targetUser.getProfileURL(),
                                                  imageBuilder: (context, imageProvider) => Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.rectangle,
                                                      image: DecorationImage(
                                                          image: imageProvider, fit: BoxFit.cover),
                                                    ),
                                                  ),
                                                  placeholder: (context, url) => Center(
                                                    child: CircularProgressIndicator(),
                                                  ),
                                                  errorWidget: (context, url, error) => Icon(Icons.error),
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                    ),
                                    Flexible(
                                        flex: 5,
                                        child: InkWell(
                                          onTap: () {
                                            CustomDialog.doubleButton(
                                                context, Icons.edit, '이름 변경', "변경할 이름을 입력하세요.",
                                                Container(
                                                  padding: EdgeInsets.only(top: 10),
                                                  child: TextField(
                                                    controller: userNameController,
                                                    /*onChanged: (value) {
                                                    userItem.setName(value);

                                                    setState(() {
                                                      isNameEdited = value.isNotEmpty;
                                                    });
                                                  },*/
                                                    decoration: InputDecoration(
                                                      filled: true,
                                                      fillColor: Colors.white,
                                                      hintText: targetUser.getName(),
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
                                                ), '저장', () {
                                              // 입력 액션
                                              if (userNameController.text.isNotEmpty && userNameController.text != targetUser.getName()) {
                                                // 유저 이름 저장 처리...
                                                NetworkUtil.changeUserName(
                                                    travel.getTravelCode(), targetUser.getUserCode(), userNameController.text);
                                              }
                                              Navigator.pop(context);
                                            },
                                                '취소', () {
                                              Navigator.pop(context);
                                            }, false);
                                          },
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    targetUser.getName(),
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight: FontWeight.bold
                                                    ),
                                                  ),
                                                  Text(
                                                    '(' + targetUser.getUserCode() + ')',
                                                    style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        )
                                    ),
                                  ],
                                ),
                              )
                          ),
                        ],
                      ),
                    ),
                    GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        children: [
                          EtcMenuItem(
                            icon: Icons.assignment,
                            title: '공지사항',
                            action: () async {
                              var noticeMap = await NetworkUtil.getNoticeList();

                              Navigator.pushNamed(context, NoticeListViewRoute, arguments: noticeMap);
                            },
                          ),
                          EtcMenuItem(
                              icon: Icons.translate,
                              title: '번역기',
                              action: () {
                                // BotToast.showText(text: '미구현 기능입니다...');
                                Navigator.pushNamed(context, TranslatorViewRoute);
                              }),
                          EtcMenuItem(
                              icon: Icons.travel_explore,
                              title: '국가정보',
                              action: () {
                                // 일정이 비어있을경우 미조회.
                                var country = context.read<DataClass>().travel.getCountry();
                                if (country.isEmpty) {
                                  CustomDialog.oneButton(
                                    context, Icons.info_outline_rounded, '안내', '아직 여행지가 추가되지 않았습니다.'
                                      , null, '확인', () {
                                      Navigator.pop(context);
                                    }, false
                                  );
                                } else {
                                  Navigator.pushNamed(context, CountryInfoViewRoute, arguments: country);
                                }
                              }),
                          EtcMenuItem(
                              icon: Icons.settings,
                              title: '설정',
                              action: () {
                                Navigator.pushNamed(context, SettingViewRoute,
                                    arguments: {
                                      'state' : targetUser.getAuthority(),
                                      'userCount' : travel.getUserList().length.toString(),
                                    });
                              }),
                        ]),
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

// 메뉴이동 아이콘
class EtcMenuItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback action;
  final bool? isEnabled;

  const EtcMenuItem(
      {Key? key,
      required this.icon,
      required this.title,
      this.isEnabled,
      required this.action})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _EtcMenuItem();
}

class _EtcMenuItem extends State<EtcMenuItem> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: ElevatedButton(
        onPressed: widget.action,
        style: ElevatedButton.styleFrom(
          elevation: 5,
          surfaceTintColor: Colors.white,
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.icon,
              size: 55,
              color: Colors.black.withAlpha(200),
            ),
            Container(height: 15),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 20, color: Colors.black54),
            )
          ],
        ),
      ),
    );
  }
}
