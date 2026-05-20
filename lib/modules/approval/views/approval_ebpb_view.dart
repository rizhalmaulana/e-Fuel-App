import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/approval_ebpb_controller.dart';

class ApprovalEbpbView extends GetView<ApprovalEbpbController> {
  const ApprovalEbpbView({super.key});

  String _val(dynamic value, [String suffix = ""]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    return "$value $suffix".trim();
  }

  String _formatLiter(dynamic value, [String suffix = "Ltr"]) {
    if (value == null || value.toString().isEmpty || value == "null") return "-";
    final parsed = double.tryParse(value.toString());
    if (parsed == null) return "-";
    final formatted = parsed % 1 == 0 ? parsed.toInt().toString() : parsed.toStringAsFixed(2);
    return "$formatted $suffix".trim();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.currentPage.value == 0 ? "Detail Dokumen E-BPB" : "Proses Approval",
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

        final data = controller.detailData;
        if (data.isEmpty) {
          return const Center(child: Text("Data tidak ditemukan"));
        }

        return PageView(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildSummaryStep(data),
            _buildActionStep(data),
          ],
        );
      }),
    );
  }

  Widget _buildSummaryStep(Map<String, dynamic> data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(data),
          const SizedBox(height: 16),

          _buildSectionTitle("Detail Transaksi"),
          if (data['details'] != null && (data['details'] as List).isNotEmpty)
            _buildDetailsList(data['details'])
          else
            Text("Tidak ada detail transaksi", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
          _buildSectionTitle("Riwayat Persetujuan"),
          if (data['approvals'] != null && (data['approvals'] as List).isNotEmpty)
            _buildApprovalTimeline(data['approvals'])
          else
            Text("Belum ada riwayat persetujuan", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),

          const SizedBox(height: 16),

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

  Widget _buildActionStep(Map<String, dynamic> data) {
    String docTypeName = 'E-BPB';
    String dateInbound = data['date_inbound'] ?? '-';

    double totalLiter = 0;
    if (data['details'] != null) {
      for (var item in data['details']) {
        if (item['aktual_pengisian_solar'] != null) {
          totalLiter += double.tryParse(item['aktual_pengisian_solar'].toString()) ?? 0;
        } else if (item['liter'] != null) {
          totalLiter += double.tryParse(item['liter'].toString()) ?? 0;
        }
      }
    }
    String volume = _formatLiter(totalLiter);

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
                            controller.noDoc,
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
                          Text("Total Aktual Solar", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
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
            maxLines: 3,
            style: AppFonts.fUrbanistRegular12,
            decoration: InputDecoration(
              hintText: "Masukkan catatan di sini (opsional)...",
              hintStyle: AppFonts.fUrbanistRegular12.copyWith(color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFE3E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  "Tanda Tangan digital",
                  style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText)
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero, // Menghilangkan padding bawaan button agar presisi
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => controller.signatureController.clear(),
                icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                label: Text(
                    "Bersihkan",
                    style: AppFonts.fUrbanistSemiBold12.copyWith(color: Colors.red)
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE3E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Signature(
                controller: controller.signatureController,
                height: 180,
                backgroundColor: const Color(0xFFFAFAFA),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => controller.submitDecision('REJECTED'),
                  child: Text("Reject", style: AppFonts.fUrbanistBold14.copyWith(color: Colors.red)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => controller.submitDecision('APPROVED'),
                  child: Text("Approve", style: AppFonts.fUrbanistBold14.copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsList(List<dynamic> details) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: details.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = details[index] as Map<String, dynamic>;

        double est = double.tryParse(item['estimasi_pengisian_solar'].toString()) ?? 0;
        double akt = double.tryParse(item['aktual_pengisian_solar'].toString()) ?? 0;
        bool isDeviating = (est - akt).abs() > 5;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE3E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Nama Unit & Plat No / No IO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _val(item['nama_unit']),
                    style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                  ),
                  Text(
                    item['no_polisi'] != null ? _val(item['no_polisi']) : _val(item['no_io']),
                    style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.secondaryText),
                  ),
                ],
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
              ),

              Row(
                children: [
                  _buildDataColumn("Supir", _val(item['supir_check'])),
                  _buildDataColumn("Tipe Unit", "${_val(item['tipe_unit_io'])} (${_val(item['kategori_kendaraan'])})"),
                  _buildDataColumn("Jenis", _val(item['jenis_pengeluaran'])),
                ],
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  _buildDataColumn("Awal (${_val(item['satuan'])})", _val(item['hm_km_awal'])),
                  _buildDataColumn("Akhir (${_val(item['satuan'])})", _val(item['hm_km_akhir'])),
                  _buildDataColumn("Varian Jarak", _val(item['varian'])),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDeviating ? Colors.orange.withOpacity(0.05) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDeviating ? Colors.orange.withOpacity(0.3) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Estimasi Pengisian",
                            style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatLiter(item['estimasi_pengisian_solar']),
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.darkText),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 24,
                      width: 1,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                "Aktual Pengisian",
                                style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
                              ),
                              if (isDeviating) ...[
                                const SizedBox(width: 4),
                                const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.orange),
                              ]
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatLiter(item['aktual_pengisian_solar']),
                            style: AppFonts.fUrbanistBold14.copyWith(
                              color: isDeviating ? Colors.orange.shade800 : AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeaderSection(Map<String, dynamic> data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE3E8F0), width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("No. Dokumen", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                    Text(_val(data['no_doc']), style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE3E8F0)),
          ),
          _buildSummaryRow("Unit / Afd", _val(data['unit'])),
          _buildSummaryRow("Tanggal Inbound", _val(data['date_inbound'])),
          _buildSummaryRow("Dibuat Oleh", _val(data['created_by'])),
        ],
      ),
    );
  }

  Widget _buildApprovalTimeline(List<dynamic> approvals) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: approvals.length,
      itemBuilder: (context, index) {
        final app = approvals[index] as Map<String, dynamic>;
        String status = _val(app['status_approve']);
        String title = _val(app['title']);
        String dateFormatted = app['tgl_approve'] ?? '-';
        String note = app['catatan'] ?? '';

        Color statusColor = Colors.grey;
        IconData statusIcon = Icons.hourglass_empty;

        if (status == 'APPROVED') {
          statusColor = Colors.green;
          statusIcon = Icons.check_circle_outline;
        } else if (status == 'REJECTED') {
          statusColor = Colors.red;
          statusIcon = Icons.error_outline;
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                if (index != approvals.length - 1)
                  Container(
                    width: 2,
                    height: 40 + (note.isNotEmpty ? 30 : 0),
                    color: Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText)),
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
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(title, style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText)),
    );
  }

  Widget _buildDataColumn(String label, String value, {bool isHighlight = false}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText, fontSize: 9)),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppFonts.fUrbanistBold12.copyWith(color: isHighlight ? AppColors.primary : AppColors.darkText),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
          Text(value, style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryText)),
        ],
      ),
    );
  }
}