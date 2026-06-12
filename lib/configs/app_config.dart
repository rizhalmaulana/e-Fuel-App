import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static const bool isDevMode = true;
  static const String appName = 'E-Fuel Mobile';

  static String _version = '1.0.0'; // Default fallback

  static Future<void> initVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      _version = packageInfo.version;
    } catch (e) {
      print('Gagal mengambil versi aplikasi: $e');
    }
  }

  static String get versionProd => _version;
  static String get versionDev => isDevMode ? 'Dev $_version' : _version;
}