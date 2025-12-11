import 'package:flutter/services.dart';

class FileSaverHelper {
  static const MethodChannel _channel = MethodChannel('nfc_settings');/// Menyimpan string [jsonData] sebagai file dengan nama [fileName].

  static Future<String?>saveJsonFile({
    required String jsonData,
    required String fileName,
  }) async {
    try {
      final String? filePath = await _channel.invokeMethod('saveJsonFile', {
        'fileName': fileName,
        'jsonData': jsonData,
      });

      if (filePath != null) {
        print('File berhasil disimpan di: $filePath');
        return filePath;
      } else {
        print('Penyimpanan file dibatalkan oleh pengguna.');
        return null;
      }
    } on PlatformException catch(e) {
      print('Gagal menyimpan file: ${e.message}');
      rethrow;
    }
  }
}