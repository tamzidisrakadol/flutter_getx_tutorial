import 'package:get/get.dart';
import '../DB/DbService.dart';

class HomeController extends GetxController{

  late DbService dbService;

  @override
  void onInit() {
    dbService = Get.find<DbService>();
    super.onInit();
  }

  void dbOperation(){
    dbService.queryDb();
  }

}