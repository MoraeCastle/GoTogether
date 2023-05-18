import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// 메인 씬
class MapView extends StatelessWidget {
  MapView({Key? key}) : super(key: key);

  Completer<GoogleMapController> _controller = Completer();

  // 현재 위치 좌표
  CameraPosition currentPosition =
      CameraPosition(target: LatLng(35.151624, 126.869592), zoom: 16);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: currentPosition,
            onMapCreated: (controller) => {
              _controller.complete(controller),
            },
          ),
          Container(
            color: Colors.black,
            width: 150,
            height: 150,
          ),
        ],
      ),
    );
  }
}
