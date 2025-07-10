
sealed class ApiResponse<T> {
  const ApiResponse();

  factory ApiResponse.success(T data, int statusCode) => Success<T>(data, statusCode);
  factory ApiResponse.failure(String message, [int? statusCode]) => Failure<T>(message, statusCode);
  factory ApiResponse.loading() => Loading<T>();
}

class Loading<T> extends ApiResponse<T> {}

class Success<T> extends ApiResponse<T> {
  final T data;
  final int statusCode;
  const Success(this.data, this.statusCode);
}

class Failure<T> extends ApiResponse<T> {
  final String message;
  final int? statusCode;
  const Failure(this.message, [this.statusCode]);
}
