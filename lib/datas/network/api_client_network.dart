import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';

class ApiClientNetwork {
  // late Dio dio;
  //
  // ApiClientNetwork() {
  //   dio = Dio(
  //     BaseOptions(
  //       baseUrl: UrlApiStatic.API_END_POINT,
  //       connectTimeout: const Duration(seconds: 20),
  //       receiveTimeout: const Duration(seconds: 20),
  //       sendTimeout: const Duration(seconds: 20),
  //       headers: {
  //         'Content-Type': 'application/json',
  //       },
  //     ),
  //   );
  //
  //   // (Opsional) Tambahkan interceptor khusus untuk logging error
  //   dio.interceptors.add(InterceptorsWrapper(
  //     onError: (DioException e, handler) {
  //       if (e.type == DioExceptionType.connectionTimeout ||
  //           e.type == DioExceptionType.receiveTimeout ||
  //           e.type == DioExceptionType.connectionError ||
  //           e.type == DioExceptionType.unknown) {
  //         print("🔵 [API CLIENT] Timeout/Connection Error: ${e.message}");
  //       }
  //       return handler.next(e);
  //     },
  //   ));
  // }

  // ApiClientNetwork SINGLETON
  static final ApiClientNetwork _instance = ApiClientNetwork._internal();
  late Dio dio;

  factory ApiClientNetwork() {
    return _instance;
  }

  ApiClientNetwork._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: UrlApiStatic.API_END_POINT,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    // (Opsional) Interceptor error
    dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown) {
          print("🔵 [API CLIENT] Timeout/Connection Error: ${e.message}");
        }
        return handler.next(e);
      },
    ));
  }
}