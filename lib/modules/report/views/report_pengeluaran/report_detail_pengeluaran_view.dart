import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../controllers/report_detail_pengeluaran_controller.dart';

class ReportDetailPengeluaranView extends GetView<ReportDetailPengeluaranController> {
  const ReportDetailPengeluaranView({Key? key}) : super(key: key);

  String _val(dynamic value, [String suffix = ""]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    return "$value $suffix".trim();
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText))),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
                value,
                textAlign: TextAlign.right,
                style: isHighlight
                    ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange)
                    : AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText)
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalTimeline(List approvals) {
    return Column(
      children: List.generate(approvals.length, (index) {
        var appv = approvals[index];
        bool isLast = index == approvals.length - 1;
        String date = appv['tgl_approve'] != null ? appv['tgl_approve'].toString().substring(0, 16).replaceAll('T', ' ') : '-';
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
                    Text(date, style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey)),
                    if (appv['catatan'] != null && appv['catatan'].toString().isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                        child: Text(appv['catatan'], style: AppFonts.fUrbanistMedium10.copyWith(color: Colors.grey.shade700)),
                      )
                  ],
                ),
              ),
            )
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
        title: Text("Detail Pengeluaran", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
        }

        final data = controller.detailData;
        if (data.isEmpty) return const Center(child: Text("Data tidak tersedia"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // INFO UMUM
              _buildSection("Informasi Umum", [
                _buildRow("No. Dokumen", _val(data['no_doc'])),
                _buildRow("Tanggal", _val(data['date_inbound'])),
                _buildRow("Unit Asal", _val(data['nama_unit'])),
                _buildRow("Storage", _val(data['storage_name'])),
                _buildRow("Status", data['status_inbound'] == 'C' ? "Selesai" : "Proses", isHighlight: true),
                _buildRow("Tipe Input", _val(data['input_type'])),
              ]),

              // DATA UNIT / KENDARAAN (PENGGUNA SOLAR)
              _buildSection("Data Unit Penerima", [
                _buildRow("No. Unit/Polisi", _val(data['nopol_check'])),
                _buildRow("Nama Operator", _val(data['supir_check'])),
                _buildRow("Cost Center", _val(data['cost_center'])),
                _buildRow("Keterangan", _val(data['keterangan'])),
              ]),

              // DATA PENGISIAN HM/KM & LITER
              _buildSection("Data Pengisian", [
                _buildRow("HM/KM Awal", _val(data['hm_km_awal'])),
                _buildRow("HM/KM Akhir", _val(data['hm_km_akhir'])),
                _buildRow("HM/KM Varian", _val(data['varian_hm_km_awal'])),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1),
                ),
                _buildRow("Ratio Input", _val(data['ratio_input'])),
                _buildRow("Estimasi Sistem", _val(data['liter'], "Ltr")),
                // Highlight Aktual Liter karena ini yg paling penting di FOT
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.primaryOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)
                  ),
                  child: _buildRow("Aktual Pengisian", _val(data['aktual_liter'], "Ltr"), isHighlight: true),
                ),
                const SizedBox(height: 8),
                _buildRow("Varian (Selisih)", _val(data['varian_liter'], "Ltr")),
              ]),

              // RIWAYAT APPROVAL
              if (data['approvals'] != null && (data['approvals'] as List).isNotEmpty)
                _buildSection("Riwayat Persetujuan", [
                  _buildApprovalTimeline(data['approvals'])
                ]),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}