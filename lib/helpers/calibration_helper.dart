class CalibrationHelper {
  // ===========================================================================
  // 1. DATA TANGKI 10.000 LITER
  // Silakan lengkapi data ini dengan copy-paste dari Excel Anda.
  // Formatnya: {'mm': tinggi_dalam_mm, 'liter': volume_dalam_liter}
  // ===========================================================================
  static final List<Map<String, double>> table10000L = [
    {'mm': 0.0, 'liter': 0.0},
    {'mm': 1.0, 'liter': 2.5},
    {'mm': 2.0, 'liter': 5.1},
    {'mm': 3.0, 'liter': 7.8},
    {'mm': 4.0, 'liter': 10.5},
    {'mm': 5.0, 'liter': 13.4},
    // ... PASTE SEMUA DATA EXCEL 10RB LITER ANDA DI SINI ...
    {'mm': 1657.0, 'liter': 10250.8},
    // {'mm': 1800.0, 'liter': 11300.0}, // (Contoh Baris Terakhir)
  ];

  // ===========================================================================
  // 2. DATA TANGKI 5.000 LITER
  // Silakan lengkapi data ini dengan copy-paste dari Excel Anda.
  // ===========================================================================
  static final List<Map<String, double>> table5000L = [
    {'mm': 0.0, 'liter': 0.0},
    {'mm': 1.0, 'liter': 1.2},
    {'mm': 2.0, 'liter': 2.5},
    {'mm': 3.0, 'liter': 3.9},
    {'mm': 4.0, 'liter': 5.2},
    {'mm': 5.0, 'liter': 6.6},
    // ... PASTE SEMUA DATA EXCEL 5RB LITER ANDA DI SINI ...
    {'mm': 1416.0, 'liter': 5009.9},
  ];

  // ===========================================================================
  // 3. FUNGSI REVERSE LOOKUP (Mencari Tinggi berdasarkan Liter)
  // ===========================================================================
  static double getEstimatedHeight(int capacity, double currentVolume) {
    // Tentukan tabel mana yang akan dibaca berdasarkan kapasitas tangki
    List<Map<String, double>> targetTable = (capacity == 10000) ? table10000L : table5000L;

    // Jika tabel kosong atau error, kembalikan 0
    if (targetTable.isEmpty) return 0.0;

    double closestHeight = 0.0;
    double minDiff = double.maxFinite;

    // Looping untuk mencari volume yang selisihnya paling mendekati target (currentVolume)
    for (var row in targetTable) {
      // Pastikan data tidak null
      if (row['liter'] != null && row['mm'] != null) {
        // Hitung selisih absolut antara volume di tabel dengan volume dari IoT
        double diff = (row['liter']! - currentVolume).abs();

        if (diff < minDiff) {
          minDiff = diff;
          closestHeight = row['mm']!;
        }
      }
    }

    // Mengembalikan tinggi (mm) yang paling mendekati
    return closestHeight;
  }
}