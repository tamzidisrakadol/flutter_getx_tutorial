import 'package:dio/dio.dart';
import 'package:flutter_getx/Api/ApiHandler.dart';
import 'package:flutter_getx/Api/ProductApiService.dart';
import 'package:flutter_getx/Modal/Product.dart';
import '../Api/ApiResponse.dart';

class ProductRepository {
  final ProductApiService productApiService;

  ProductRepository(this.productApiService);

  Future<(int, ApiResponse<List<Product>>)> getAllProduct() async {
    return await safeApiCall<List<Product>>(() async {
      final response = await productApiService.fetchProduct();

      final List<dynamic> preproduction = response.data;
      final productList = preproduction
          .map((e) => Product.fromJson(e))
          .toList();

      return Response(
        data: productList,
        statusCode: response.statusCode,
        statusMessage: response.statusMessage,
        requestOptions: response.requestOptions,
      );
    });
  }
}
