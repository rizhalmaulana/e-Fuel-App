import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';

class ApiClientNetwork {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: UrlApiStatic.API_END_POINT,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );

  static Dio get dio => _dio;
}