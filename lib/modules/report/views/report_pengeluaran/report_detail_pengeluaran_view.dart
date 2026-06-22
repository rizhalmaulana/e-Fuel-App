import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../controllers/report_detail_pengeluaran_controller.dart';

class ReportDetailPengeluaranView extends GetView<ReportDetailPengeluaranController> {
  const ReportDetailPengeluaranView({super.key});

  String _val(dynamic value, [String suffix = ""]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    return "$value $suffix".trim();
  }

  /// Format angka: jika bulat tampilkan tanpa desimal, jika tidak tampilkan 2 desimal
  String _formatLiter(dynamic value, [String suffix = "Ltr"]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return "-";
    final formatted = parsed % 1 == 0
        ? parsed.toInt().toString()
        : parsed.toStringAsFixed(2);
    return "$formatted $suffix".trim();
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange)),
          const Divider(height: 20, thickness: 1),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: AppFonts.fUrbanistMedium12.copyWith(color: Colors.grey),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: isHighlight
                  ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange)
                  : AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiterComparison({
    required dynamic estimasi,
    required dynamic aktual,
  }) {
    final estimasiVal = double.tryParse(estimasi?.toString() ?? '') ?? 0;
    final aktualVal = double.tryParse(aktual?.toString() ?? '') ?? 0;
    final selisih = aktualVal - estimasiVal;
    final isOver = selisih > 0;
    final selisihColor = isOver ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
    final selisihIcon = isOver ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final selisihLabel = isOver ? "Lebih" : "Kurang";

    String fmtLiter(double val) {
      return val % 1 == 0
          ? "${val.toInt()} Ltr"
          : "${val.toStringAsFixed(2)} Ltr";
    }

    return Column(
      children: [
        // -- Estimasi & Aktual berdampingan --
        Row(
          children: [
            // Estimasi
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.show_chart_rounded, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text("Estimasi",
                            style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fmtLiter(estimasiVal),
                      style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Aktual
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryOrange.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primaryOrange.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_gas_station_outlined, size: 14, color: AppColors.primaryOrange),
                        const SizedBox(width: 4),
                        Text("Aktual",
                            style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.primaryOrange)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      fmtLiter(aktualVal),
                      style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // -- Selisih --
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: selisihColor.withOpacity(0.06),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selisihColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.compare_arrows_rounded, size: 16, color: AppColors.secondaryText),
                    ),
                    const SizedBox(width: 6),

                    Expanded(
                      child: Text(
                        "Selisih (Aktual - Estimasi)",
                        style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(selisihIcon, size: 14, color: selisihColor),
                  const SizedBox(width: 4),
                  Text(
                    "${fmtLiter(selisih.abs())} ($selisihLabel)",
                    style: AppFonts.fUrbanistBold12.copyWith(color: selisihColor),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovalTimeline(List approvals) {
    return Column(
      children: List.generate(approvals.length, (index) {
        var appv = approvals[index];
        bool isLast = index == approvals.length - 1;
        String date = appv['tgl_approve'] != null
            ? appv['tgl_approve'].toString().substring(0, 16).replaceAll('T', ' ')
            : '-';
        String status = appv['status_approve'] ?? 'PENDING';
        Color statusColor = status == 'APPROVED' ? Colors.green : Colors.orange;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(Icons.check_circle, color: statusColor, size: 20),
                if (!isLast) Container(height: 40, width: 2, color: statusColor.withOpacity(0.3)),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appv['level_title'] ?? "-", style: AppFonts.fUrbanistBold12),
                    Text(date,
                        style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey)),
                    if (appv['catatan'] != null && appv['catatan'].toString().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(appv['catatan'],
                            style: AppFonts.fUrbanistMedium10
                                .copyWith(color: Colors.grey.shade700)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Detail Pengeluaran",
            style: AppFonts.fUrbanistBold16.copyWith(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }

        final data = controller.detailData;
        if (data.isEmpty) return const Center(child: Text("Data tidak tersedia"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ── INFORMASI UMUM ───────────────────────────────────────
              _buildSection("Informasi Umum", [
                _buildRow("No. Dokumen", _val(data['no_doc'])),
                _buildRow("Tanggal", _val(data['date_inbound'])),
                _buildRow("Unit Asal", _val(data['nama_unit'])),
                _buildRow("Storage", _val(data['storage_name'])),
                _buildRow(
                  "Status",
                  data['status_inbound'] == 'C' ? "Selesai" : "Proses",
                  isHighlight: true,
                ),
                _buildRow("Tipe Input", _val(data['input_type'])),
              ]),

              // ── DATA UNIT / KENDARAAN ──
              _buildSection("Data Unit Penerima", [
                _buildRow("No. Unit/Polisi", _val(data['nopol_check'])),
                _buildRow("Nama Operator", _val(data['supir_check'])),
                _buildRow("Cost Center", _val(data['cost_center'])),
                _buildRow("Keterangan", _val(data['keterangan'])),
              ]),

              // ── DATA PENGISIAN ──
              _buildSection("Data Pengisian", [
                _buildRow("HM/KM Awal", _val(data['hm_km_awal'])),
                _buildRow("HM/KM Akhir", _val(data['hm_km_akhir'])),
                _buildRow("HM/KM Varian", _val(data['varian_hm_km_awal'])),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1),
                ),
                _buildRow("Ratio Input", _val(data['ratio_input'])),
                const SizedBox(height: 4),

                // -- Estimasi vs Aktual (widget khusus) --
                _buildLiterComparison(
                  estimasi: data['estimasi_pengisian_solar'] ?? data['liter'],
                  aktual: data['aktual_pengisian_solar'] ?? data['aktual_liter'],
                ),

                const SizedBox(height: 8),
                _buildRow("Varian (Selisih)", _formatLiter(data['varian_liter'])),
              ]),

              // ── RIWAYAT APPROVAL ─────────────────────────────────────
              if (data['approvals'] != null &&
                  (data['approvals'] as List).isNotEmpty)
                _buildSection("Riwayat Persetujuan", [
                  _buildApprovalTimeline(data['approvals']),
                ]),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}