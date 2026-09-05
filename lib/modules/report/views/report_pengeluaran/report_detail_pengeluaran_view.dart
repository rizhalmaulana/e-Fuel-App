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

  Widget _buildPhotoList(Map<String, dynamic> data) {
    List<Map<String, String>> images = [];
    if (data['foto1_url'] != null && data['foto1_url'].toString().isNotEmpty) {
      images.add({"url": data['foto1_url'], "label": "Foto Odometer (KM Kendaraan)"});
    }
    if (data['foto2_url'] != null && data['foto2_url'].toString().isNotEmpty) {
      images.add({"url": data['foto2_url'], "label": "Foto Angka Meter Dispenser"});
    }
    if (data['foto3_url'] != null && data['foto3_url'].toString().isNotEmpty) {
      images.add({"url": data['foto3_url'], "label": "Foto Supir/Operator"});
    }

    if (images.isEmpty) {
      return Text("Tidak ada foto terlampir.", style: AppFonts.fUrbanistMedium12.copyWith(color: Colors.grey));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: images.map((img) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.all(16),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            InteractiveViewer(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  img["url"]!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.broken_image, color: Colors.white, size: 50),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                                onPressed: () => Get.back(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        img["url"]!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(child: Icon(Icons.broken_image, color: Colors.grey));
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange));
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 100,
                  child: Text(
                    img["label"]!,
                    textAlign: TextAlign.center,
                    style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.darkText),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatDateTime(dynamic value) {
    if (value == null || value.toString().isEmpty) return "-";
    try {
      final dt = DateTime.parse(value.toString());
      return "${dt.day.toString().padLeft(2, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Detail Pengeluaran",
            style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryOrange)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
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
              // INFORMASI UMUM
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

              // DATA UNIT / KENDARAAN
              _buildSection("Data Unit Penerima", [
                _buildRow("No. Unit/Polisi", _val(data['nopol_check'])),
                _buildRow("Nama Operator", _val(data['supir_check'])),
                
                if (_val(data['cost_center']) != '-' && _val(data['no_io']) != '-') ...[
                  _buildRow("Cost Center", _val(data['cost_center'])),
                  _buildRow("No. IO", _val(data['no_io'])),
                ] else if (_val(data['cost_center']) != '-') ...[
                  _buildRow("Cost Center", _val(data['cost_center'])),
                ] else if (_val(data['no_io']) != '-') ...[
                  _buildRow("No. IO", _val(data['no_io'])),
                ] else ...[
                  _buildRow("Cost Center", "-"),
                ],

                _buildRow("Keterangan", _val(data['keterangan'])),
              ]),

              // DATA PENGISIAN
              _buildSection("Data Pengisian", [
                _buildRow("Waktu Mulai", _formatDateTime(data['dtime_before'])),
                _buildRow("Waktu Selesai", _formatDateTime(data['dtime_after'])),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1),
                ),
                _buildRow("HM/KM Sebelumnya", _val(data['hm_km_awal'])),
                _buildRow("HM/KM Saat Ini", _val(data['hm_km_akhir'])),
                _buildRow("HM/KM Varian", _val(data['varian_hm_km_awal'])),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(height: 1),
                ),
                _buildRow("Ratio Input", _val(data['ratio_input'])),
                _buildRow("Estimasi Liter", _formatLiter(data['estimasi_pengisian_solar'] ?? data['liter'])),
                _buildRow("Aktual Liter", _formatLiter(data['aktual_pengisian_solar'] ?? data['aktual_liter']), isHighlight: true),
              ]),

              // RIWAYAT APPROVAL
              if (data['approvals'] != null &&
                  (data['approvals'] as List).isNotEmpty)
                _buildSection("Riwayat Persetujuan", [
                  _buildApprovalTimeline(data['approvals']),
                ]),

              // LAMPIRAN FOTO
              _buildSection("Lampiran Foto", [
                _buildPhotoList(data),
              ]),

              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }
}