import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/providers/data_provider.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

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

  late DataClass _countProvider;
  final Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  // 현재 위치 좌표
  late LatLng currentLatLng;
  CameraPosition currentPosition =
  const CameraPosition(target: LatLng(35.151624, 126.869592), zoom: 16);

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  _getCurrentLocation() async {
    Position position;

    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
          timeLimit: Duration(seconds: 15));

      currentLatLng = LatLng(position.latitude, position.longitude);
      GoogleMapController controller = await getController();

      setState(() {
        currentPosition = CameraPosition(target: currentLatLng, zoom: 16);

        controller.moveCamera(CameraUpdate.newLatLngZoom(currentLatLng, 17));

        logger.d(currentLatLng.toString());
      });

      BotToast.showText(text: '위치를 최신화 했습니다.');
    } catch (e) {
      logger.e(e.toString());
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    _countProvider = Provider.of<DataClass>(context, listen: false);

    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(20), bottomRight: Radius.circular(20)),
        ),
        child: Container(),
      ),
      drawerEdgeDragWidth: 10,
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: currentPosition,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
          ),
          // 검색창
          Positioned(
            top: 40,
            left: 10,
            right: 10,
            child: Container(
                width: double.infinity,
                height: 50,
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
                            // _scaffoldKey.currentState!.openDrawer();
                            // BotToast.showText(text: "text");

                            // 테스트
                            // Navigator.pop(context),
                            Navigator.pushNamed(context, ScheduleRoute);
                          },
                          icon: Icon(Icons.menu)),
                    ),
                    Flexible(
                      flex: 8,
                      child: TextField(
                        maxLines: 1,
                        controller: TextEditingController(),
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: '탭 해서 지도 검색...',
                          hintStyle: TextStyle(color: Colors.black26),
                          contentPadding: EdgeInsets.only(
                              left: 14.0, bottom: 8.0, top: 8.0),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black12, width: 1.5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                            BorderSide(color: Colors.black12, width: 1.5),
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                        ),
                        style: const TextStyle(),
                        onTap: () {
                          BotToast.showText(
                              text: _countProvider.travel.getTravelCode());
                        },
                      ),
                    ),
                  ],
                )),
          ),
          // GPS
          Positioned(
              right: 25,
              bottom: 100,
              child: SizedBox(
                  width: 65,
                  height: 65,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(offset: Offset(3, 3), blurRadius: 10, color: Colors.black.withAlpha(50), spreadRadius: 1)],
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: IconButton(
                        icon: Icon(
                          Icons.my_location,
                          color: Colors.black,
                        ),
                        onPressed: () async {
                          _getCurrentLocation();
                        },
                      ),
                    ),
                  )
              )
          ),
        ],
      ),
    );
  }
}
