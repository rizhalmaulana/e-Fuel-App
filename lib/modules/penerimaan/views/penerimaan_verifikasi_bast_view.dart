import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

import '../../../widgets/component/total_volume_card.dart';
import '../controllers/penerimaan_verifikasi_bast_controller.dart';

class PenerimaanVerifikasiBastView extends GetView<PenerimaanVerifikasiBastController> {
  const PenerimaanVerifikasiBastView({super.key});

  // --- WIDGET HELPER BARU: SIGNATURE CARD ---
  Widget _buildSignatureCard({
    required String title,
    required String placeholder,
    required SignatureController signatureController,
    TextEditingController? noteController, // Opsional (Hanya untuk Gudang)
    String noteLabel = "Catatan",
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Judul & Tombol Reset
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.draw_rounded, color: AppColors.primary, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
                ],
              ),
              InkWell(
                onTap: () => signatureController.clear(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.alertSoftRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.refresh, size: 14, color: AppColors.alertSoftRed),
                      const SizedBox(width: 4),
                      Text("Ulangi", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.alertSoftRed)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Input Catatan (Jika ada controller-nya)
          if (noteController != null) ...[
            Text(noteLabel, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 8),
            TextFormField(
              controller: noteController,
              maxLines: 2,
              style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.darkText),
              decoration: InputDecoration(
                hintText: "Tulis catatan disini...",
                hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400),
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
              ),
            ),
            const SizedBox(height: 20),
            Text("Area Tanda Tangan", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
            const SizedBox(height: 8),
          ],

