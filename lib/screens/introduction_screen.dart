import 'package:flutter/material.dart';
import 'package:go_together/service/routing_service.dart';
import 'package:go_together/utils/string.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 기능 안내 씬
class IntroductionView extends StatefulWidget {
  const IntroductionView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IntroductionViewState();
}

class _IntroductionViewState extends State<IntroductionView> {
  final introKey = GlobalKey<IntroductionScreenState>();

  /// 소개가 끝날 시.
  Future<void> _onIntroEnd(context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(SystemData.introCheck, true);

    Navigator.pop(context);
    Navigator.pushNamed(context, LoginViewRoute);
  }

  Widget _buildImage(String assetName, [double width = 250]) {
    return Image.asset('assets/$assetName', width: width);
  }

  @override
  Widget build(BuildContext context) {
    const bodyStyle = TextStyle(fontSize: 19.0);

    const pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(fontSize: 28.0, fontWeight: FontWeight.w700),
      bodyTextStyle: bodyStyle,
      bodyPadding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
      pageColor: Color.fromARGB(255, 234, 242, 255),
      imagePadding: EdgeInsets.zero,
      bodyFlex: 1,
      imageFlex: 2,
    );

    return IntroductionScreen(
      key: introKey,
      globalBackgroundColor: Color.fromARGB(255, 234, 242, 255),
      allowImplicitScrolling: true,
      // autoScrollDuration: 3000,

      infiniteAutoScroll: false,
      pages: [
        PageViewModel(
          title: "지도",
          body:
          "현재 일정과 팀원 위치를 확인하세요.",
          image: _buildImage('images/intro_1.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "채팅 & 번역기능",
          body:
          "팀원 혹은 외국인과 편하게 대화하세요.",
          image: _buildImage('images/intro_2.png'),
          decoration: pageDecoration,
        ),
        PageViewModel(
          title: "여행국가 정보",
          body:
          "여행가는 곳의 사건사고 소식을 확인하세요.",
          image: _buildImage('images/intro_3.png'),
          decoration: pageDecoration,
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text('건너뛰기', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      next: const Icon(Icons.arrow_forward),
      done: const Text('확인', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Colors.white,
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
      ),
      dotsContainerDecorator: const ShapeDecoration(
        color: Color.fromARGB(255, 159, 195, 255),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
      ),
    );
  }
}