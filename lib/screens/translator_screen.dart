import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_google_maps_webservices/geocoding.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_together/screens/schedule_screen.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/Translate_util.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:logger/logger.dart';
import 'package:map_autocomplete_field/map_autocomplete_field.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/string.dart';

/// 번역기 씬
class TranslatorView extends StatefulWidget {
  const TranslatorView({
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TranslatorViewState();
}

class _TranslatorViewState extends State<TranslatorView> {
  var logger = Logger();

  TextEditingController textEditingController = TextEditingController();
  String resultStr = "";
  String startLangTxt = "한국어";
  String endLangeTxt = "영어";

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
                //
              },
              icon: const Icon(Icons.info_outline_rounded),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '번역기',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
        ),
        body: Container(
          padding: EdgeInsets.only(top: 15, left: 15, right: 15),
          width: double.infinity,
          height: double.infinity,
          color: Colors.black.withAlpha(200),
          child: Column(
            children: [
              Expanded(
                flex: 10,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: TextField(
                        controller: textEditingController,
                        maxLines: null,
                        onChanged: (value) {
                          //
                        },
                        onSubmitted: (value) async {
                          if (textEditingController.text.isNotEmpty) {
                            var list = TranslateUtil.countryCode;

                            resultStr = await TranslateUtil.translateText(
                                list[startLangTxt]!, list[endLangeTxt]!, textEditingController.text);

                            setState(() {
                              // BotToast.showText(text: resultStr);
                            });
                          }
                        },
                        onEditingComplete: () {
                          // BotToast.showText(text: 'text');
                        },
                        textAlignVertical: TextAlignVertical.top,
                        expands: true,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color.fromARGB(150, 255, 255, 255),
                          // labelText: context.watch<ScheduleClass>().travel.getNotice(),
                          alignLabelWithHint: true,
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
                    Visibility(
                      visible: textEditingController.text.isNotEmpty,
                      child: Expanded(
                        flex: 1,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          width: double.infinity,
                          height: double.infinity,
                          margin: EdgeInsets.only(top: 10),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(150, 255, 255, 255),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            resultStr,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 17
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Text(
                        '언어 버튼을 꾹 눌러서 음성 입력',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: TextButton(
                              onPressed: () {
                                CustomDialog.noButton(
                                  context,
                                  '언어를 선택하세요',
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: GridView.count(
                                      childAspectRatio: 5 / 1,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      children: getCountryItemList(
                                        0,
                                        startLangTxt,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(15)),
                                ),
                                backgroundColor: Colors.white
                              ),
                              child: Text(
                                startLangTxt,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 1,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  var temp = startLangTxt;
                                  startLangTxt = endLangeTxt;
                                  endLangeTxt = temp;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      offset: Offset(0.0, 1.0), //(x,y)
                                      blurRadius: 3.0,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.swap_horiz,
                                  color: Colors.black,
                                ),
                              )
                            )
                          ),
                          SizedBox(width: 5),
                          Expanded(
                            flex: 4,
                            child: TextButton(
                              onPressed: () {
                                CustomDialog.noButton(
                                  context,
                                  '언어를 선택하세요',
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: EdgeInsets.all(10),
                                    child: GridView.count(
                                      childAspectRatio: 5 / 1,
                                      shrinkWrap: true,
                                      physics: ScrollPhysics(),
                                      crossAxisCount: 1,
                                      mainAxisSpacing: 5,
                                      crossAxisSpacing: 5,
                                      children: getCountryItemList(
                                        1,
                                        endLangeTxt,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                endLangeTxt,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                  backgroundColor: Colors.white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              ),
            ],
          )
        ),
      ),
    );
  }

  List<Widget> getCountryItemList(int index, String block) {
    List<Widget> widgetList = [];

    for (String country in TranslateUtil.countryCode.keys) {
      widgetList.add(
        CountryItem(
          countryName: country, action: () {
            // 반대편 언어 선택 시.
            if (country == startLangTxt) {
              var temp = endLangeTxt;
              endLangeTxt = country;
              startLangTxt = temp;
            } else if (country == endLangeTxt) {
              var temp = startLangTxt;
              startLangTxt = country;
              endLangeTxt = temp;
            } else {
              if (index == 0) {
                startLangTxt = country;
              } else {
                endLangeTxt = country;
              }
            }

            setState(() {
              Navigator.pop(context);
            });

          },
          isSelected: country == block,
        )
      );
    }

    return widgetList;
  }
}

/// 나라 아이템
class CountryItem extends StatefulWidget {
  final String countryName;
  final VoidCallback action;
  final bool isSelected;

  const CountryItem(
      {Key? key,
        required this.countryName,
        required this.action, required this.isSelected})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CountryItem();
}

class _CountryItem extends State<CountryItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.isSelected ? null : widget.action,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: widget.isSelected ? Colors.black.withAlpha(200) : Colors.grey,
          borderRadius: BorderRadius.circular(10),
        ),
        height: 35,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Center(
            child: Text(
              widget.countryName,
              style: TextStyle(
                color: widget.isSelected ? Colors.grey : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )
      ),
    );
  }
}
