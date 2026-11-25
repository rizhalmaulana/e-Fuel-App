import 'package:flutter/services.dart';

/// Standarisasi input bilangan desimal menggunakan tanda titik (`.`).
/// - Menekan koma (`,`) otomatis dikonversi menjadi titik (`.`).
/// - Hanya menerima digit `0-9` dan maksimal satu titik (`.`).
/// - Mengetik `.` atau `,` di awal otomatis menjadi `0.`.
/// - Posisi kursor tetap terjaga saat mengedit di tengah teks.
class DecimalInputFormatter extends TextInputFormatter {
  final int? maxDecimalPlaces;

  DecimalInputFormatter({this.maxDecimalPlaces});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String newText = newValue.text.replaceAll(',', '.');

    // Jika diawali titik langsung (misal user menekan "." atau "," saat kosong),
    // ubah menjadi "0." agar menjadi desimal yang valid.
    int cursorOffset = newValue.selection.end;
    if (newText.startsWith('.')) {
      newText = '0$newText';
      cursorOffset = cursorOffset + 1;
    }

    // Hanya izinkan angka dan maksimal 1 titik desimal
    if (!RegExp(r'^\d*\.?\d*$').hasMatch(newText)) {
      return oldValue;
    }

    if (maxDecimalPlaces != null && newText.contains('.')) {
      final parts = newText.split('.');
      if (parts.length > 1 && parts[1].length > maxDecimalPlaces!) {
        return oldValue;
      }
    }

    final clampedOffset = cursorOffset.clamp(0, newText.length);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: clampedOffset),
    );
  }

  /// Helper untuk memformat angka desimal secara konsisten menggunakan titik (`.`)
  /// tanpa nol berlebih di belakang koma jika bilangan bulat.
  static String formatDecimal(num value, {int fractionDigits = 2}) {
    final double rounded =
        double.parse(value.toDouble().toStringAsFixed(fractionDigits));
    if (rounded % 1 == 0) {
      return rounded.toInt().toString();
    }
    return rounded.toStringAsFixed(fractionDigits);
  }
}
