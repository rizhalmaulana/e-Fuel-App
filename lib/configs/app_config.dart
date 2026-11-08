import 'package:package_info_plus/package_info_plus.dart';

/// Enum untuk mendefinisikan environment aplikasi
enum EnvironmentType {
  prod,
  dev,
  lokal,
}

class AppConfig {
  /// Ubah environment aktif di sini (Single Source of Truth).
  /// Pilih salah satu:
  /// - EnvironmentType.prod  : Server Production Teladan Prima
  /// - EnvironmentType.dev   : Server Development (192.168.1.39)
  /// - EnvironmentType.lokal : Server Lokal PC Pengembang (192.168.137.1)
  static const EnvironmentType currentEnv = EnvironmentType.lokal;

  static const String appName = 'E-Fuel Mobile';
  static String _version = '1.1.0+3'; // Fallback default jika PackageInfo belum selesai/gagal dimuat

  /// Mengambil versi aplikasi dan build number secara dinamis langsung dari pubspec.yaml
  static Future<void> initVersion() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String version = packageInfo.version;
      final String buildNumber = packageInfo.buildNumber;

      if (buildNumber.isNotEmpty) {
        _version = '$version+$buildNumber';
      } else {
        _version = version;
      }
    } catch (e) {
      print('Gagal mengambil versi aplikasi: $e');
    }
  }

  /// URL Base API berdasarkan Environment yang aktif
  static String get baseUrl {
    switch (currentEnv) {
      case EnvironmentType.prod:
        return 'https://digilink.teladanprima.com/api';
      case EnvironmentType.dev:
        return 'http://192.168.1.39:8000/api';
      case EnvironmentType.lokal:
        return 'http://192.168.137.1:8000/api';
    }
  }

  /// Pengecekan Environment
  static bool get isProd => currentEnv == EnvironmentType.prod;
  static bool get isDev => currentEnv == EnvironmentType.dev;
  static bool get isLokal => currentEnv == EnvironmentType.lokal;

  /// Mode pengembangan: bernilai true jika bukan production (misal untuk Hive dev box dsb.)
  static bool get isDevMode => currentEnv != EnvironmentType.prod;

  /// Label Environment untuk tampilan UI atau debugging
  static String get envLabel {
    switch (currentEnv) {
      case EnvironmentType.prod:
        return 'PROD';
      case EnvironmentType.dev:
        return 'DEV';
      case EnvironmentType.lokal:
        return 'LOKAL';
    }
  }

  /// Versi murni (contoh: "1.1.0+3") untuk payload backend / integrasi API
  static String get version => _version;
  static String get versionProd => _version;

  /// Versi dengan label Environment untuk tampilan UI (Splash Screen, Profil, dll.)
  /// - Jika PROD: "1.1.0+3"
  /// - Jika DEV: "1.1.0+3 (DEV)"
  /// - Jika LOKAL: "1.1.0+3 (LOKAL)"
  static String get displayVersion {
    if (isProd) {
      return _version;
    }
    return '$_version ($envLabel)';
  }

  static String get versionDev => displayVersion;
}
