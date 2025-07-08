import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';

class CounterController extends GetxController{

  RxInt counter = 0.obs;

  RxDouble opacity = 0.4.obs;

  RxString imagePath = "".obs;


  void increment(){
    counter++;
  }

  void decrement(){
    counter--;
  }

  void changeOpacity(double value){
    opacity.value = value;
  }

  Future<void> getImage() async{
    final ImagePicker imagePicker = ImagePicker();
    final image = await imagePicker.pickImage(source: ImageSource.gallery);
    if(image != null){
      imagePath.value = image.path;
    }

  }



}