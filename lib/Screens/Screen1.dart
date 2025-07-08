import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_getx/Screens/Screen2.dart';
import 'package:flutter_getx/getxStateManagement/CounterController.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Screen1 extends StatefulWidget {
  const Screen1({super.key});

  @override
  State<Screen1> createState() => _Screen1State();
}

class _Screen1State extends State<Screen1> {
  final CounterController controller = CounterController();

  @override
  Widget build(BuildContext context) {
    print("build"); //checking the full widget is built or not

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.red, title: Text("Screen 1")),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print("rebuilt");
          controller.decrement();
        },
        child: Icon(Icons.plus_one),
      ),


      //make the make obx at the top level
      body: Center(
        child: Column(
          children: [
            Text("Screen 1"),
            ElevatedButton(
              onPressed: () {
                //example with getx navigation
                //Get.to(Screen2());

                //example with route
                Get.toNamed("/screen2", arguments: ["Screen 1 data"]);
              },
              child: Text("Navigate to Screen 2"),
            ),

            //getx state management
            Obx(() {
              return Text(
                "You have pushed the button this many times: ${controller.counter}",
                style: TextStyle(fontSize: 20),
              );
            }),

            Obx((){
              return Container(
                height: 100,
                width: 100,
                color: Colors.red.withOpacity(controller.opacity.value),
              );
            }),

            Obx(() {
              return Slider.adaptive(
                value: controller.opacity.value,
                onChanged: (value) {
                  controller.changeOpacity(value);
                },
              );
            }),

            //image picker
            TextButton(onPressed: (){controller.getImage();}, child: Text("Pick Images")),
            Obx((){
              return CircleAvatar(
                backgroundImage:controller.imagePath.isNotEmpty ? FileImage(File(controller.imagePath.value)) : null,
                radius: 50,
              );
            })


          ],
        ),
      ),
    );
  }
}
