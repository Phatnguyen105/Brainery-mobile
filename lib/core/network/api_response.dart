class ApiResponse<T> {
  const ApiResponse({
    required this.message,
    required this.data,
    this.code,
    this.success,
  });

  final String? code;
  final String message;
  final T data;
  final bool? success;

  static ApiResponse<T> fromJson<T>(
    Map<String, dynamic> json,
    T Function(Object? json) parseData,
  ) {
    return ApiResponse<T>(
      code: json['code']?.toString(),
      message: json['message']?.toString() ?? '',
      success: json['success'] is bool ? json['success'] as bool : null,
      data: parseData(json['data']),
    );
  }
}
