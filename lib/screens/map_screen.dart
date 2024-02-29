import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:badges/badges.dart' as badges;
import 'package:custom_marker/marker_icon.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/Travel.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/models/data.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:go_together/utils/string.dart';
import 'package:go_together/utils/system_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:map_autocomplete_field/map_autocomplete_field.dart';

/// 메인 씬
class MapView extends StatefulWidget {
  const MapView({
    Key? key,
    //required this.roomData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  var logger = Logger();

  // 지도 관련
  final Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // 현재 위치 좌표
  late LatLng currentLatLng;
  CameraPosition currentPosition =
      const CameraPosition(target: LatLng(37.5518911,126.9917937), zoom: 10);

  TextEditingController textEditingController = TextEditingController();

  FocusNode textFocus = FocusNode();

  RouteItem? recentRoute;

  // 현재 일정 마커
  Set<Marker> currentMarkers = {};

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  int testCount = 0;

  /// 드로워에 새 인원이 있는지.
  bool drawerWaitPersonState = false;

  /// PlaceId의 위치로 이동하기
  findAddressForPlace(String placeId) async {
    final geocoding = GoogleMapsGeocoding(apiKey: SystemUtil.getWebKey);
    final response =
        await geocoding.searchByPlaceId(placeId);

    if (response.isOkay) {
      final result = response.results.first.geometry;

      await moveCamera(LatLng(result.location.lat, result.location.lng));
    } else {
      // BotToast.showText(text: response.errorMessage.toString());
      BotToast.showText(text: "위치 조회 실패");
    }
  }

  /// 오류로 인한 나가기.
  Future<bool> settingDialog(String message, VoidCallback action) async {
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
            child: const Text('안내'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  message,
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
                onPressed: action,
                child: const Text('확인')),
          ],
        ),
      ),
    ));
  }

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();

    // 주기적 마커 업데이트.
    Timer.periodic(Duration(seconds: 3), (Timer timer) {
      updateMarker();
    });
  }

  /// 마커 업데이트.
  updateMarker() async {
    if (mounted) {
      await getMarkerListToDay(context.read<DataClass>().targetRoute);
      await refreshUserMarker(context.read<DataClass>().travel.getUserList().values.toList());

      setState(() {});
    }
  }

  /// 루트에 맞는 마커를 맵에 출력합니다.
  Future<void> getMarkerListToDay(RouteItem target) async {
    currentMarkers.removeWhere((marker) => marker.markerId.value.contains('schedule'));

    var dataProvider = context.read<DataClass>();
    var schedule = dataProvider.travel.getSchedule();
    var dayKey = dataProvider.targetDayKey;

    if (schedule.isEmpty) return;

    List<RouteItem> routeList = schedule.first.getRouteMap()[dayKey] ?? [];

    // 해당 일자로 채워넣기.
    for (RouteItem route in routeList) {
      currentMarkers.add(
          Marker(
            markerId: MarkerId('schedule: ' + route.getPosition()),
            onTap: () {
              Provider.of<DataClass>(context, listen: false).targetRoute = route;
            },
            // markerId: MarkerId(routeItem.getRouteName()),
            position: SystemUtil.convertStringPosition(route.getPosition()),
            infoWindow: InfoWindow(
              title: route.getRouteName(),
              snippet: "${route.getStartTime()} ~ ${route.getEndTime()}",
              onTap: () {},
            ),
            icon: await MarkerIcon.circleCanvasWithText(
              size: Size.fromRadius(50),
              text: (routeList.indexOf(route) + 1).toString(),
              fontSize: 40,
              fontWeight: FontWeight.bold,
              fontColor: Colors.white,
              circleColor: Colors.green
            ),
          )
      );
    }

    /*if (recentRoute != target) {
      recentRoute = target;
      moveCamera(SystemUtil.convertStringPosition(target.getPosition()));
    }*/
  }

  /// 유저마커 최신화.
  refreshUserMarker(List<User> userList) async {
    /// 초기화.
    currentMarkers.removeWhere((marker) => marker.markerId.value.contains('user'));

    for (User user in userList) {
      if (user.getPosition().isEmpty) continue;

      currentMarkers.add(
          Marker(
            markerId: MarkerId('user: ' + user.getUserCode()),
            position: SystemUtil.convertStringPosition(user.getPosition()),
            icon: await MarkerIcon.downloadResizePictureCircle(
                user.getProfileURL().isEmpty ? Data.defaultImage : user.getProfileURL(),
                size: 150,
                addBorder: true,
                borderColor: user.getAuthority() == describeEnum(UserType.guide) ? Colors.yellow : Colors.black,
                borderSize: 15
            ),
            infoWindow: InfoWindow(
              title: user.getName(),
            ),
          )
      );
    }
  }

  moveCamera(LatLng position) async {
    currentLatLng = LatLng(position.latitude, position.longitude);
    GoogleMapController controller = await getController();

    currentPosition = CameraPosition(target: currentLatLng, zoom: 17);

    // controller.moveCamera(CameraUpdate.newLatLngZoom(currentLatLng, 17));
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: currentLatLng,
      zoom: 17
    )));
  }

  _getCurrentLocation() async {
    Position? position;

    try {
      position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        await moveCamera(LatLng(position.latitude, position.longitude));
      }

      // Test if location services are enabled.
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        settingDialog('GPS가 꺼져있습니다. 활성화 해주세요.', () async {
          serviceEnabled = await Geolocator.openLocationSettings();
          Navigator.pop(context);
        },);
        return;
      }

      /// 퍼미션 묻기
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          settingDialog('위치 권한이 있어야 정상적인 서비스 이용이 가능합니다.', () {
            Navigator.pop(context);
            _getCurrentLocation();
          },);
          return;
        }
      }

      // 여기서부터는 설정창으로 이동해야 함.
      if (permission == LocationPermission.deniedForever) {
        settingDialog('위치를 계속 거부해서 앱 설정에서 권한을 허용해야 합니다.', () async {
          SystemNavigator.pop();

          AppSettings.openAppSettings();
        },);
        return;
      }

      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 15));

      // 위치 업데이트.
      String positionStr = "${position.latitude},${position.longitude}";
      if (context.read<DataClass>().currentUser.getPosition() != positionStr) {
        NetworkUtil.updatePosition(
          context.read<DataClass>().travel.getTravelCode(),
          context.read<DataClass>().currentUser.getUserCode(),
          positionStr,
        );
      }

      await moveCamera(LatLng(position.latitude, position.longitude));
      BotToast.showText(text: '위치를 최신화 했습니다.');
    } catch (e) {
      logger.e(e.toString());
    }

    return true;
  }

  /// 일차 이동
  Future<void> moveDay(int isBack) async {
    var dataProvider = context.read<DataClass>();
    var schedule = dataProvider.travel.getSchedule();
    var dayKey = dataProvider.targetDayKey;
    var dayList = dataProvider.sortedDayList;

    if (schedule.isEmpty || dayKey.isEmpty) return;

    int dayIndex = dayList.indexOf(dayKey);

    /// 주의 : dayList는 모든 일차가 아닌 <데이터가 있는 일차>만 있다.
    if (dayIndex == 0) {
      if (isBack == 0) BotToast.showText(text: "처음 일차입니다.");
      else {
        if (dayList.length <= 1) {
          BotToast.showText(text: "가져올 일정이 없습니다.");
        } else {
          var day = dayList[++dayIndex];
          var newRoute = schedule.first.getRouteMap()[day]!.first;
          Provider.of<DataClass>(context, listen: false).targetRoute = newRoute;
          Provider.of<DataClass>(context, listen: false).targetDayKey = day;

          moveCamera(SystemUtil.convertStringPosition(newRoute.getPosition()));
        }
      }
    } else if (dayIndex == dayList.length - 1){
      if (isBack != 0) BotToast.showText(text: "마지막 일차입니다.");
      else {
        var day = dayList[--dayIndex];
        var newRoute = schedule.first.getRouteMap()[day]!.last;
        Provider.of<DataClass>(context, listen: false).targetRoute = newRoute;
        Provider.of<DataClass>(context, listen: false).targetDayKey = day;

        moveCamera(SystemUtil.convertStringPosition(newRoute.getPosition()));
      }
    } else {
      // 중간에 낀 일차일 경우.
      if (isBack == 0) {
        BotToast.showText(text: "처음 일차입니다.");
      } else {
        RouteItem? item;
        String day = "";
        if (isBack == 0) {
          day = dayList[--dayIndex];
          item = schedule.first.getRouteMap()[day]!.last;
        } else {
          day = dayList[++dayIndex];
          item = schedule.first.getRouteMap()[day]!.first;
        }

        if (day.isNotEmpty) {
          Provider.of<DataClass>(context, listen: false).targetRoute = item;
          Provider.of<DataClass>(context, listen: false).targetDayKey = day;

          moveCamera(SystemUtil.convertStringPosition(item.getPosition()));
        }
      }
    }

    await getMarkerListToDay(context.read<DataClass>().targetRoute);
    setState(() {});
  }

  /// 일정 이동
  void moveRoute(int isBack) {
    var dataProvider = context.read<DataClass>();
    var schedule = dataProvider.travel.getSchedule();
    var dayKey = dataProvider.targetDayKey;
    var targetRoute = dataProvider.targetRoute;

    if (schedule.isEmpty || dayKey.isEmpty) return;

    int routeIndex = schedule.first.getRouteMap()[dayKey]!.indexOf(targetRoute);

    if (isBack == 0 && routeIndex == 0) {
      // BotToast.showText(text: '처음 일정입니다.');
      moveDay(0);
    } else if (isBack != 0 && routeIndex == schedule.first.getRouteMap()[dayKey]!.length - 1) {
      // BotToast.showText(text: '마지막 일정입니다.');
      moveDay(1);
    } else {
      routeIndex = isBack == 0 ? --routeIndex : ++routeIndex;
      var newRoute = schedule.first.getRouteMap()[dayKey]!.elementAt(routeIndex);

      Provider.of<DataClass>(context, listen: false).targetRoute = newRoute;

      moveCamera(SystemUtil.convertStringPosition(newRoute.getPosition()));
    }
  }

  /// 현재 일정순서를 반환합니다.
  String getRouteState(RouteItem target) {
    var dataProvider = context.read<DataClass>();
    var schedule = dataProvider.travel.getSchedule();
    var dayKey = dataProvider.targetDayKey;

    if (schedule.isEmpty || dayKey.isEmpty) return "";

    List<RouteItem> routeList = schedule.first.getRouteMap()[dayKey] ?? [];

    int count = 0;
    for (RouteItem routeItem in routeList) {
      ++count;
      if (routeItem.getPosition() == target.getPosition()) {
        return "$count / ${routeList.length}";
      }
    }

    return "";
  }

  void openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  /// 드로워 전용 유저리스트
  /// 반복 호출 조심.
  List<Widget> drawerUserList(List<User> values) {
    List<Widget> userList = [];

    // 정식 유저만 삽입
    for (User user in values) {
      if (user.getAuthority() == describeEnum(UserType.common)) continue;

      String position = '';
      if (context.read<DataClass>().currentUser.getUserCode() == user.getUserCode()) {
        position = "ME";
      }
      if (user.getAuthority() == describeEnum(UserType.guide)) {
        if (position.isNotEmpty) {
          position = "가이드 / " + position;
        } else {
          position = "가이드";
        }
      }

      Widget userItem = InkWell(
          onTap: () {
            _scaffoldKey.currentState?.closeDrawer();

            if (user.getPosition().isNotEmpty) {
              moveCamera(SystemUtil.convertStringPosition(user.getPosition()));
            } else {
              BotToast.showText(text: '위치가 업데이트 되지않은 유저입니다.');
            }
          },
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                height: 80,
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: user.getAuthority() == describeEnum(UserType.guide) ? Color.fromARGB(255, 243, 243, 95) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 3.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Image.network(user.getProfileURL().isEmpty ? Data.defaultImage : user.getProfileURL()),
                    Material(
                      color: Colors.transparent,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: AspectRatio(
                        aspectRatio: 1 / 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(
                            user.getProfileURL().isEmpty ? Data.defaultImage : user.getProfileURL(),
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              } else {
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              }
                            },
                            errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                        ),
                      ),
                    ),
                    Text(
                      user.getName(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 5,
                right: 10,
                child: Text(
                  position,
                  style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.normal,
                      fontSize: 12
                  ),
                ),
              ),
            ],
          )
      );

      if (user.getAuthority() == describeEnum(UserType.guide)) {
        userList.insert(0, userItem);
      } else {
        userList.add(userItem);
      }
    }
    
    // 입장 대기중인 인원이 있는지
    drawerWaitPersonState = values.where((user) => user.getAuthority() == describeEnum(UserType.common)).isNotEmpty;
    if (drawerWaitPersonState) {
      bool isGuide = context.read<DataClass>().currentUser.getAuthority() == describeEnum(UserType.guide);

      userList.add(
        Container(
          height: 40,
          padding: EdgeInsets.all(5),
          margin: const EdgeInsets.only(top: 10, bottom: 10),
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: Colors.grey,
                width: 2
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 3.0), //(x,y)
                blurRadius: 3.0,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '입장 신청 목록',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15
                ),
              ),
            ],
          )
        )
      );

      /// 대기인원 추가.
      for (User user in values) {
        if (user.getAuthority() == describeEnum(UserType.common)) {
          userList.add(
            InkWell(
              onTap: () {
                if (!isGuide) return;
                _scaffoldKey.currentState?.closeDrawer();

                approvalUser(user);
              },
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(15),
                    height: 80,
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 3.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Image.network(user.getProfileURL().isEmpty ? Data.defaultImage : user.getProfileURL()),
                        Material(
                          color: Colors.transparent,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.network(
                              user.getProfileURL().isEmpty ? Data.defaultImage : user.getProfileURL(),
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                } else {
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                          : null,
                                    ),
                                  );
                                }
                              },
                              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                return Icon(Icons.error);
                              },
                            ),
                          ),
                        ),
                        Text(
                          user.getName(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 80,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(80),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: isGuide ? Material(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 2,
                      child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Icon(Icons.add)
                      )) : null,
                  ),
                ],
              )
            )
          );
        }
      }
    }

    return userList;
  }

  /// 유저 입장 승인.
  Future<void> approvalUser(User targetUser) async {
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
            child: const Text('인원 추가'),
          ),
          content: Container(
            alignment: Alignment.center,
            constraints: const BoxConstraints(maxHeight: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  targetUser.getName() + ' 님을 파티에 추가하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal
                  ),
                ),
              ],
            ),
          ),
          icon: const Icon(Icons.person_add),
          actions: [
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () async {
                  bool result = await changeAuthUser(targetUser.getUserCode());

                  if (!result) {
                    BotToast.showText(text: '서버 오류입니다. 나중에 다시 시도해주세요...');
                  }
                  Navigator.pop(context);
                },
                child: const Text('추가')),
            OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: BorderSide.none,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('취소')),
          ],
        ),
      ),
    ));
  }

  /// 상태 변경
  Future<bool> changeAuthUser(String userCode) async {
    var travelCode = context.read<DataClass>().travel.getTravelCode();

    final ref = FirebaseDatabase.instance.ref();
    final snapshot = await ref.child('travel/$travelCode').get();

    var result = snapshot.value;
    if (result != null) {
      var travel = Travel.fromJson(result);

      for (User user in travel.getUserList().values) {
        if (user.getUserCode() == userCode) {
          user.setAuthority(describeEnum(UserType.user));

          break;
        }
      }

      await ref.child('travel/$travelCode').set(travel.toJson());
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        width: 225,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const SizedBox(
              height: 100,
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 234, 242, 255),
                ),
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 5),
                    Text(
                      '인원 목록',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15
                      ),
                    ),
                  ],
                )
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Column(
                children: drawerUserList(context.watch<DataClass>().travel.getUserList().values.toList()),
              ),
            ),
          ],
        ),
      ),
      endDrawerEnableOpenDragGesture: false, // 드로워 수동제어 비활성.
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: currentPosition,
            onMapCreated: (controller) async {
              if (!_controller.isCompleted) {
                _controller.complete(controller);
              }
            },
            onTap: (argument) {
              setState(() {
                textFocus.unfocus();
              });
            },
            // markers: refreshUserMarker(context.watch<DataClass>().currentUser),
            // markers: test(context.watch<DataClass>().travel),
            markers: currentMarkers,
          ),
          // 검색창
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      offset: Offset(0.0, 3.0), //(x,y)
                      blurRadius: 6.0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () {
                            if (context.read<DataClass>().travel.getTravelCode().isEmpty) {
                              Navigator.pop(context);
                            } else {
                              Navigator.pushNamed(context, ScheduleRoute);
                            }
                          },
                          icon: context.read<DataClass>().travel.getTravelCode().isEmpty ?
                          const Icon(Icons.logout) : const Icon(Icons.event_note)),
                    ),
                    Flexible(
                        flex: 7,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Wrap(
                              children: [
                                MapAutoCompleteField(
                                  inputDecoration: const InputDecoration(
                                    contentPadding: EdgeInsets.only(left: 10, right: 50),
                                    filled: true,
                                    fillColor: Colors.white,
                                    hintText: '장소 입력...',
                                    enabledBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey, width: .5),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                      BorderSide(color: Colors.grey, width: .5),
                                      borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                    ),
                                  ),
                                  googleMapApiKey: SystemUtil.getGoogleKey(),
                                  // locale: 'kr',
                                  focusNode: textFocus,
                                  controller: textEditingController,
                                  hint: '탭 해서 검색...',
                                  itemBuilder: (BuildContext context, suggestion) {
                                    return ListTile(
                                      leading: const Icon(Icons.explore_outlined),
                                      title: Text(suggestion.description),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    textEditingController.text =
                                        suggestion.description;

                                    findAddressForPlace(suggestion.placeId);
                                  },
                                ),
                              ],
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  textEditingController.text = "";
                                },
                              ),
                            ),

                          ],
                        )),
                  ],
                )),
          ),
          /// 인원 상태
          Positioned(
            top: 122,
            left: 10,
            child: Visibility(
              visible: context.watch<DataClass>().travel.getTravelCode().isNotEmpty,
              child: InkWell(
                onTap: () {
                  // 측면 드로워 열기.
                  openDrawer();
                },
                child: badges.Badge(
                  showBadge: drawerWaitPersonState,
                  badgeStyle: badges.BadgeStyle(
                    badgeColor: Colors.orange,
                    borderRadius: BorderRadius.circular(4),
                    elevation: 5,
                  ),
                  position: badges.BadgePosition.topEnd(top: -8, end: -8),
                  badgeContent: Text(
                    'N',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
                    decoration: BoxDecoration(
                      color: drawerWaitPersonState? Colors.yellow : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 3.0), //(x,y)
                          blurRadius: 6.0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 5),
                        Text(
                          context.watch<DataClass>().travel.getUserList().length.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15
                          ),
                        ),
                        SizedBox(width: 3),
                      ],
                    ),
                  ),
                ),
              )
            )
          ),
          // GPS
          Positioned(
            right: 25,
            bottom: context.watch<DataClass>().travel.getTravelCode().isNotEmpty ? 100 : 30,
            child: SizedBox(
                width: 65,
                height: 65,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          offset: const Offset(3, 3),
                          blurRadius: 10,
                          color: Colors.black.withAlpha(50),
                          spreadRadius: 1)
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: const Icon(
                        Icons.my_location,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        _getCurrentLocation();
                      },
                    ),
                  ),
                ))),
          /// 네비게이션
          Visibility(
            visible: context.watch<DataClass>().travel.getSchedule().isNotEmpty,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned(
                  top: 120,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 10, left: 40, right: 40),
                    child: Text(
                      context.watch<DataClass>().targetDayKey,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.only(bottom: 100, top: 100, left: 10, right: 10),
                      child: Icon(Icons.keyboard_arrow_left, size: 25, color: Colors.white,),
                    ),
                    onTap: () => moveRoute(0),
                  )
                ),
                Positioned(
                  right: 10,
                  child: InkWell(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(100),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      padding: EdgeInsets.only(bottom: 100, top: 100, left: 10, right: 10),
                      child: Icon(Icons.keyboard_arrow_right, size: 25, color: Colors.white,),
                    ),
                    onTap: () => moveRoute(1),
                  )
                ),
                Positioned(
                  bottom: 100,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: EdgeInsets.only(bottom: 10, top: 10, left: 20, right: 20),
                    child: Text(
                      getRouteState(context.watch<DataClass>().targetRoute),
                      maxLines: 1,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
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
