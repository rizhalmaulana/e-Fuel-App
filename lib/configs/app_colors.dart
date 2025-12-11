import 'package:flutter/material.dart';

// Gunakan 'abstract class' dengan 'const' statis
// agar tidak ada yang bisa meng-instansiasi class ini.
abstract class AppColors {
  static const Color primary = Color(0xFF1F41BB);
  static const Color secondary = Color(0xFF478AC6);
  static const Color third = Color(0xFFF1F4FF);

  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundGrey = Color(0xFFEDEDED);
  static const Color fieldBackground = Color(0xFFF0F3FC);

  static const Color darkText = Color(0xFF333333);
  static const Color secondaryText = Color(0xFF6A707C);
  static const Color fuelGreen = Color(0xFF4CAF50); // Hijau untuk penerimaan
  static const Color fuelRed = Color(0xFFF44336); // Merah untuk pengeluaran
  static const Color alertSoftRed = Color(0xFFFA6E64); // Merah untuk pengeluaran
  static const Color white = Colors.white;
  static const Color orange = Colors.orangeAccent;

  static const Color primaryText = Color(0xFF1A1A1A); // (Contoh: Hitam/Abu tua)
  static const Color info = Color(0xFF007BFF); // (Contoh: Biru untuk slogan)
  static const Color error = Color(0xFFDC3545); // (Contoh: Merah untuk error)
  static const Color success = Color(0xFF28A745); // (Contoh: Hijau untuk sukses)

  static const Gradient headerGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF94A9FF)], // Contoh Gradien
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}