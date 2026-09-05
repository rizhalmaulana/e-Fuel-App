import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';

class ApiClientNetwork {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlApiStatic.API_END_POINT,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static bool _initialized = false;

  static Dio get dio {
    if (!_initialized) {
      _initialized = true;
    }
    return _dio;
  }
}