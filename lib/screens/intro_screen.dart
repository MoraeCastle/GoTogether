import 'package:flutter/material.dart';

/// 로그인 씬
class IntroView extends StatelessWidget {
  const IntroView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      body: Center(
        child: Text(
          "Intro Screen",
          style: TextStyle(fontSize: 30, color: Colors.white),
        ),
      ),
    );
  }


}