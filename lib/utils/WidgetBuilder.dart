import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomDialog {
  /// 버튼없음
  static noButton(BuildContext context,
    String title,
    Widget? content,
  ) {
    showDialog(context: context, builder: (context) {
      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.only(left: 20, right: 20, top: 5, bottom: 5),
                        margin: EdgeInsets.only(bottom: 20),
                        child: Text(
                          title ?? '',
                          style: TextStyle(
                              fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                      child: content ?? Container(),
                  ),
                ],
              )
          )
      );
    });
  }

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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
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

  static WebViewController _controller = WebViewController();
  static showNotice(
      BuildContext context,
      String url,
      ) {
    showDialog(context: context, builder: (context) {
      _controller.loadRequest(Uri.parse(url));
      _controller.setJavaScriptMode(JavaScriptMode.unrestricted);

      return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
              padding: EdgeInsets.all(15),
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Expanded(
                    child: WebViewWidget(controller: _controller),
                  ),
                  const SizedBox(height: 15),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 10),
                      margin: EdgeInsets.only(bottom: 10),
                      child: Icon(Icons.close)
                    ),
                  )
                ],
              )
          )
      );
    });
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
