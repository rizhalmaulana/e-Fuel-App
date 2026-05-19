import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import '../controllers/approval_ebpb_controller.dart';

class ApprovalEbpbView extends GetView<ApprovalEbpbController> {
  const ApprovalEbpbView({super.key});

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

  // --- STEP 1: SUMMARY ---
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

          const SizedBox(height: 16),

          _buildSectionTitle("Riwayat Persetujuan"),
          if (data['approvals'] != null && (data['approvals'] as List).isNotEmpty)
            _buildApprovalTimeline(data['approvals'])
          else
            Text("Belum ada riwayat persetujuan", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),

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
  Widget _buildActionStep(Map<String, dynamic> data) {
    String docTypeName = 'E-BPB';
    String dateInbound = data['date_inbound'] ?? '-';
    
    // Hitung total volume dari details
    double totalLiter = 0;
    if (data['details'] != null) {
      for (var item in data['details']) {
        if (item['liter'] != null) {
          totalLiter += double.tryParse(item['liter'].toString()) ?? 0;
        } else if (item['jumlah_pengisian_solar'] != null) {
          totalLiter += double.tryParse(item['jumlah_pengisian_solar'].toString()) ?? 0;
        }
      }
    }
    String volume = "${totalLiter.toStringAsFixed(0)} Ltr";

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
                          Text("Total Solar Keluar", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
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
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE3E8F0))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE3E8F0))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),

        const SizedBox(height: 16),

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
            color: Colors.white,
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
  Widget _buildHeaderSection(Map<String, dynamic> data) {
    String val(dynamic v, [String suffix = ""]) => (v != null && v.toString().isNotEmpty) ? "$v $suffix" : "-";
    
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
                    Text(val(data['no_doc']), style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFE3E8F0)),
          ),
          _buildSummaryRow("Unit", val(data['unit'])),
          _buildSummaryRow("Tanggal", val(data['date_inbound'])),
          _buildSummaryRow("Dibuat Oleh", val(data['created_by'])),
        ],
      ),
    );
  }

  Widget _buildDetailsList(List details) {
    return Column(
      children: details.map((item) {
        String kategori = item['kategori_kendaraan'] ?? '-';
        String jenis = item['jenis_pengeluaran'] ?? '-';
        String noPolisi = item['no_polisi']?.toString().isNotEmpty == true ? item['no_polisi'] : '-';
        String namaUnit = item['nama_unit']?.toString().isNotEmpty == true ? item['nama_unit'] : '-';
        String ioOrCc = item['no_io']?.toString().isNotEmpty == true && item['no_io'] != '-' 
            ? item['no_io'] 
            : (item['cost_center']?.toString().isNotEmpty == true ? item['cost_center'] : '-');
            
        String liter = item['liter'] != null ? "${item['liter']} Ltr" : "-";
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6)
                    ),
                    child: Text(kategori, style: AppFonts.fUrbanistBold10.copyWith(color: AppColors.primary)),
                  ),
                  Text(jenis, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                ],
              ),
              const SizedBox(height: 10),
              _buildSummaryRow("IO / Cost Center", ioOrCc),
              if (kategori == 'TAMU' || kategori == 'VENDOR') ...[
                _buildSummaryRow("No. Polisi", noPolisi),
              ] else ...[
                _buildSummaryRow("Nama Unit", namaUnit),
              ],
              _buildSummaryRow("Supir", item['supir_check'] ?? '-'),
              
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Divider(height: 1, color: Color(0xFFE3E8F0)),
              ),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataColumn("HM/KM Awal", "${item['hm_km_awal'] ?? 0}"),
                  Container(width: 1, height: 30, color: const Color(0xFFE3E8F0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                  _buildDataColumn("HM/KM Akhir", "${item['hm_km_akhir'] ?? 0}"),
                  Container(width: 1, height: 30, color: const Color(0xFFE3E8F0), margin: const EdgeInsets.symmetric(horizontal: 8)),
                  _buildDataColumn("Jumlah Solar", liter, isHighlight: true),
                ],
              ),
            ],
          ),
        );
      }).toList(),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
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
    // Asumsi approvals sudah terurut atau kita biarkan urutan dari API
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(sortedApprovals.length, (index) {
        var appv = sortedApprovals[index];
        bool isLast = index == sortedApprovals.length - 1;

        String status = appv['status_approve'] ?? 'PENDING';
        String title = appv['title'] ?? appv['level'] ?? '-';
        String note = appv['catatan'] ?? '';

        String rawDate = appv['tgl_approve']?.toString() ?? '';
        String dateFormatted = "-";
        if (rawDate.isNotEmpty && rawDate != "null") {
          try {
            DateTime dt = DateTime.parse(rawDate).toLocal();
            dateFormatted = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}";
          } catch(e) {
            dateFormatted = rawDate;
          }
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
}
