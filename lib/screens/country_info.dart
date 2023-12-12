import 'package:countries_world_map/countries_world_map.dart';
import 'package:countries_world_map/data/maps/world_map.dart';
import 'package:flutter/material.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 여행지 정보 목록 씬
class CountryInfoView extends StatefulWidget {
  const CountryInfoView({Key? key, required this.arguments}) : super(key: key);
  final Map<String, String> arguments;

  @override
  State<StatefulWidget> createState() => _CountryInfoViewState();
}

class _CountryInfoViewState extends State<CountryInfoView> {
  var logger = Logger();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black.withAlpha(200),
          leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          actions: [
            IconButton(
              onPressed: () async {
                CustomDialog.oneButton(
                  context, Icons.info_outline_rounded, '안내', '외교부에서 제공한 데이터입니다.'
                    , null, '확인', () {
                    Navigator.pop(context);
                  }, false
                );
              },
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '여행지 정보',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(200),
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Color.fromARGB(150, 255, 255, 255),
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  offset: Offset(0.0, 3.0), //(x,y)
                  blurRadius: 3.0,
                ),
              ],
            ),
            child: Container(
              width: double.infinity,
              height: 500,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black87,
                            offset: Offset(0.0, 1.0),
                            blurRadius: 3.0,
                          ),
                        ],
                      ),
                      // Actual widget from the Countries_world_map package.
                      child: SimpleMap(
                        instructions: SMapWorld.instructions,
                        // If the color of a country is not specified it will take in a default color.
                        defaultColor: Colors.white,
                        // CountryColors takes in 250 different colors that will color each country the color you want. In this example it generates a random color each time SetState({}) is called.
                        callback: (id, name, tapdetails) {
                          // goToCountry(id);
                        },
                        countryBorder: CountryBorder(color: Colors.grey),
                        colors: SMapWorldColors(
                          kR: Colors.green,
                        ).toMap(),
                      ),
                    ),
                  ],
                ),
              )
            ),
          )
        ),
      ),
    );
  }
}

/// 공지 아이템
class CountryViewItem extends StatefulWidget {
  final Notice item;
  final bool isRead;

  const CountryViewItem({
    Key? key, required this.item, required this.isRead
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountryViewItem();
}

class _CountryViewItem extends State<CountryViewItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        CustomDialog.showNotice(context, widget.item.url);
      },
      child: Container(
        margin: EdgeInsets.all(10),
        width: double.infinity,
        height: 35,
        decoration: BoxDecoration(
          color: widget.isRead ? Colors.black.withAlpha(200) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 1.0), //(x,y)
              blurRadius: 3.0,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  widget.item.getNoticeCode(),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_square,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Text(
                      widget.item.getUpdateTime(),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                )
              ),
            ),
            Text(
              widget.item.getTitle(),
              style: TextStyle(
                color: widget.isRead ? Colors.grey : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}