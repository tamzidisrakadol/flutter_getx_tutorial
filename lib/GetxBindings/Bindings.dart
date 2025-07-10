import 'package:flutter_getx/Api/ProductApiService.dart';
import 'package:flutter_getx/Api/ProductApiServiceImpl.dart';
import 'package:flutter_getx/Repository/ProductRepository.dart';
import 'package:get/get.dart';
import '../Api/DioClient.dart';
import '../Controller/HomeController.dart';
import '../Controller/ProductController.dart';
import '../DB/DbService.dart';
import '../Transactions.dart';
class HomeBindings extends Bindings{

  @override
  void dependencies() {
    Get.lazyPut<DbService>(() => DbService()); //singleton
    Get.lazyPut<HomeController>(() => HomeController()); //singleton
    Get.create<Transactions>(()=>Transactions()); //factory
    Get.lazyPut(() => DioClient());
    Get.lazyPut<ProductApiService>(() => ProductApiServiceImpl(Get.find()));
    Get.lazyPut(() => ProductRepository(Get.find()));
    Get.lazyPut(() => ProductController(Get.find()));
  }

}