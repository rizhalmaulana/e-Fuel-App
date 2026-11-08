import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../configs/app_colors.dart';

class NetworkErrorHelper {
  /// Mengubah berbagai jenis Exception / Error (DioException, SocketException, TimeoutException, dll)
  /// menjadi pesan Bahasa Indonesia yang ramah, santun, dan mudah dipahami pengguna (UX-friendly),
  /// tanpa menampilkan istilah teknis atau kode error yang membingungkan.
  static String getFriendlyErrorMessage(dynamic error) {
    if (error == null) {
      return "Terjadi kendala saat memproses data. Silakan coba beberapa saat lagi.";
    }

    // 1. Handling DioException
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return "Waktu koneksi habis. Sinyal internet tidak stabil atau lambat. Silakan periksa jaringan dan coba lagi.";
        case DioExceptionType.sendTimeout:
          return "Waktu pengiriman data habis. Koneksi internet terlalu lambat untuk mengunggah data. Silakan coba kembali.";
        case DioExceptionType.receiveTimeout:
          return "Waktu menunggu respon server habis. Server sedang sibuk, mohon coba beberapa saat lagi.";
        case DioExceptionType.connectionError:
          return "Tidak dapat terhubung ke server. Pastikan perangkat Anda memiliki sambungan internet yang aktif.";
        case DioExceptionType.cancel:
          return "Permintaan transaksi telah dibatalkan.";
        case DioExceptionType.badCertificate:
          return "Koneksi keamanan server tidak valid. Silakan hubungi tim administrator.";
        case DioExceptionType.badResponse:
          final response = error.response;
          if (response != null) {
            final statusCode = response.statusCode;

            // Periksa jika server mengembalikan pesan error yang ramah pengguna
            String? serverMessage;
            try {
              if (response.data is Map) {
                final data = response.data as Map;
                serverMessage = data['message'] ?? data['detail'] ?? data['error'];
              }
            } catch (_) {}

            if (serverMessage != null &&
                serverMessage.isNotEmpty &&
                !serverMessage.toLowerCase().contains("html") &&
                !serverMessage.toLowerCase().contains("exception") &&
                !serverMessage.toLowerCase().contains("sql") &&
                !serverMessage.toLowerCase().contains("stacktrace") &&
                !serverMessage.toLowerCase().contains("internal server error")) {
              return serverMessage;
            }

            switch (statusCode) {
              case 400:
                return "Permintaan tidak dapat diproses. Mohon periksa kembali data yang dimasukkan.";
              case 401:
                return "Sesi Anda telah berakhir. Silakan masuk kembali ke aplikasi.";
              case 403:
                return "Anda tidak memiliki izin akses untuk melakukan tindakan ini.";
              case 404:
                return "Layanan atau data yang diminta tidak ditemukan di server.";
              case 408:
                return "Waktu permintaan habis. Silakan coba beberapa saat lagi.";
              case 413:
                return "Ukuran file foto terlalu besar. Mohon ambil ulang foto atau kurangi ukuran file.";
              case 422:
                return "Data yang dikirimkan belum lengkap atau tidak sesuai. Mohon periksa kembali formulir Anda.";
              case 500:
              case 502:
              case 503:
              case 504:
                return "Layanan server sedang mengalami kendala atau dalam pemeliharaan. Silakan coba kembali nanti.";
              default:
                return "Gagal memproses data pada server (Status: $statusCode). Silakan coba lagi.";
            }
          }
          return "Respon yang diterima dari server tidak sesuai. Silakan coba lagi.";
        case DioExceptionType.unknown:
          final inner = error.error;
          if (inner is SocketException) {
            return _handleSocketException(inner);
          } else if (inner is TimeoutException) {
            return "Waktu koneksi habis. Mohon pastikan sinyal internet stabil dan coba kembali.";
          }
          final msg = error.message?.toLowerCase() ?? "";
          if (msg.contains("socketexception") ||
              msg.contains("connection refused") ||
              msg.contains("network is unreachable") ||
              msg.contains("failed host lookup")) {
            return "Tidak ada koneksi internet. Pastikan jaringan internet perangkat Anda aktif.";
          }
          return "Terjadi kendala saat menghubungkan ke server. Silakan coba beberapa saat lagi.";
      }
    }

    // 2. Handling SocketException
    if (error is SocketException) {
      return _handleSocketException(error);
    }

    // 3. Handling TimeoutException
    if (error is TimeoutException) {
      return "Waktu koneksi habis. Mohon pastikan sinyal internet stabil dan coba kembali.";
    }

    // 4. Handling String / Exception umum
    String rawMsg = error.toString().replaceAll(RegExp(r'^(Exception:|Error:)\s*'), '').trim();

    // Saring istilah teknis
    final lower = rawMsg.toLowerCase();
    if (lower.contains("socketexception") ||
        lower.contains("connection refused") ||
        lower.contains("failed host lookup") ||
        lower.contains("network is unreachable") ||
        lower.contains("clientexception")) {
      return "Tidak dapat terhubung ke server. Pastikan perangkat Anda terhubung ke internet.";
    }
    if (lower.contains("timeout") || lower.contains("time out") || lower.contains("rto")) {
      return "Waktu permintaan habis. Pastikan koneksi internet stabil dan coba lagi.";
    }
    if (lower.contains("handshakeexception") || lower.contains("certificate")) {
      return "Koneksi keamanan ke server terganggu. Silakan hubungi administrator.";
    }
    if (lower.contains("null check") || lower.contains("nosuchmethoderror")) {
      return "Terjadi kendala saat memproses data pada aplikasi. Silakan coba lagi.";
    }

    // Jika pesan sudah ramah pengguna dan tidak terlalu panjang
    if (rawMsg.isNotEmpty && rawMsg.length < 150) {
      return rawMsg;
    }

    return "Terjadi kendala saat memproses data. Silakan coba beberapa saat lagi.";
  }

  static String _handleSocketException(SocketException e) {
    final msg = e.message.toLowerCase();
    final osMsg = e.osError?.message.toLowerCase() ?? "";
    if (msg.contains("network is unreachable") || osMsg.contains("network is unreachable")) {
      return "Perangkat Anda tidak terhubung ke jaringan internet.";
    }
    if (msg.contains("connection refused") || osMsg.contains("connection refused")) {
      return "Server tidak dapat dijangkau. Silakan hubungi admin atau coba lagi nanti.";
    }
    return "Tidak dapat terhubung ke server. Pastikan internet Anda aktif dan stabil.";
  }

  /// Menampilkan Snackbar notifikasi error yang rapi, informatif, dan UX-friendly.
  static void showErrorSnackbar({
    String title = "Perhatian",
    required dynamic error,
    Duration duration = const Duration(seconds: 4),
    SnackPosition position = SnackPosition.TOP,
  }) {
    final message = getFriendlyErrorMessage(error);

    // Hindari duplikasi snackbar jika sedang aktif
    if (Get.isSnackbarOpen == true) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.alertSoftRed,
      colorText: Colors.white,
      snackPosition: position,
      duration: duration,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
      shouldIconPulse: true,
    );
  }
}

