import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';

class ApiClientNetwork {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlApiStatic.API_END_POINT,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 15),
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