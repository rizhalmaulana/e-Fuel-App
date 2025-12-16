import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class SeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {

    // 1. Handle kosong
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // 2. Jika user baru mengetik koma di akhir (contoh: "1.200,"), biarkan saja dulu
    if (newValue.text.endsWith(',')) {
      return newValue;
    }

    // 3. Bersihkan format (Hapus titik, biarkan koma untuk desimal)
    String cleanedText = newValue.text.replaceAll('.', '');

    // Cek apakah input valid angka (boleh ada 1 koma)
    // Ganti koma jadi titik untuk validasi double Dart
    if (double.tryParse(cleanedText.replaceAll(',', '.')) == null) {
      return oldValue; // Jika tidak valid, revert ke input lama
    }

    // 4. Pisahkan Angka Bulat dan Desimal
    List<String> parts = cleanedText.split(',');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // 5. Format bagian Integer (Ribuan)
    final formatter = NumberFormat('#,###', 'id_ID');
    // Handle integerPart kosong (misal user ketik ",5") -> jadi "0"
    if (integerPart.isEmpty) integerPart = "0";

    String formattedInteger = formatter.format(int.parse(integerPart));

    // 6. Gabungkan kembali
    String newString = formattedInteger;
    if (cleanedText.contains(',')) {
      newString += ',${decimalPart ?? ""}';
    }

    // 7. Hitung posisi kursor (Smart Cursor) agar tidak loncat
    int selectionIndex = newString.length - (newValue.text.length - newValue.selection.end);

    return TextEditingValue(
      text: newString,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, newString.length),
      ),
    );
  }
}