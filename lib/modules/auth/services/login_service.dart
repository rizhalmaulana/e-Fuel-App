import 'package:dio/dio.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:e_fuel/modules/auth/services/login_user_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
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

      final responseData = response.data;

      if (responseData['user'] != null) {
        final userMap = responseData['user'];
        final userKaryawan = userMap['user_karyawan'];
        final List<dynamic> otorisasi = userMap['otorisasi'] ?? [];

        bool isApprover = otorisasi.contains('fuel_level_2') || otorisasi.contains('fuel_level_3');
        if (userKaryawan == null && !isApprover) {
          throw DioCustomException(
            statusCode: 422,
            message: "Akun belum memiliki Data Karyawan (Unit/Jabatan). Silakan hubungi Administrator.",
          );
        }
      }

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

    } on DioCustomException catch (e) {
      rethrow;
    } catch (e) {
      if (e.toString().contains("Null") && e.toString().contains("subtype of type")) {
        throw Exception('Terjadi kesalahan format data akun. Mohon hubungi IT Support.');
      }
      throw Exception('Terjadi kesalahan tak terduga: ${e.toString()}');
    }
  }

  Future<bool> initializeSessionFromHive() async {
    final isLoggedIn = await _loginUserService.checkLoginStatus();
    if (isLoggedIn) {
      _updateBoxReferences();
      try {
        final auth = getCurrentAuth();
        if (auth != null) {
          final username = auth.user.username;
          FirebaseCrashlytics.instance.setUserIdentifier(username);
          FirebaseCrashlytics.instance.setCustomKey('username', username);
        }
      } catch (e) {
        print("Gagal set user identifier di Crashlytics: $e");
      }
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

    try {
      final username = authResponse.user.username;
      FirebaseCrashlytics.instance.setUserIdentifier(username);
      FirebaseCrashlytics.instance.setCustomKey('username', username);
    } catch (e) {
      print("Gagal set user identifier di Crashlytics: $e");
    }

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

    try {
      FirebaseCrashlytics.instance.setUserIdentifier("");
      FirebaseCrashlytics.instance.setCustomKey('username', "");
    } catch (e) {
      print("Gagal clear user identifier di Crashlytics: $e");
    }
  }

  void _updateBoxReferences() {
    _userAuthBox = _loginUserService.userAuthBox;
    _tokenBox = _loginUserService.tokenBox;
    _refreshBox = _loginUserService.refreshBox;

    print('✅ LoginService Box References Updated.');
  }
}