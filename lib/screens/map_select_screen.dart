import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_autocomplete_field/map_autocomplete_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/string.dart';

/// 위치 선택 씬
class MapSelectView extends StatefulWidget {
  const MapSelectView({
    Key? key,
    //required this.roomData,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MapSelectViewState();
}

class _MapSelectViewState extends State<MapSelectView> {
  var logger = Logger();

  final Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // 현재 위치 좌표
  late LatLng currentLatLng;
  CameraPosition currentPosition =
      const CameraPosition(target: LatLng(35.151624, 126.869592), zoom: 16);

  TextEditingController textEditingController = TextEditingController();

  FocusNode textFocus = FocusNode();
  String addressStr = "";
  bool isSearchDone = false;

  // 마커
  LatLng centerLatLng = LatLng(37.7749, -122.4194); // 중앙 좌표
  MarkerId markerId = MarkerId("center_marker");
  Set<Marker> markers = {};

  /// 맵 컨트롤러 가져오기
  Future<GoogleMapController> getController() async {
    return await _controller.future;
  }

  /// 선택한 위치 저장
  _saveTargetPosition(String position) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(SystemData.selectPosition, position);
  }

  /// PlaceId의 위치로 이동하기
  _findAddressForPlace(String placeId) async {
    final geocoding = GoogleMapsGeocoding(apiKey: "AIzaSyCjyYnbJHXEOYLHuCs7yhn00qv_a3GErts");
    final response =
        await geocoding.searchByPlaceId(placeId);

    if (response.isOkay) {
      final result = response.results.first.geometry;

      currentLatLng = LatLng(result.location.lat, result.location.lng);
      GoogleMapController controller = await getController();

      setState(() {
        currentPosition = CameraPosition(target: currentLatLng, zoom: 16);

        controller.moveCamera(CameraUpdate.newLatLngZoom(currentLatLng, 17));
      });
    } else {
      BotToast.showText(text: response.errorMessage.toString());
    }
  }

  /// 현재 위치로 이동하기.
  _getCurrentLocation() async {
    Position position;

    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          forceAndroidLocationManager: true,
          timeLimit: const Duration(seconds: 15));

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

  /// 화면 중앙에 마커를 고정시킵니다.
  _updateCenterMarker(LatLng newCenter) {
    currentLatLng = newCenter;

    final Marker marker = Marker(
      markerId: markerId,
      position: newCenter,
      icon: BitmapDescriptor.defaultMarker,
    );

    setState(() {
      markers.clear();
      markers.add(marker);
    });
  }

  /// 화면이 움직일 때의 해당 위치 최신화.
  Future<void> _updateAddress() async {
    List<Placemark> placemarks = await placemarkFromCoordinates(currentLatLng.latitude, currentLatLng.longitude);
    if (placemarks.isNotEmpty) {
      Placemark placemark = placemarks[0];
      String address = placemark.street ?? placemark.name ?? "Unknown";

      isSearchDone = true;

      setState(() {
        addressStr = address;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
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
          // 구글 맵
          GoogleMap(
            zoomControlsEnabled: false,
            mapType: MapType.normal,
            initialCameraPosition: currentPosition,
            onMapCreated: (controller) {
              if (!_controller.isCompleted) _controller.complete(controller);
            },
            onTap: (argument) {
              setState(() {
                textFocus.unfocus();
              });
            },
            onCameraMove: (CameraPosition position) {
              _updateCenterMarker(position.target); // 지도 이동 시 중앙에 마커 업데이트

              isSearchDone = false;
              addressStr = "....";
            },
            onCameraIdle: () {
              _updateAddress();
            },
            markers: markers,
          ),
          // 검색창
          Positioned(
            top: 40,
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
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.arrow_back)),
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
                              googleMapApiKey:
                              'AIzaSyCjyYnbJHXEOYLHuCs7yhn00qv_a3GErts',
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

                                _findAddressForPlace(suggestion.placeId);
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
                    )
                  ),
                ],
              )
            ),
          ),
          Positioned(
            bottom: 50,
            child: GestureDetector(
              child: Container(
                margin: const EdgeInsets.only(left: 10, right: 10),
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 30, right: 30),
                constraints: const BoxConstraints(
                  maxWidth: 350.0, // 최대 너비를 200.0으로 제한
                ),
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
                // 만약 검색중이라면?
                child: addressStr.isNotEmpty ?
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(15),
                      child: isSearchDone ? Icon(
                        Icons.check,
                        size: 35,
                      ) :
                      CircularProgressIndicator(
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      addressStr,
                      maxLines: 3,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text('탭 해서 이 장소로 지정',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                      ),),
                  ],
                ) : Text(
                    '검색하거나 지도를 움직여보세요...',
                ),
              ),
              onTap: () {
                if (!isSearchDone) {
                  BotToast.showText(text: '위치를 조회중입니다...');
                } else {
                  _saveTargetPosition(
                      "${currentLatLng.latitude},${currentLatLng.longitude}");
                  //Navigator.pushNamedAndRemoveUntil(context, AddScheduleRoute, (route) => false);

                  // Navigator.pushNamed(context, AddScheduleRoute);
                  Navigator.pop(context);

                  //BotToast.showText(text: '장소를 선택했습니다.');
                }
              },
            )
          ),
        ],
      ),
    );
  }
}
