import 'package:dio/dio.dart';

class DioClient {
  final Dio dio;

  DioClient() : dio = Dio(
    BaseOptions(
      baseUrl: "https://api.escuelajs.co/",
    )
  );

  Future<Response> get(String path) => dio.get(path);

}