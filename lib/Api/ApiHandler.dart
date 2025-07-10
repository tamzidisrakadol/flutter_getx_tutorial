import 'package:dio/dio.dart';
import 'ApiResponse.dart';

Future<(int, ApiResponse<T>)> safeApiCall<T>(
    Future<Response<T>> Function() request) async {
  try {
    final response = await request();
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    if (statusCode >= 200 && statusCode < 300) {
      if (data != null) {
        return (statusCode, ApiResponse<T>.success(data, statusCode));
      } else {
        return (statusCode, ApiResponse<T>.failure("Response body is null", statusCode));
      }
    } else {
      final errorMsg = response.statusMessage ?? "Unknown Error";
      return (statusCode, ApiResponse<T>.failure(errorMsg, statusCode));
    }
  } catch (e) {
    return (0, ApiResponse<T>.failure(e.toString()));
  }
}