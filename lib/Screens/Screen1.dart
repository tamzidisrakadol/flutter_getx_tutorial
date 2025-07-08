import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx/Screens/Screen2.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Screen 1"),
      ),
      body: Center(
        child: Column(
          children: [
            Text("Screen 1"),
            ElevatedButton(onPressed: (){
              //example with getx navigation
              //Get.to(Screen2());

              //example with route
              Get.toNamed("/screen2",arguments: ["Screen 1 data"]);

            }, child: Text("Navigate to Screen 2"))
          ],
        ),
      ),
    );
  }
}
