import 'dart:async';
import 'dart:io';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_together/utils/Translate_util.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:volume_control/volume_control.dart';

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

  late FlutterTts flutterTts;

  late stt.SpeechToText _speech;

  // 음성인식 상태.
  bool isRecord = false;
  bool isRecordPermission = false;
  bool isSTTInit = false;

  List<stt.LocaleName> localeList = [];

  @override
  void initState() {
    super.initState();
    _initializeTts();
    _initializeStt();
  }

  @override
  void dispose() {
    _speech.stop();

    super.dispose();
  }

  Future _initializeStt() async {
    _speech = stt.SpeechToText();
    _checkPermissionAndInitialize();
  }

  Future<void> _checkPermissionAndInitialize() async {
    if (await _checkPermission()) {
      isSTTInit = await _speech.initialize(
        onStatus: (status) {
          logger.e('status: ' + status);
          if (status.contains('done')) {
            _speech.stop();
  
            BotToast.showText(text: '음성인식이 종료되었습니다.');

            setState(() {
              isRecord = false;
            });
          }
        },
        onError: (errorNotification) {
          logger.e('error: ' + errorNotification.toString());

          _speech.stop();

          BotToast.showText(text: '인식 실패... 다시 시도해주세요.');
          setState(() {
            isRecord = false;
          });

        },
      );

      if (isSTTInit) {
        localeList = await _speech.locales();
      }
    } else {
      await _requestPermission();
    }
  }

  Future<void> _requestPermission() async {
    final PermissionStatus status = await Permission.microphone.request();
    isRecordPermission = status.isGranted;
    if (isRecordPermission) {
      await _checkPermissionAndInitialize();
    } else {
      // 권한이 거부되었을 때의 처리를 수행합니다.
      print('Permission denied');
    }
  }

  Future<bool> _checkPermission() async {
    if (await Permission.microphone.status.isGranted) {
      isRecordPermission = true;
      return true;
    }
    return false;
  }

  Future _initializeTts() async {
    flutterTts = FlutterTts();

    // 플랫폼 구분
    if (Platform.isAndroid) {
      await flutterTts.getEngines;
    } else {
      await flutterTts.setSharedInstance(true);
    } 

    // await flutterTts.getDefaultVoice;
    await flutterTts.setLanguage("en-US"); // 언어 설정 (예: 영어)
    await flutterTts.setPitch(1.0); // 피치 설정 (기본값: 1.0)
    await flutterTts.setSpeechRate(0.5); // 읽는 속도 설정 (기본값: 1.0)

    // 기기의 미디어 음량에 맞게 설정 (0.0 ~ 1.0)
    double deviceVolume = await VolumeControl.volume;
    await flutterTts.setVolume(deviceVolume);

    if (Platform.isIOS) {
      await flutterTts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }

    List<dynamic> test = await flutterTts.getLanguages;

    String language = "";
    language = TranslateUtil.countryCode[endLangeTxt] ?? 'en';
    for (String code in test) {
      if (code.contains(language)) {
        await flutterTts.setLanguage(code);
        break;
      }
    }
  }

  /// 음성 출력...
  Future _speak() async {
    await flutterTts.speak(resultStr); // 출력할 텍스트 설정
  }

  Future _translate() async {
    if (textEditingController.text.isNotEmpty) {
      var list = TranslateUtil.countryCode;

      /*resultStr = await TranslateUtil.translateText(
          list[startLangTxt]!, list[endLangeTxt]!, textEditingController.text);*/

      resultStr = await TranslateUtil.translate(list[startLangTxt]!, list[endLangeTxt]!, textEditingController.text);

      setState(() {
        // BotToast.showText(text: resultStr);
      });
    }
  }

  // STT 전용 localeId 얻기.
  String _getLocaleId(String countryName) {
    String resultId = '';

    var isoCode = '';
    isoCode = TranslateUtil.countryCode[countryName] ?? 'en';

    for (stt.LocaleName data in localeList) {
      if (data.localeId.contains(isoCode)) {
        resultId = data.localeId;
        break;
      }
    }

    return resultId;
  }

  /// 음성 인식...
  Future _record() async {
    BotToast.showText(text: '음성인식 중입니다.');

    if (!isRecordPermission) {
      BotToast.showText(text: '권한이 거부되었습니다. 앱 설정에서 권한을 허용해 주세요.');
      return;
    }

    if (isSTTInit) {
      var inputLocaleId = _getLocaleId(startLangTxt);

      if (inputLocaleId.isEmpty) {
        var systemLocale = await _speech.systemLocale();
        inputLocaleId = systemLocale!.localeId;
      }

      _speech.listen(
        localeId: inputLocaleId,
        onDevice: false,
        listenMode: stt.ListenMode.dictation,
        listenFor: Duration(seconds: 10),
        pauseFor: Duration(seconds: 9),
        onResult: (result) {
          textEditingController.text = result.recognizedWords;
          _translate();
        },
        // cancelOnError: true,
      );

      setState(() {
        isRecord = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context);
      },
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
            /*IconButton(
              onPressed: () async {
                //
              },
              icon: const Icon(
                Icons.info_outline_rounded,
                color: Colors.white,
              ),
            ),*/
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
          child: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                      flex: 10,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Stack(
                              children: [
                                TextField(
                                  controller: textEditingController,
                                  maxLines: null,
                                  onChanged: (value) {
                                    //
                                  },
                                  onSubmitted: (value) async {
                                    _translate();
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
                                Positioned(
                                  right: 10,
                                  bottom: 10,
                                  child: InkWell(
                                      onTap: () async {
                                        _translate();
                                      },
                                      child: const SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black,
                                          child: Icon(
                                            Icons.arrow_forward,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                  ),
                                ),
                                Positioned(
                                  right: 70,
                                  bottom: 10,
                                  child: InkWell(
                                      onTap: () async {
                                        _record();
                                      },
                                      child: const SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.black,
                                          child: Icon(
                                            Icons.keyboard_voice_rounded,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      )
                                  ),
                                )
                              ],
                            ),
                          ),
                          Visibility(
                            visible: textEditingController.text.isNotEmpty,
                            child: Expanded(
                                flex: 1,
                                child: Stack(
                                  children: [
                                    Container(
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
                                    Positioned(
                                      right: 10,
                                      bottom: 10,
                                      child: InkWell(
                                          onTap: () {
                                            _speak();
                                          },
                                          child: const SizedBox(
                                            width: 50,
                                            height: 50,
                                            child: CircleAvatar(
                                              backgroundColor: Colors.black,
                                              child: Icon(
                                                Icons.volume_up,
                                                color: Colors.white,
                                                size: 30,
                                              ),
                                            ),
                                          )
                                      ),
                                    )
                                  ],
                                )
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
                                          if (textEditingController.text.isNotEmpty) {
                                            var temp = textEditingController.text;
                                            textEditingController.text = resultStr;
                                            resultStr = temp;
                                          }

                                          _initializeTts();

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
              ),
              Visibility(
                visible: isRecord,
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius:
                          BorderRadius.circular(10)),
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.keyboard_voice_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
                              SizedBox(height: 15),
                              Text(
                                '음성 인식 중입니다...',
                                style: TextStyle(
                                  color: Colors.white
                                ),
                              ),
                              SizedBox(height: 15),
                              TextButton(
                                onPressed: () {
                                  _speech.stop();

                                  setState(() {
                                    isRecord = false;
                                  });
                                },
                                child: Text(
                                  '확인',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(15)),
                                  ),
                                  backgroundColor: Colors.white,
                                ),
                              ),
                            ],
                          )
                        ),
                      ),
                    )
                  ],
                ),
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
            _initializeTts();

            _translate();

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
