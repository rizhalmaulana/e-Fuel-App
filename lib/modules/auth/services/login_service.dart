import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:e_fuel/modules/auth/services/login_user_service.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

import '../../../datas/models/auth/auth_response_model.dart';

class DioCustomException implements Exception {
  final int? statusCode;
  final String message;

  DioCustomException({this.statusCode, required this.message});

  @override
  String toString() => 'Exception: $message';
}

class LoginService extends GetxService {
  Box<AuthResponseModel>? _userAuthBox;
  Box<String>? _tokenBox;
  Box<String>? _refreshBox;

  late final LoginUserService _loginUserService = Get.find<LoginUserService>();
  final Dio _dio = Dio();

  LoginService() {
    _dio.options.baseUrl = UrlApiStatic.API_END_POINT;
  }

  String? get accessToken => _tokenBox?.get(ValueKeyStatic.TOKEN_ACCESS_KEY);
  String? get refreshToken => _refreshBox?.get(ValueKeyStatic.TOKEN_REFRESH_KEY);

  Future<AuthResponseModel> login(String username, String password) async {
    try {
      final response = await _dio.post(
        UrlApiStatic.API_PAIR_AUTH,
        data: {
          'username': username,
          'password': password,
        },
      );

      final authResponse = AuthResponseModel.fromJson(response.data);
      await _loginUserService.openUserBoxes(username);

      _userAuthBox = _loginUserService.userAuthBox;
      _tokenBox = _loginUserService.tokenBox;
      _refreshBox = _loginUserService.refreshBox;

      _updateBoxReferences();

      await _saveAuthToHive(authResponse);
      await _loginUserService.saveActiveUsername(username);

      return authResponse;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;

      String serverMessage = 'Terjadi kesalahan jaringan atau koneksi.';
      if (e.response?.data != null && e.response!.data is Map) {
        serverMessage = e.response!.data['detail'] ??
            e.response!.data['message'] ??
            serverMessage;
      }

      throw DioCustomException(statusCode: statusCode, message: serverMessage);

    } catch (e) {
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  Future<bool> initializeSessionFromHive() async {
    final isLoggedIn = await _loginUserService.checkLoginStatus();
    if (isLoggedIn) {
      _updateBoxReferences();
    }
    return isLoggedIn;
  }

  AuthResponseModel? getCurrentAuth() {
    if (_userAuthBox == null) {
      _updateBoxReferences();
    }
    return _userAuthBox?.get(ValueKeyStatic.AUTH_DATA_KEY);
  }

  Future<AuthResponseModel?> getAuthOrLoad() async {
    // 1. Cek Memory
    var auth = getCurrentAuth();
    if (auth != null) return auth;

    // 2. Jika null, coba load dari Hive
    final success = await initializeSessionFromHive();
    if (success) {
      return getCurrentAuth();
    }

    // 3. Jika gagal load (user belum login), return null
    return null;
  }

  Future<void> _saveAuthToHive(AuthResponseModel authResponse) async {
    if (_userAuthBox == null || _tokenBox == null || _refreshBox == null) {
      throw Exception('Hive Boxes belum terbuka. Harap login terlebih dahulu.');
    }

    await _userAuthBox?.clear();
    await _userAuthBox?.put(ValueKeyStatic.AUTH_DATA_KEY, authResponse);

    await _tokenBox!.clear();
    if (authResponse.access.isNotEmpty) {
      await _tokenBox!.put(ValueKeyStatic.TOKEN_ACCESS_KEY, authResponse.access);
    }

    await _refreshBox!.clear();
    if (authResponse.refresh.isNotEmpty) {
      await _refreshBox!.put(ValueKeyStatic.TOKEN_REFRESH_KEY, authResponse.refresh);
    }
  }

  Future<void> clearAuthData() async {
    print('Auth - LocalService: clearing auth data');

    await _userAuthBox?.clear();
    await _tokenBox?.clear();

    _userAuthBox = null;
    _tokenBox = null;
  }

  void _updateBoxReferences() {
    _userAuthBox = _loginUserService.userAuthBox;
    _tokenBox = _loginUserService.tokenBox;
    _refreshBox = _loginUserService.refreshBox;

    print('✅ LoginService Box References Updated.');
  }
}