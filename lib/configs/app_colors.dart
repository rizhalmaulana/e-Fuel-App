import 'package:flutter/material.dart';

abstract class AppColors {
  // Tema Penerimaan
  static const Color primary = Color(0xFF00553A);
  static const Color secondary = Color(0xFF008859);
  static const Color third = Color(0xFFF1F4FF);

  // Tema Pengeluaran
  static const Color primaryOrange = Color(0xFFE67E22); // Oranye tombol/header
  static const Color secondaryOrange = Color(0xFFEDA160); // Oranye tombol/header
  static const Color textLabel = Color(0xFFE67E22); // Warna label teks

  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFEDEDED);
  static const Color fieldBackground = Color(0xFFF0F3FC);
  static const Color fieldBackgroundDark = Color(0xFFD5D5D5);

  static const Color darkText = Color(0xFF222222);
  static const Color secondaryText = Color(0xFF6A707C);
  static const Color fuelGreen = Color(0xFF4CAF50); // Hijau untuk penerimaan
  static const Color fuelRed = Color(0xFFF44336); // Merah untuk pengeluaran
  static const Color alertSoftRed = Color(0xFFFA6E64); // Merah untuk pengeluaran
  static const Color alertSoftOrange = Color(0xDAFFC693); // Merah untuk pengeluaran
  static const Color alertSoftOrangeSecond = Color(0xDAFFE4C6); // Merah untuk pengeluaran

  static const Color alertSoftPrimary = Color(0xDA93FFAC); // Merah untuk pengeluaran
  static const Color alertSoftPrimarySecond = Color(0xDACCFFD3); // Merah untuk pengeluaran

  static const Color white = Colors.white;
  static const Color orange = Colors.orangeAccent;

  static const Color primaryText = Color(0xFF1A1A1A); // (Contoh: Hitam/Abu tua)
  static const Color black = Color(0xFF000000); // (Contoh: Hitam)
  static const Color info = Color(0xFF4F9DEF); // (Contoh: Biru untuk slogan)
  static const Color error = Color(0xFFDC3545); // (Contoh: Merah untuk error)
  static const Color success = Color(0xFF28A745); // (Contoh: Hijau untuk sukses)

  static const Gradient headerGradient = LinearGradient(
    colors: [Color(0xFF00553A), Color(0xFF65DDB7)], // Contoh Gradien
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}