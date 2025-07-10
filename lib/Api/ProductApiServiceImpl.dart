import 'package:dio/dio.dart';
import 'package:flutter_getx/Api/DioClient.dart';
import 'package:flutter_getx/Api/ProductApiService.dart';

class ProductApiServiceImpl implements ProductApiService{

   final DioClient dioClient;

   ProductApiServiceImpl(this.dioClient);

  @override
  Future<Response> fetchProduct() {
      return dioClient.get("api/v1/products");
  }

}