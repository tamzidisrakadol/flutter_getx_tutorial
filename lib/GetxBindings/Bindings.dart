import 'package:get/get.dart';

import '../DB/DbService.dart';
import '../Transactions.dart';
import '../getxStateManagement/HomeController.dart';

class HomeBindings extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut<DbService>(() => DbService()); //singleton
    Get.lazyPut<HomeController>(() => HomeController()); //singleton
    Get.create<Transactions>(()=>Transactions()); //factory
  }


}