import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/approval_controller.dart';

class ApprovalView extends GetView<ApprovalController> {
  const ApprovalView({super.key});

  // --- STEP 1: SUMMARY ---
  Widget _buildSummaryStep() {
    final data = controller.detailData;

    String val(dynamic v, [String suffix = ""]) => (v != null) ? "$v $suffix" : "-";
    String valNum(dynamic v, [String suffix = ""]) => (v != null) ? "${double.tryParse(v.toString())?.toStringAsFixed(0) ?? v} $suffix" : "-";

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0), // OPTIMASI: Padding dalam dari 16 ke 12
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

                const Divider(height: 20, thickness: 1, color: Color(0xFFE3E8F0)),

                _buildSectionTitle("Data Pengiriman"),
                _buildSummaryRow("No. PO", data['no_po'] ?? "-"),
                _buildSummaryRow("Jumlah", valNum(data['volume_vendor'], "Ltr")),
                _buildSummaryRow("Density", valNum(data['density_vendor'])),
                _buildSummaryRow("Tempr (Obs)", valNum(data['temp_vendor'])),

                const SizedBox(height: 4),

                _buildSectionTitle("Unit Pengangkutan"),
                _buildSummaryRow("No. Polisi", data['nopol_vendor'] ?? "-"),
                _buildSummaryRow("Nama Sopir", data['supir_vendor'] ?? "-"),
                _buildSummaryRow("Kap. Tangki Angkut (Ltr)", valNum(data['kapasitas_vendor'])),

                const SizedBox(height: 4),

                _buildSectionTitle("Pemeriksaan"),
                _buildSummaryRow("Tinggi Terra SPB (mm)", valNum(data['terra_vendor'])),
                _buildSummaryRow("Tinggi Terra Zounding (mm)", valNum(data['terra_check'])),
                _buildSummaryRow("Selisih Tinggi Terra (mm)", valNum(data['terra_var'])),
                _buildSummaryRow("Nilai Kepekaan (mm/Ltr)", data['tangki_peka'] ?? "-"),
                _buildSummaryRow("Selisih Volume Terra (Ltr)", valNum(data['selisih_volume_terra'])),
                _buildSummaryRow("Segel Tangki Atas", data['segel_tangki_atas'] ?? "-"),
                _buildSummaryRow("Segel Tangki Bawah", data['segel_tangki_bawah'] ?? "-"),
                _buildSummaryRow("Kondisi Segel", data['segel_kondisi'] ?? "-"),

                const SizedBox(height: 8),

