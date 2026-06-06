import 'package:dio/dio.dart';

String apiErrorMessage(Object error, {required bool isLogin}) {
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Cannot reach the server. Start the backend on port 8000.';
      default:
        break;
    }

    final statusCode = error.response?.statusCode;
    final detail = error.response?.data;
    String? serverMessage;
    if (detail is Map && detail['detail'] != null) {
      serverMessage = detail['detail'].toString();
    }

    if (statusCode == 401) {
      return serverMessage ?? 'Invalid email or password.';
    }
    if (statusCode == 400) {
      return serverMessage ?? 'Registration failed. Email may already be in use.';
    }
    if (statusCode != null) {
      return serverMessage ?? 'Request failed ($statusCode).';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Cannot reach the server. Start the backend on port 8000.';
    }
  }

  return isLogin
      ? 'Login failed. Check your credentials.'
      : 'Registration failed. Please try again.';
}