          // Canvas Tanda Tangan
          Container(
            height: 220,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB), // Background abu sangat muda
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Placeholder Text (Tengah)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.grey.shade300, size: 32),
                        const SizedBox(height: 8),
                        Text(
                          placeholder,
                          style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                  // Signature Canvas
                  Signature(
                    controller: signatureController,
                    backgroundColor: Colors.transparent,
                    width: double.infinity,
                    height: 220,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          Center(
            child: Text(
              "Pastikan tanda tangan sesuai dengan identitas.",
              style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(int index) {
    String label = "Pembuatan BAST";
    if (index == 2) label = "Verifikasi Gudang";
    if (index == 3) label = "Verifikasi Supir";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.secondaryText.withOpacity(0.2)), // Border lebih soft
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))
          ]
      ),
      child: Row(
        children: [
          const Icon(Icons.radio_button_checked, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
          ),
        ],
      ),
    );
  }

  // --- STEP 1: PENGECEKAN DATA ---
  Widget _buildStep1Pengecekan(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 20),

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
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildDimensionField("Tinggi (mm)", controller.stdTinggiController, readOnly: true),
              const SizedBox(width: 12),
              _buildDimensionField("Liter", controller.stdLiterController, readOnly: true),
            ],
          ),

          const SizedBox(height: 16),

          // =======================================================
          // SECTION 2: VOLUME DITERIMA (INPUT)
          // =======================================================
          Text("Volume Solar yang Diterima (mm)",
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 8),

          Row(
            children: [
              _buildDimensionField("Tinggi (mm)", controller.actTinggiController, readOnly: false),
              const SizedBox(width: 12),
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

          _buildTextField(
              "Volume Tangki Kebun (Ltr)",
              controller.volumeKebunController,
              readOnly: true
          ),

          _buildTextField(
              "Varian Perhitungan Volume (Ltr)",
              controller.varianController,
              readOnly: true
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- STEP 2: PENGUKURAN ---
  Widget _buildStep2Pengukuran(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 20),

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
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE3E8F0), width: 1.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                ]
            ),
            child: Obx(() {
              final trx = controller.currentTransaction.value;
              final data = trx?.dataSebelum;

              String valNum(double? v, [String suffix = ""]) => (v != null) ? "${v.toStringAsFixed(0)} $suffix" : "-";

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  _buildSummaryRow("No. BAST", trx?.noBast ?? "-"),
                  _buildSummaryRow("Hari, Tanggal", data?.dateInbound ?? "-"),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(height: 1, thickness: 1, color: Color(0xFFE3E8F0)),
                  ),

                  // --- DATA PENGIRIMAN ---
                  _buildSectionTitle("Data Pengiriman"),
                  _buildSummaryRow("No. PO", data?.purchNo ?? "-"),
                  _buildSummaryRow("Jumlah", valNum(data?.volumeVendor, "Ltr")),
                  _buildSummaryRow("Density", valNum(data?.densityVendor)),
                  _buildSummaryRow("Tempr (Obs)", valNum(data?.tempVendor)),

                  const SizedBox(height: 12),

                  // --- UNIT PENGANGKUTAN ---
                  _buildSectionTitle("Unit Pengangkutan"),
                  _buildSummaryRow("No. Polisi", data?.nopolVendor ?? "-"),
                  _buildSummaryRow("Nama Sopir", data?.supirVendor ?? "-"),
                  _buildSummaryRow("Kap. Tangki Angkut (Ltr)", valNum(data?.kapasitasVendor)),

                  const SizedBox(height: 12),

                  // --- PEMERIKSAAN ---
                  _buildSectionTitle("Pemeriksaan"),
                  _buildSummaryRow("Tinggi Terra SPB (mm)", valNum(data?.terraVendor)),
                  _buildSummaryRow("Tinggi Terra Zounding (mm)", valNum(data?.terraCheck)),
                  _buildSummaryRow("Selisih Tinggi Terra (mm)", valNum(data?.terraVar)),
                  _buildSummaryRow("Nilai Kepekaan (mm/Ltr)", data?.tangkiPeka ?? "-"),
                  _buildSummaryRow("Segel Tangki Atas", data?.segelTangkiAtas ?? "-"),
                  _buildSummaryRow("Segel Tangki Bawah", data?.segelTangkiBawah ?? "-"),
                  _buildSummaryRow("Kondisi Segel", data?.segelKondisi ?? "-"),

                  const SizedBox(height: 12),

                  // --- PEMERIKSAAN DAN PENGUKURAN DI TANGKI KEBUN ---
                  _buildSectionTitle("Pemeriksaan di Tangki Kebun"),

                  _buildSummaryRow(
                      "Ukuran Standart Tangki",
                      controller.stdTinggiController.text
                  ),
                  _buildSummaryRow(
                      "Vol. Diterima (Dimensi)",
                      controller.actTinggiController.text
                  ),
                  _buildSummaryRow(
                      "Vol. Diterima (Liter)",
                      controller.volumeDiterimaLtrController.text
                  ),

                  const SizedBox(height: 12),

                  // --- PERHITUNGAN FISIK / VOLUME SOLAR ---
                  _buildSectionTitle("Perhitungan Volume Solar"),

                  _buildSummaryRow("Vol. Tangki Pengirim", "${controller.volumePengirimController.text} Ltr"),
                  _buildSummaryRow("Vol. Tangki Kebun", "${controller.volumeKebunController.text} Ltr"),
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                    child: _buildSummaryRow("Varian Perhitungan", "${controller.varianController.text} Ltr"),
                  ),
                ],
              );
            }),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => controller.previousPage(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE8F1FF),
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
                      elevation: 2,
                      shadowColor: AppColors.primary.withOpacity(0.3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Lanjut", style: AppFonts.fUrbanistSemiBold16.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // --- STEP 3: GUDANG (REVISI DESIGN) ---
  Widget _buildStep3Gudang(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 24),

          _buildSignatureCard(
              title: "Bagian Gudang",
              placeholder: "Tanda Tangan Penerima disini",
              signatureController: controller.signatureGudangController,
              noteController: controller.catatanGudangController, // Ada Catatan
              noteLabel: "Catatan Penerimaan"
          ),

          const SizedBox(height: 80), // Spacer bawah
        ],
      ),
    );
  }

  // --- STEP 4: SUPIR (REVISI DESIGN) ---
  Widget _buildStep4Supir(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          _buildProgressIndicator(controller.currentPage.value),
          const SizedBox(height: 24),

          _buildSignatureCard(
            title: "Supir / Partner",
            placeholder: "Tanda Tangan Pengirim disini",
            signatureController: controller.signatureSupirController,
            // Tidak ada catatan untuk supir
          ),

          const SizedBox(height: 80), // Spacer bawah
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildDimensionField(String label, TextEditingController ctrl, {bool readOnly = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? const Color(0xFFF2F6FF) : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
          Text(label, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText)),
          const SizedBox(height: 6),
          TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            onChanged: onChanged,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              filled: true,
              fillColor: readOnly ? const Color(0xFFF2F6FF) : AppColors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0), width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 6,
            child: Text(
              label,
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
            ),
          ),
          const SizedBox(width: 8),
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
      padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD), // Update background agar card terlihat
      appBar: AppBar(
        title: Text('Verifikasi BAST', style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: const Color(0xFFF8F9FD),
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

          // Tombol Global (Muncul di Step 1, 3, 4)
          // Step 2 sudah punya tombol sendiri
          Obx(() {
            if (controller.currentPage.value == 1) {
              return const SizedBox.shrink();
            }

            return Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 3,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    controller.currentPage.value >= 3 ? 'Submit Verifikasi' : 'Selanjutnya',
                    style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
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