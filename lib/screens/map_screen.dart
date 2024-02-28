import 'dart:async';
import 'package:app_settings/app_settings.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:custom_marker/marker_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/models/RouteItem.dart';
import 'package:go_together/models/User.dart';
import 'package:go_together/models/data.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/network_util.dart';
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
                borderColor: Colors.black,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      /*drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: Container(),
      ),
      drawerEdgeDragWidth: 10,*/
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
                          const Icon(Icons.logout) : const Icon(Icons.menu)),
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
