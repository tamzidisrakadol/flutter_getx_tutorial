import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import 'Screen1.dart';

class Screen2 extends StatefulWidget {

  var titleName;
  Screen2({super.key,this.titleName});

  @override
  State<Screen2> createState() => _Screen2State();
}

class _Screen2State extends State<Screen2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screen 2"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("The passed data is ${Get.arguments[0]}"),
            ElevatedButton(onPressed: (){
              Get.back();
              Get.back();
            }, child: Text("Navigate to home screen"))
          ],
        ),
      ),
    );
  }
}
