import 'package:flutter_getx/Api/ApiResponse.dart';
import 'package:flutter_getx/Modal/Product.dart';
import 'package:get/get.dart';

import '../Repository/ProductRepository.dart';

class ProductController extends GetxController{

  final ProductRepository productRepository;

  ProductController(this.productRepository);

  final apiResponse = Rx<ApiResponse<List<Product>>>(ApiResponse.loading());


  @override
  void onInit() {
    fetchProducts();
    super.onInit();
  }


  // Call this from the UI to load data
  Future<void> fetchProducts() async {
    apiResponse.value = ApiResponse.loading();

    final (code, response) = await productRepository.getAllProduct();
    apiResponse.value = response;
    print(response);
  }


}