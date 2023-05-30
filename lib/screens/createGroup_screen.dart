import 'package:flutter/material.dart';

/// 그룹생성 씬
class CreateGroupView extends StatelessWidget {
  const CreateGroupView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController editingController = TextEditingController();

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 234, 242, 255),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(15),
                width: 50,
                height: 150,
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
