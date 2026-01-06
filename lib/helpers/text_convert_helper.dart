import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class TextConvertHelper {
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

  double parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value.replaceAll(',', '.')) ?? 0.0;
    }
    return 0.0;
  }

  String handleApiError(dynamic e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        return "Koneksi terputus. Pastikan internet Anda stabil dan coba lagi.";
      }

      // B. Error Response dari Server (Punya Status Code)
      if (e.response != null) {
        int? statusCode = e.response?.statusCode;

        switch (statusCode) {
          case 400:
            return "[$statusCode] Permintaan tidak dapat diproses. Mohon periksa kembali data inputan Anda.";
          case 401:
            return "[$statusCode] Sesi login Anda telah berakhir. Silakan logout dan login kembali.";
          case 403:
            return "[$statusCode] Akses ditolak. Anda tidak memiliki izin untuk melakukan proses ini.";
          case 404:
            return "[$statusCode] Layanan atau data tidak ditemukan di server.";
          case 405:
            return "[$statusCode] Metode akses tidak diizinkan oleh server.";
          case 408:
            return "[$statusCode] Waktu permintaan habis. Server terlalu sibuk, silakan coba lagi.";
          case 413:
            return "[$statusCode] Ukuran data/foto terlalu besar. Mohon kurangi ukuran foto.";
          case 422:
            return "[$statusCode] Validasi data gagal. Pastikan semua kolom wajib telah terisi dengan benar.";
          case 429:
            return "[$statusCode] Terlalu banyak permintaan dalam waktu singkat. Mohon tunggu sebentar.";
          case 500:
            return "[$statusCode] Terjadi gangguan internal pada server pusat. Silakan hubungi IT Support.";
          case 502:
          case 503:
          case 504:
            return "[$statusCode] Server sedang dalam perbaikan atau tidak dapat diakses (Gateway Error).";
          default:
            return "[$statusCode] Terjadi kendala saat memproses data (Kode: $statusCode).";
        }
      }
    }

    return "Terjadi kesalahan pada aplikasi. Silakan coba lagi.";
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
