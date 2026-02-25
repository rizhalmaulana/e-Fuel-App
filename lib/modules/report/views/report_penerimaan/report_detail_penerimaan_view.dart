import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../controllers/report_detail_penerimaan_controller.dart';


class ReportDetailPenerimaanView extends GetView<ReportDetailPenerimaanController> {
  const ReportDetailPenerimaanView({Key? key}) : super(key: key);

  String _val(dynamic value, [String suffix = ""]) {
    if (value == null || value.toString().isEmpty) return "-";
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
          Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
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
          Expanded(flex: 3, child: Text(value, textAlign: TextAlign.right, style: isHighlight ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.primary) : AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.darkText))),
        ],
      ),
    );
  }

  Widget _buildTankList(List tanks) {
    // Hindari duplikasi jika ada (seperti contoh JSON yang terkirim dobel)
    List uniqueTanks = [];
    var seenCodes = <String>{};
    for (var t in tanks) {
      if (!seenCodes.contains(t['kode_tank'])) {
        seenCodes.add(t['kode_tank']);
        uniqueTanks.add(t);
      }
    }

    return Column(
      children: uniqueTanks.map((tank) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.fieldBackground, borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tank['nama_tank'] ?? "-", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.darkText)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildTankVal("Terkini", _val(tank['volume_terkini_liter'], "L"), _val(tank['tinggi_terkini_cm'], "mm")),
                  _buildTankVal("Akhir", _val(tank['volume_akhir_liter'], "L"), _val(tank['tinggi_akhir_cm'], "mm")),
                  _buildTankVal("Diterima", _val(tank['volume_var_liter'], "L"), _val(tank['tinggi_var_cm'], "mm"), color: AppColors.primary),
                ],
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTankVal(String title, String vol, String height, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 2),
        Text(vol, style: AppFonts.fUrbanistBold12.copyWith(color: color ?? AppColors.darkText)),
        Text(height, style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildApprovalTimeline(List approvals) {
    return Column(
      children: List.generate(approvals.length, (index) {
        var appv = approvals[index];
        bool isLast = index == approvals.length - 1;
        String date = appv['tgl_approve'] != null ? appv['tgl_approve'].toString().substring(0, 16).replaceAll('T', ' ') : '-';

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 20),
                if (!isLast) Container(height: 40, width: 2, color: Colors.green.withOpacity(0.3)),
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
                    Text("$date • ${_val(appv['approved_by'])}", style: AppFonts.fUrbanistRegular10.copyWith(color: Colors.grey)),
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
        title: Text("Detail Penerimaan", style: AppFonts.fUrbanistBold16.copyWith(color: Colors.black)),
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
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        final data = controller.detailData;
        if (data.isEmpty) return const Center(child: Text("Data tidak tersedia"));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // 1. INFO UMUM
              _buildSection("Informasi Umum", [
                _buildRow("No. Dokumen", _val(data['no_doc'])),
                _buildRow("Tanggal", _val(data['date_inbound'])),
                _buildRow("Unit", _val(data['nama_unit'])),
                _buildRow("Storage", _val(data['storage_name'])),
                _buildRow("Status", data['status_inbound'] == 'C' ? "Selesai (Full Approved)" : "Proses", isHighlight: true),
              ]),

              // 2. DATA PENGIRIMAN
              _buildSection("Data Pengiriman / Vendor", [
                _buildRow("No. PO", _val(data['purch_no'])),
                _buildRow("Vendor SPB", _val(data['vendor_spb'])),
                _buildRow("No. Polisi", _val(data['nopol_vendor'])),
                _buildRow("Sopir", _val(data['supir_vendor'])),
                const SizedBox(height: 8),
                _buildRow("Volume Pengiriman", _val(data['volume_vendor'], "Ltr"), isHighlight: true),
                _buildRow("Density", _val(data['density_vendor'])),
                _buildRow("Temperature", _val(data['temp_vendor'], "°C")),
              ]),

              // 3. PEMERIKSAAN (TERRA & SEGEL)
              _buildSection("Pemeriksaan Kedatangan", [
                _buildRow("Terra Vendor", _val(data['terra_vendor'], "mm")),
                _buildRow("Terra Pemeriksaan", _val(data['terra_check'], "mm")),
                _buildRow("Selisih Terra", _val(data['terra_var'], "mm")),
                _buildRow("Kepekaan Tangki", _val(data['tangki_peka'], "mm/L")),
                const SizedBox(height: 8),
                _buildRow("Segel Atas", _val(data['segel_tangki_atas'])),
                _buildRow("Segel Bawah", _val(data['segel_tangki_bawah'])),
                _buildRow("Kondisi Segel", _val(data['segel_kondisi'])),
              ]),

              // 4. HASIL PENERIMAAN VOLUME
              _buildSection("Hasil Penerimaan (Aktual)", [
                _buildRow("Total Volume Diterima", _val(data['volume_var_liter'], "Ltr"), isHighlight: true),
                _buildRow("Tinggi Total Diterima", _val(data['tinggi_var_cm'], "mm")),
              ]),

              // 5. RINCIAN TANGKI
              if (data['tanks'] != null && (data['tanks'] as List).isNotEmpty)
                _buildSection("Rincian per Tangki", [
                  _buildTankList(data['tanks'])
                ]),

              // 6. RIWAYAT APPROVAL
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