import 'package:e_fuel/configs/app_config.dart';
import 'package:e_fuel/datas/models/auth/auth_response_model.dart';
import 'package:e_fuel/datas/models/user/user_model.dart';
import 'package:hive/hive.dart';
import '../../../datas/constant/value_key_static.dart';

class LoginUserService {
  Box<AuthResponseModel>? _userAuthBox;
  Box<String>? _tokenBox;
  Box<String>? _refreshBox;
  Box<String>? _statusBox;

  Box<AuthResponseModel>? get userAuthBox => _userAuthBox;
  Box<String>? get tokenBox => _tokenBox;
  Box<String>? get refreshBox => _refreshBox;

  Future<void> _openStatusBox() async {
    final statusBoxName = ValueKeyStatic.APP_STATUS_BOX;
    if (!Hive.isBoxOpen(statusBoxName)) {
      _statusBox = await Hive.openBox<String>(statusBoxName);
    } else {
      _statusBox = Hive.box<String>(statusBoxName);
    }
  }

  Future<bool> checkLoginStatus() async {
    await _openStatusBox();

    String? activeUsername = _statusBox!.get(ValueKeyStatic.ACTIVE_USERNAME_KEY);
    if (activeUsername == null || activeUsername.isEmpty) {
      print('Hive Auth Status: No active username found.');
      return false;
    }

    try {
      await openUserBoxes(activeUsername);
      final isLoggedIn = _userAuthBox?.get(ValueKeyStatic.AUTH_DATA_KEY)?.user.username.isNotEmpty ?? false;

      if (isLoggedIn) {
        print('Hive Auth Status: Logged in as $activeUsername');
        return true;
      } else {
        await _statusBox!.delete(ValueKeyStatic.ACTIVE_USERNAME_KEY);
        print('Hive Auth Status: Active user found, but data is missing. Deleting status.');
        return false;
      }
    } catch (e) {
      print('Error in checkLoginStatus: $e');
      return false;
    }
  }

  Future<void> openUserBoxes(String username) async {
    final userBoxName = AppConfig.isDevMode
        ? '${ValueKeyStatic.USER_BOX_DEV}_$username'
        : '${ValueKeyStatic.USER_BOX}_$username';

    final tokenBoxName = ValueKeyStatic.TOKEN_ACCESS_KEY;
    final refreshBoxName = ValueKeyStatic.TOKEN_REFRESH_KEY;

    if (!Hive.isBoxOpen(userBoxName)) {
      _userAuthBox = await Hive.openBox<AuthResponseModel>(userBoxName);
      print('✅ Box Hive User/Auth dibuka per akun untuk: $username di $userBoxName');
    } else {
      _userAuthBox = Hive.box<AuthResponseModel>(userBoxName);
    }

    // Buka Box Token
    if (!Hive.isBoxOpen(tokenBoxName)) {
      _tokenBox = await Hive.openBox<String>(tokenBoxName);
      print('✅ Box Hive Token dibuka per akun untuk: $username di $tokenBoxName');
    } else {
      _tokenBox = Hive.box<String>(tokenBoxName);
    }

    // Buka Box Refresh Token
    if (!Hive.isBoxOpen(refreshBoxName)) {
      _refreshBox = await Hive.openBox<String>(refreshBoxName);
      print('✅ Box Hive Refresh dibuka per akun untuk: $username di $refreshBoxName');
    } else {
      _refreshBox = Hive.box<String>(refreshBoxName);
    }
  }

  Future<void> saveActiveUsername(String username) async {
    await _openStatusBox();
    await _statusBox!.put(ValueKeyStatic.ACTIVE_USERNAME_KEY, username);
    print('✅ Auth Status: Saved active username: $username');
  }
}