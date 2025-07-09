import 'package:flutter/material.dart';
import 'package:flutter_getx/GetxBindings/Bindings.dart';
import 'package:flutter_getx/Screens/Screen1.dart';
import 'package:flutter_getx/getxStateManagement/HomeController.dart';
import 'package:get/get.dart';
import 'Api/SampleApiService.dart';
import 'Screens/Screen2.dart';
import 'Transactions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
      initialBinding: HomeBindings(),
      getPages: [
        GetPage(name: "/", page: ()=> MyHomePage(title: 'Flutter Demo Home Page')),
        GetPage(name: "/screen1", page: ()=> Screen1()),
        GetPage(name: "/screen2", page: ()=> Screen2())
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late SampleApiService sampleApiService;
  final HomeController homeController = Get.find();
  final Transactions transactions = Get.find();

  @override
  void initState() {
    sampleApiService=Get.put(SampleApiService());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){

          Get.snackbar("Fluter", "Getx Tutorial",backgroundColor: Colors.red,snackPosition: SnackPosition.BOTTOM);
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: EdgeInsetsGeometry.all(5),
        child: Column(
          children: [
            Card(
              elevation: 10,
              child: ListTile(
                title: Text("Getx Alert Dialog"),
                subtitle: Text("Tap to open alert dialog"),
                onTap: (){

                  //alert dialog
                  Get.defaultDialog(
                    title: "Alert Dialog with Getx",
                    middleText: "This is an alert dialog with Getx",
                    confirm: TextButton(onPressed: (){
                      Get.back();
                    }, child: Text("Yes")),
                    cancel: TextButton(onPressed: (){
                      Get.back();
                    }, child: Text("No")),
                  );



                },
              ),
            ),


            Card(
              elevation: 10,
              child: ListTile(
                title: Text("Getx btm sheet"),
                subtitle: Text("Tap to open btm sheet"),
                onTap: (){

                  //btm sheet
                  Get.bottomSheet(Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Icon(Icons.light_mode),
                          title: Text("Light mode"),
                          onTap: (){
                            Get.changeTheme(ThemeData.light());
                            Get.back();
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.dark_mode),
                          title: Text("dark mode"),
                          onTap: (){
                            Get.changeTheme(ThemeData.dark());
                            Get.back();
                          },
                        ),
                      ],
                    ),
                  ));
                },
              ),
            ),


            Card(
              elevation: 10,
              child: ListTile(
                title: Text("Navigate"),
                subtitle: Text("navigate to another screen"),
                onTap: (){
                  //navigate to another screen with getx
                 // Get.to(Screen1());


                  //getx route
                  Get.toNamed("/screen1");
                },
              ),
            ),

            //Di=Sample Di
            Card(
              elevation: 10,
              child: ListTile(
                title: Text("DI Sample"),
                subtitle: Text("Tap to fetch data from api"),
                onTap: (){
                  sampleApiService.fetchData();
                },
              ),
            ),

            //Di=Bindings
            Card(
              elevation: 10,
              child: ListTile(
                title: Text("DI Bindings Sample"),
                subtitle: Text("Tap to perform db operation"),
                onTap: (){
                  homeController.dbOperation();
                },
              ),
            ),

            //Di=Bindings(Factory pattern= everytime create a new instance)
            Card(
              elevation: 10,
              child: ListTile(
                title: Text("Create transaction"),
                subtitle: Text("Tap to generate transaction"),
                onTap: (){
                  transactions.createTransaction();
                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}
