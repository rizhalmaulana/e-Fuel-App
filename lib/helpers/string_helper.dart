import 'package:intl/intl.dart';

class StringHelper {
  String getDayName(int day) {
    switch (day) {
      case 1: return 'Senin';
      case 2: return 'Selasa';
      case 3: return 'Rabu';
      case 4: return 'Kamis';
      case 5: return 'Jumat';
      case 6: return 'Sabtu';
      case 7: return 'Minggu';
      default: return '';
    }
  }

  String formatNumber(double value) {
    final formatter = NumberFormat("#,##0", "id_ID");
    return formatter.format(value).replaceAll(',', '.');
  }

  String cleanNumber(String value) {
    if (value.isEmpty) return "0";
    return value.replaceAll('.', '');
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "-";
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }
}