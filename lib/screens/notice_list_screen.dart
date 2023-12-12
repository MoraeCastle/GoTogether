import 'package:flutter/material.dart';
import 'package:go_together/models/Notice.dart';
import 'package:go_together/utils/WidgetBuilder.dart';
import 'package:go_together/utils/network_util.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// 공지사항 목록 씬
class NoticeListView extends StatefulWidget {
  const NoticeListView({
    Key? key, required this.arguments
  }) : super(key: key);

  final Map<String, Notice> arguments;

  @override
  State<StatefulWidget> createState() => _NoticeListViewState();
}

class _NoticeListViewState extends State<NoticeListView> {
  var logger = Logger();

  List<Widget> noticeList = [];

  WebViewController _controller = WebViewController();

  @override
  void initState() {
    _controller = WebViewController()
      ..loadRequest(Uri.parse('https://youtube.com'))
      ..setJavaScriptMode(JavaScriptMode.unrestricted);


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
                NetworkUtil.writeNotice(
                  '0001', '이 앱을 설치해주셔 감사합니다.', 'naver.com', '2023-12-20', '2023-12-30');
              },
              icon: const Icon(Icons.add),
            ),
          ],
          shadowColor: Colors.transparent,
          centerTitle: true,
          title: const Text(
            '공지사항',
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
              child: widget.arguments.isNotEmpty ?
                GridView.count(
                  childAspectRatio: 3 / 1,
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  crossAxisCount: 1,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  children: getNoticeItemList(widget.arguments),
                ) :
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cancel_presentation,
                          size: 80,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text('게시된 공지가 없습니다.')
                      ],
                    ),
                  ),
            ),
          )
        ),
      ),
    );
  }

  List<Widget> getNoticeItemList(Map<String, Notice> dataList) {
    noticeList.clear();

    for (String code in dataList.keys) {
      // 날짜가 범위 이내이면 리스트에 추가.

      // 해당 코드로 기기내값이 체크여부가 있는지?
      bool isCheck = false;
      if (true) {
        noticeList.add(
          NoticeItem(
            item: dataList[code]!,
            isRead: isCheck,
          ),
        );
      }
    }

    return noticeList;
  }
}

/// 공지 아이템
class NoticeItem extends StatefulWidget {
  final Notice item;
  final bool isRead;

  const NoticeItem({
    Key? key, required this.item, required this.isRead
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NoticeItem();
}

class _NoticeItem extends State<NoticeItem> {
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