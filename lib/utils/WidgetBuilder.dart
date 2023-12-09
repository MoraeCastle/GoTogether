import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_together/utils/system_util.dart';

class CustomDialog {
  /// 공지.
  static oneButton(
      BuildContext context,
      IconData icon,
      String title,
      String subTitle,
      Widget? content,
      String buttonTxt,
      VoidCallback action,
      bool isLockBack,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !isLockBack,
      builder: (context) =>
          WillPopScope(
            onWillPop: () async => !isLockBack,
            child: AlertDialog(
              title: Container(
                alignment: Alignment.center,
                child: Text(title),
              ),
              content: Wrap(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                        content ?? SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
              icon: Icon(icon),
              actions: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: action,
                    child: Text(buttonTxt)),
              ],
            ),
          ),);
  }

  static doubleButton(
      BuildContext context,
      IconData icon,
      String title,
      String subTitle,
      Widget? content,
      String okButtonTxt,
      VoidCallback okAction,
      String cancelButtonTxt,
      VoidCallback cancelAction,
      bool isLockBack,
      ) {
    showDialog(
      context: context,
      barrierDismissible: !isLockBack,
      builder: (context) =>
          WillPopScope(
            onWillPop: () async => !isLockBack,
            child: AlertDialog(
              title: Container(
                alignment: Alignment.center,
                child: Text(title),
              ),
              content: Wrap(
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          subTitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.normal
                          ),
                        ),
                        content ?? SizedBox(),
                      ],
                    ),
                  ),
                ],
              ),
              icon: Icon(icon),
              actions: [
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: okAction,
                    child: Text(okButtonTxt)),
                OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide.none,
                    ),
                    onPressed: cancelAction,
                    child: Text(cancelButtonTxt)),
              ],
            ),
          ),);
  }
}
/*class Form extends StatelessWidget {
  const Form({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

  }
}*/
/*
class ItemCard extends StatelessWidget {
  final String item;

  const ItemCard({Key? key, required this.item}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.symmetric(
        horizontal: 5.0,
        vertical: 5.0,
      ),
      child: Stack(children: [
      ]),
    );
  }
}
*/