                _buildSectionTitle("Pemeriksaan Volume Solar"),
                _buildSummaryRow("Volume Tangki Pengirim", valNum(data['volume_pengirim'] ?? data['volume_vendor'], "Ltr")),
                _buildSummaryRow("Volume Tangki Kebun", valNum(data['volume_aktual'] ?? data['volume_kebun'], "Ltr")),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: _buildSummaryRow("Varian", valNum(data['varian_volume'] ?? data['var_solar_tangki'] ?? data['varian'], "Ltr")),
                ),

                const SizedBox(height: 16),

                _buildSectionTitle("Rincian per Tangki"),
                if (data['tanks'] != null && (data['tanks'] as List).isNotEmpty)
                  _buildTankList(data['tanks'])
                else
                  Text("Tidak ada data tangki", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),

                const SizedBox(height: 16),

                _buildSectionTitle("Riwayat Persetujuan"),
                if (data['approvals'] != null && (data['approvals'] as List).isNotEmpty)
                  _buildApprovalTimeline(data['approvals'])
                else
                  Text("Belum ada riwayat persetujuan", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
              ],
            ),
          ),

          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 2,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => controller.nextPage(),
              child: Text("Proses Dokumen", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
            ),
          ),
          SizedBox(height: 20 + MediaQuery.of(Get.context!).padding.bottom),
        ],
      ),
    );
  }

  // --- STEP 2: ACTION ---
  Widget _buildActionStep() {
    final data = controller.detailData;
    String docTypeName = data['doc_type_name'] ?? 'Penerimaan';
    String dateInbound = data['date_inbound'] ?? '-';

    String volume = "-";
    if (data['volume_aktual'] != null) {
      volume = "${double.tryParse(data['volume_aktual'].toString())?.toStringAsFixed(0)} Ltr";
    } else if (data['volume_vendor'] != null) {
      volume = "${double.tryParse(data['volume_vendor'].toString())?.toStringAsFixed(0)} Ltr";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Dokumen $docTypeName",
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            controller.noBast,
                            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFE3E8F0)),
                ),
                // OPTIMASI: Row ini dibungkus Expanded agar aman saat teks tumpah
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tanggal", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text(dateInbound, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Total Volume", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 4),
                          Text(volume, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary), textAlign: TextAlign.right),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          Text("Catatan Persetujuan", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
          const SizedBox(height: 8),
          TextField(
            controller: controller.noteController,
            maxLines: 2,
            style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.darkText),
            decoration: InputDecoration(
              hintText: "Tulis catatan (wajib jika Reject)...",
              hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400),
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Tanda Tangan", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
              InkWell(
                onTap: () => controller.signatureController.clear(),
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
          const SizedBox(height: 12),
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              border: Border.all(color: const Color(0xFFE3E8F0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.draw, color: Colors.grey.shade300, size: 28),
                        const SizedBox(height: 8),
                        Text("Tanda Tangan Disini", style: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  Signature(
                    controller: controller.signatureController,
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppColors.alertSoftRed, width: 1.5),
                      ),
                    ),
                    onPressed: () => controller.submitDecision('REJECTED'),
                    child: Text("Tolak", style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.alertSoftRed)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => controller.submitDecision('APPROVED'),
                    child: Text("Setujui", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20 + MediaQuery.of(Get.context!).padding.bottom),
        ],
      ),
    );
  }

  // --- WIDGET HELPER: TEXT ROW ---
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // OPTIMASI: Flex diubah agar ruang teks label lebih lega jika panjang
          Expanded(
            flex: 5,
            child: Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(value, textAlign: TextAlign.right, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
    );
  }

  // --- WIDGET HELPER: TIMELINE ---
  Widget _buildApprovalTimeline(List approvals) {
    var sortedApprovals = List.from(approvals);
    sortedApprovals.sort((a, b) => (a['id'] ?? 0).compareTo(b['id'] ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(sortedApprovals.length, (index) {
        var appv = sortedApprovals[index];
        bool isLast = index == sortedApprovals.length - 1;

        String status = appv['status_approve'] ?? 'PENDING';
        String title = appv['level_title'] ?? '-';
        String note = appv['catatan'] ?? '';

        String rawDate = appv['tgl_approve']?.toString() ?? '';
        String dateFormatted = "-";
        if (rawDate.isNotEmpty && rawDate != "null") {
          DateTime dt = DateTime.parse(rawDate).toLocal();
          dateFormatted = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        }

        Color statusColor = (status == 'APPROVED') ? Colors.green : (status == 'REJECTED') ? Colors.red : Colors.orange;
        IconData statusIcon = (status == 'APPROVED') ? Icons.check_circle : (status == 'REJECTED') ? Icons.cancel : Icons.access_time_filled;

        return Stack(
          children: [
            if (!isLast)
              Positioned(
                left: 11,
                top: 24,
                bottom: 0,
                child: Container(width: 2, color: Colors.grey.shade200),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)),
                            Text(dateFormatted, style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                          child: Text(status, style: AppFonts.fUrbanistBold10.copyWith(color: statusColor)),
                        ),
                        if (note.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFE3E8F0)),
                            ),
                            child: Text(note, style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.darkText)),
                          )
                        ]
                      ],
                    ),
                  ),
                )
              ],
            ),
          ],
        );
      }),
    );
  }

  // --- WIDGET HELPER: TANK LIST ---
  Widget _buildTankList(List tanksRaw) {
    List uniqueTanks = [];
    var seenCodes = <String>{};
    for (var t in tanksRaw) {
      String code = t['kode_tank'] ?? '';
      if (!seenCodes.contains(code)) {
        seenCodes.add(code);
        uniqueTanks.add(t);
      }
    }

    return Column(
      children: uniqueTanks.map((tank) {
        String valNum(dynamic v, [String suffix = ""]) => (v != null) ? "${double.tryParse(v.toString())?.toStringAsFixed(0) ?? v} $suffix" : "-";

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12), // OPTIMASI: Dari 16 ke 12
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8F0)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
              ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                    child: const Icon(Icons.storage_rounded, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tank['nama_tank'] ?? tank['kode_tank'] ?? "Tangki",
                    style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Divider(height: 1, color: Color(0xFFE3E8F0)),
              ),

              // OPTIMASI: Dibuat Row biasa yang fluid, tanpa garis pemisah yg memakan tempat
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTankValueCol("Volume Awal", valNum(tank['tinggi_terkini_cm'], "mm"), valNum(tank['volume_terkini_liter'], "Ltr")),
                  Container(width: 1, height: 35, color: const Color(0xFFE3E8F0), margin: const EdgeInsets.symmetric(horizontal: 6)),
                  _buildTankValueCol("Volume Akhir", valNum(tank['tinggi_akhir_cm'], "mm"), valNum(tank['volume_akhir_liter'], "Ltr")),
                  Container(width: 1, height: 35, color: const Color(0xFFE3E8F0), margin: const EdgeInsets.symmetric(horizontal: 6)),
                  _buildTankValueCol("Diterima", valNum(tank['tinggi_var_cm'], "mm"), "+${valNum(tank['volume_var_liter'], "Ltr")}", isHighlight: true),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- WIDGET HELPER: TANK COLUMN VALUE ---
  Widget _buildTankValueCol(String label, String tinggi, String volume, {bool isHighlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText, fontSize: 9)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.height, size: 10, color: Colors.grey.shade400),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  tinggi,
                  style: AppFonts.fUrbanistSemiBold10.copyWith(color: AppColors.darkText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.water_drop_outlined, size: 10, color: isHighlight ? AppColors.primary : Colors.grey.shade400),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  volume,
                  style: AppFonts.fUrbanistBold12.copyWith(color: isHighlight ? AppColors.primary : AppColors.darkText, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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
              Navigator.of(context).pop();
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
}