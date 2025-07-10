import 'package:dio/dio.dart';

abstract class ProductApiService{
  Future<Response> fetchProduct();
}