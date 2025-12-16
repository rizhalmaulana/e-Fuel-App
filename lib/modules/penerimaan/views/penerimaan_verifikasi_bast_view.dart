import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../widgets/component/total_volume_card.dart';
import '../controllers/penerimaan_verifikasi_bast_controller.dart';

class PenerimaanVerifikasiBastView extends GetView<PenerimaanVerifikasiBastController> {
  const PenerimaanVerifikasiBastView({super.key});

  Widget _buildProgressIndicator(int index) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondaryText),
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            'Pembuatan BAST',
            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: PENGECEKAN DATA ---
  Widget _buildStep1Pengecekan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 16),

          // 1. HEADER CARD (Total Volume)
          Obx(() => TotalVolumeCard(
            totalVolume: controller.totalVolumeDisplay.value.toStringAsFixed(0),
            tankList: controller.tankListDisplay,
            storageLocations: [controller.selectedStorage.value],
            selectedStorage: controller.selectedStorage.value,
            onStorageChanged: (val) {},
            showDropdown: false,
            showTotalVolume: true,
          )),

          const SizedBox(height: 24),

          // [TITLE]
          Text("Pemeriksaan dan Pengukuran di Tangki Kebun",
              style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),

          const SizedBox(height: 16),

          // =======================================================
          // SECTION 1: UKURAN STANDAR (READONLY)
          // =======================================================
          Text("Ukuran Standar Tangki Kebun 10.000 Ltr",
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),

          Row(
            children: [
              // Tinggi Fix 1605
              _buildDimensionField("Tinggi (mm)", controller.stdTinggiController, readOnly: true),
              const SizedBox(width: 12),
              // Liter Hasil API
              _buildDimensionField("Liter", controller.stdLiterController, readOnly: true),
            ],
          ),

          const SizedBox(height: 16),

          // =======================================================
          // [UPDATED UI] SECTION 2: VOLUME DITERIMA (INPUT)
          // =======================================================
          Text("Volume Solar yang Diterima (mm)",
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),

          Row(
            children: [
              // User Input Tinggi Disini
              _buildDimensionField("Tinggi (mm)", controller.actTinggiController, readOnly: false),
              const SizedBox(width: 12),
              // Liter Hasil Hitung API (Readonly)
              _buildDimensionField("Liter", controller.volumeDiterimaLtrController, readOnly: true),
            ],
          ),

          const SizedBox(height: 24),

          // =======================================================
          // SECTION 3: PERBANDINGAN VOLUME (VARIAN)
          // =======================================================
          Text("Volume Tangki Kendaraan vs Tangki Kebun",
              style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
          const SizedBox(height: 16),

          _buildTextField(
              "Volume Tangki Pengirim (Ltr)",
              controller.volumePengirimController,
              onChanged: (val) => controller.hitungVarian()
          ),

          // Auto Fill dari hasil hitung Liter Aktual diatas
          _buildTextField(
              "Volume Tangki Kebun (Ltr)",
              controller.volumeKebunController,
              readOnly: true
          ),

          _buildTextField(
              "Varian Perhitungan Volume (Ltr)",
              controller.varianController,
              readOnly: true // Auto Calc
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- STEP 2: PENGUKURAN ---
  Widget _buildStep2Pengukuran(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 16),

          // 1. TOTAL VOLUME CARD
          Obx(() => TotalVolumeCard(
            totalVolume: controller.totalVolumeDisplay.value.toStringAsFixed(0),
            tankList: controller.tankListDisplay,
            storageLocations: [controller.selectedStorage.value],
            selectedStorage: controller.selectedStorage.value,
            onStorageChanged: (val) {},
            showDropdown: false,
            showTotalVolume: true,
          )),

          const SizedBox(height: 24),

          // WRAPPER CONTAINER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8F0), width: 1.0),
            ),
            child: Obx(() {
              final trx = controller.currentTransaction.value;
              final data = trx?.dataSebelum;

              // Helper format null safety
              String val(dynamic v, [String suffix = ""]) => (v != null) ? "$v $suffix" : "-";
              String valNum(double? v, [String suffix = ""]) => (v != null) ? "${v.toStringAsFixed(0)} $suffix" : "-";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildSummaryRow("No. BAST", trx?.noBast ?? "-"), // Header ada di trx
                  _buildSummaryRow("Hari, Tanggal", data?.dateInbound ?? "-"),

                  const Divider(height: 24, thickness: 1, color: Color(0xFFE3E8F0)),

                  // --- DATA PENGIRIMAN ---
                  _buildSectionTitle("Data Pengiriman"),
                  _buildSummaryRow("No. PO", data?.purchNo ?? "-"),
                  _buildSummaryRow("Jumlah", valNum(data?.volumeVendor, "Ltr")),
                  _buildSummaryRow("Density", valNum(data?.densityVendor)),
                  _buildSummaryRow("Tempr (Obs)", valNum(data?.tempVendor)),

                  const SizedBox(height: 8),

                  // --- UNIT PENGANGKUTAN ---
                  _buildSectionTitle("Unit Pengangkutan"),
                  _buildSummaryRow("No. Polisi", data?.nopolVendor ?? "-"),
                  _buildSummaryRow("Nama Sopir", data?.supirVendor ?? "-"),
                  _buildSummaryRow("Kap. Tangki Angkut (Ltr)", valNum(data?.kapasitasVendor)),

                  const SizedBox(height: 8),

                  // --- PEMERIKSAAN ---
                  _buildSectionTitle("Pemeriksaan"),
                  _buildSummaryRow("Tinggi Terra SPB (mm)", valNum(data?.terraVendor)),
                  _buildSummaryRow("Tinggi Terra Zounding (mm)", valNum(data?.terraCheck)),
                  _buildSummaryRow("Selisih Tinggi Terra (mm)", valNum(data?.terraVar)),
                  _buildSummaryRow("Nilai Kepekaan (mm/Ltr)", data?.tangkiPeka ?? "-"),
                  _buildSummaryRow("Segel Tangki Atas", data?.segelTangkiAtas ?? "-"),
                  _buildSummaryRow("Segel Tangki Bawah", data?.segelTangkiBawah ?? "-"),
                  _buildSummaryRow("Kondisi Segel", data?.segelKondisi ?? "-"),

                  const SizedBox(height: 8),

                  // --- PEMERIKSAAN DAN PENGUKURAN DI TANGKI KEBUN ---
                  _buildSectionTitle("Pemeriksaan dan Pengukuran di Tangki Kebun"),

                  _buildSummaryRow(
                      "Ukuran Standart Tangki Kebun (mm)",
                      controller.stdTinggiController.text
                  ),
                  _buildSummaryRow(
                      "Volume Solar yang Diterima (Dimensi)",
                      controller.actTinggiController.text
                  ),
                  _buildSummaryRow(
                      "Volume Solar yang Diterima",
                      controller.volumeDiterimaLtrController.text
                  ),

                  const SizedBox(height: 8),

                  // --- PERHITUNGAN FISIK / VOLUME SOLAR ---
                  _buildSectionTitle("Perhitungan Fisik/Volume Solar"),

                  _buildSummaryRow("Volume Tangki Pengirim (Ltr)", controller.volumePengirimController.text),
                  _buildSummaryRow("Volume Tangki Kebun (Ltr)", controller.volumeKebunController.text),
                  _buildSummaryRow("Varian Perhitungan Volume (Ltr)", controller.varianController.text),
                ],
              );
            }),
          ),

          const SizedBox(height: 32),

          // --- TOMBOL EDIT & NEXT ---
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.previousPage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6DFFF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Edit", style: AppFonts.fUrbanistSemiBold16.copyWith(color: AppColors.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Lanjut", style: AppFonts.fUrbanistSemiBold16.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- STEP 3: GUDANG ---
  Widget _buildStep3Gudang(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 16),

          Align(alignment: Alignment.centerLeft, child: Text("Catatan", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText))),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.catatanGudangController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Catatan Bagian Gudang",
              hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
            ),
          ),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText)),
              GestureDetector(
                onTap: () => controller.signatureGudangController.clear(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("Reset", style: AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.red)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(child: Text("Tanda tangan Bagian Gudang", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText.withOpacity(0.5)))),
                  Signature(
                    controller: controller.signatureGudangController,
                    backgroundColor: Colors.transparent,
                    width: double.infinity,
                    height: 200,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- STEP 4: SUPIR ---
  Widget _buildStep4Supir(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText)),
              GestureDetector(
                onTap: () => controller.signatureSupirController.clear(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("Reset", style: AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.red)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Container(
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(child: Text("Tanda tangan Supir", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText.withOpacity(0.5)))),
                  Signature(
                    controller: controller.signatureSupirController,
                    backgroundColor: Colors.transparent,
                    width: double.infinity,
                    height: 400,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey)),
        Text(value, style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText)),
      ],
    );
  }

  Widget _buildDimensionField(String label, TextEditingController ctrl, {bool readOnly = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF2F6FF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
          )
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, {bool readOnly = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF2F6FF),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              // BORDER CONFIGURATION
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0), // Jarak antar baris text
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label (Kiri)
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary),
            ),
          ),
          const SizedBox(width: 8),
          // Value (Kanan)
          Expanded(
            flex: 4,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Verifikasi BAST', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
          onPressed: () => controller.previousPage(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: controller.onPageChanged,
              children: [
                _buildStep1Pengecekan(context),
                _buildStep2Pengukuran(context),
                _buildStep3Gudang(context),
                _buildStep4Supir(context),
              ],
            ),
          ),

          // Sembunyikan tombol global jika sedang di Step 2
          Obx(() {
            if (controller.currentPage.value == 1) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    controller.currentPage.value >= 3 ? 'Submit' : 'Lanjut',
                    style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.white),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}