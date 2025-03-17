class Result<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  Result._({this.data, this.error, required this.isSuccess});

  factory Result.success(T data) {
    return Result._(data: data, isSuccess: true);
  }

  factory Result.failure(String error) {
    return Result._(error: error, isSuccess: false);
  }

  T getOrThrow() {
    if (isSuccess && data != null) {
      return data!;
    }
    throw Exception(error ?? '未知错误');
  }

  bool get isFailure => !isSuccess;

  R fold<R>(
      {required R Function(T data) onSuccess,
      required R Function(String error) onFailure}) {
    if (isSuccess && data != null) {
      return onSuccess(data as T);
    } else {
      return onFailure(error ?? '未知错误');
    }
  }
}
