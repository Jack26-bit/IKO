import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _getBaseUrl(),
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
      headers: {
        'Content-Type': 'application/json',
      },
    ));
  }

  String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000';
    } else {
      return 'http://127.0.0.1:8000';
    }
  }

  Dio get client => _dio;
}

final apiService = ApiService();
