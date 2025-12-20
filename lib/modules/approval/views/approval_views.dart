import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/approval_controller.dart';

class ApprovalView extends GetView<ApprovalController> {
  const ApprovalView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentPage.value == 0 ? "Detail Dokumen" : "Proses Approval",
          style: AppFonts.fUrbanistBold16.copyWith(color: Colors.black),
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (controller.currentPage.value > 0) {
              controller.prevPage();
            } else {
              Get.back();
            }
          },
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        return PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSummaryStep(),
            _buildActionStep(),
          ],
        );
      }),
    );
  }

  // --- STEP 1: SUMMARY ---
  Widget _buildSummaryStep() {
    final data = controller.detailData;

    String val(dynamic v, [String suffix = ""]) => (v != null) ? "$v $suffix" : "-";
    String valNum(dynamic v, [String suffix = ""]) => (v != null) ? "${double.tryParse(v.toString())?.toStringAsFixed(0) ?? v} $suffix" : "-";

    String catatanKrani = "-";
    String catatanKasie = "-";

    if (data['approvals'] != null) {
      var approvalsList = data['approvals'] as List;
      var kasieData = approvalsList.firstWhere(
            (element) => element['level_approval'] == 'fuel_level_2',
        orElse: () => null,
      );
      var managerData = approvalsList.firstWhere(
            (element) => element['level_approval'] == 'fuel_level_3',
        orElse: () => null,
      );

      if (kasieData != null && kasieData['catatan'] != null && kasieData['catatan'].toString().isNotEmpty) {
        catatanKrani = kasieData['catatan'];
      }

      if (managerData != null && managerData['catatan'] != null && managerData['catatan'].toString().isNotEmpty) {
        catatanKasie = managerData['catatan'];
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8F0), width: 1.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("No. BAST", data['no_doc'] ?? "-"),
                _buildSummaryRow("Hari, Tanggal", data['date_inbound'] ?? "-"),

                const Divider(height: 24, thickness: 1, color: Color(0xFFE3E8F0)),

                _buildSectionTitle("Data Pengiriman"),
                _buildSummaryRow("No. PO", data['no_po'] ?? "-"),
                _buildSummaryRow("Jumlah", valNum(data['volume_vendor'], "Ltr")),
                _buildSummaryRow("Density", valNum(data['density_vendor'])),
                _buildSummaryRow("Tempr (Obs)", valNum(data['temp_vendor'])),

                const SizedBox(height: 8),

                _buildSectionTitle("Unit Pengangkutan"),
                _buildSummaryRow("No. Polisi", data['nopol_vendor'] ?? "-"),
                _buildSummaryRow("Nama Sopir", data['supir_vendor'] ?? "-"),
                _buildSummaryRow("Kap. Tangki Angkut (Ltr)", valNum(data['kapasitas_vendor'])),

                const SizedBox(height: 8),

                _buildSectionTitle("Pemeriksaan"),
                _buildSummaryRow("Tinggi Terra SPB (mm)", valNum(data['terra_vendor'])),
                _buildSummaryRow("Tinggi Terra Zounding (mm)", valNum(data['terra_check'])),
                _buildSummaryRow("Selisih Tinggi Terra (mm)", valNum(data['terra_var'])),
                _buildSummaryRow("Nilai Kepekaan", data['tangki_peka'] ?? "-"),
                _buildSummaryRow("Segel Tangki Atas", data['segel_tangki_atas'] ?? "-"),
                _buildSummaryRow("Segel Tangki Bawah", data['segel_tangki_bawah'] ?? "-"),
                _buildSummaryRow("Kondisi Segel", data['segel_kondisi'] ?? "-"),

                const SizedBox(height: 8),

                if (data['tanks'] != null && (data['tanks'] as List).isNotEmpty)
                  ...List.generate((data['tanks'] as List).length, (index) {
                    var tank = data['tanks'][index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Pemeriksaan Tangki: ${tank['nama_tank'] ?? ''}"),
                        _buildSummaryRow("Ukuran Standart Tangki (mm)", valNum(tank['std_tinggi_tangki_kebun'])),
                        _buildSummaryRow("Volume Diterima (Dimensi)", valNum(tank['std_tinggi_diterima'], "mm")),
                        _buildSummaryRow("Volume Solar Diterima", valNum(tank['volume_solar_diterima'], "Ltr")),

                        const SizedBox(height: 4),
                        Text("Perhitungan Fisik", style: AppFonts.fUrbanistMedium12.copyWith(color: Colors.grey)),
                        const SizedBox(height: 4),

                        _buildSummaryRow("Vol. Tangki Pengirim", valNum(tank['volume_tangki_pengirim'], "Ltr")),
                        _buildSummaryRow("Vol. Tangki Kebun", valNum(tank['volume_solar_diterima'], "Ltr")),
                        _buildSummaryRow("Varian", valNum(tank['var_solar_tangki'], "Ltr")),
                        const Divider(),
                      ],
                    );
                  }),

                const SizedBox(height: 12),
                _buildSectionTitle("Catatan Kasie"),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.fieldBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE3E8F0)),
                  ),
                  child: Text(
                    catatanKrani,
                    style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.darkText),
                  ),
                ),
                // -----------------------------------------------
              ],
            ),
          ),

          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.nextPage(),
              child: Text("Proses Approval", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // --- STEP 2: ACTION ---
  Widget _buildActionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Doc. ${controller.noBast}",
                    style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text("Catatan", style: AppFonts.fUrbanistSemiBold14),
          const SizedBox(height: 8),
          TextField(
            controller: controller.noteController,
            maxLines: 1,
            decoration: InputDecoration(
              hintText: "Masukkan catatan approval/rejection...",
              hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
          ),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan", style: AppFonts.fUrbanistSemiBold14),
              GestureDetector(
                onTap: () => controller.signatureController.clear(),
                child: Text("Hapus", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.alertSoftRed)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE3E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: controller.signatureController,
                backgroundColor: Colors.transparent,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertSoftRed,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.submitDecision('REJECTED'),
                  child: Text("Reject", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => controller.submitDecision('APPROVED'),
                  child: Text("Approve", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
                ),
              ),
            ],
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
              style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary),
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
      child: Text(
        title,
        style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
      ),
    );
  }
}