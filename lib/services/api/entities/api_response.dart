sealed class ApiResponse<T> {}

class Success<T> extends ApiResponse<T> {
  T data;

  Success(this.data);
}


class Failure<T> extends ApiResponse<T> {
  String? message;
  int code;

  Failure({
    required this.code,
    this.message,
  });
}