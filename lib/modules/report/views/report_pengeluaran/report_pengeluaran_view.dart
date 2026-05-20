import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../datas/models/report/report_transaction_model.dart';
import '../../controllers/report_pengeluaran_controller.dart';

class ReportPengeluaranView extends GetView<ReportPengeluaranController> {
  const ReportPengeluaranView({super.key});

  Widget _buildDateFilter(BuildContext context) {
    return Obx(() => Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _dateField(context, "dari Tanggal", controller.dateFromC),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _dateField(context, "ke Tanggal", controller.dateToC),
          ),
        ],
      ),
    ));
  }

  Widget _dateField(BuildContext context, String label, TextEditingController textCon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.pickDate(context, textCon),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(color: AppColors.fieldBackground, borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Pastikan teks mengambil data terbaru dari controller
                Text(textCon.text, style: AppFonts.fUrbanistRegular12),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryOrange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ReportTransactionModel item) {
    bool isCompleted = item.statusInbound == 'C';
    Color statusColorBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    Color statusColorText = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    final estimasi = item.estimasiPengisianSolar ?? 0;
    final aktual = item.aktualPengisianSolar ?? 0;
    final selisih = aktual - estimasi;
    final isOver = selisih > 0;

    return InkWell(
      onTap: () {
        Get.toNamed('/report-detail-pengeluaran', arguments: {'no_doc': item.noDoc});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.noDoc ?? "-", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColorBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    isCompleted ? "Selesai" : "Dalam Proses",
                    style: AppFonts.fUrbanistBold10.copyWith(color: statusColorText),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text(item.dateInbound ?? "-", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                if (item.nopolCheck != null) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      "${item.nopolCheck} • ${item.supirCheck ?? '-'}",
                      style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),

            // -- Divider --
            Divider(color: Colors.grey.shade100, height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildLiterInfo(
                    label: "Estimasi",
                    value: estimasi,
                    icon: Icons.show_chart_rounded,
                    iconColor: AppColors.secondaryText,
                    valueColor: AppColors.primaryText,
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(
                  child: _buildLiterInfo(
                    label: "Aktual",
                    value: aktual,
                    icon: Icons.local_gas_station_outlined,
                    iconColor: AppColors.primaryOrange,
                    valueColor: AppColors.primaryOrange,
                  ),
                ),
                Container(width: 1, height: 36, color: Colors.grey.shade200),
                Expanded(
                  child: _buildSelisihInfo(selisih: selisih, isOver: isOver),
                ),
              ],
            ),

            // -- Tombol Lihat Detail (Sekarang selalu muncul agar user bisa cek berkas proses/selesai) --
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 36,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primaryOrange),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Get.toNamed('/report-detail-pengeluaran', arguments: {'no_doc': item.noDoc});
                },
                child: Text("Lihat Detail", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryOrange)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiterInfo({
    required String label,
    required double value,
    required IconData icon,
    required Color iconColor,
    required Color valueColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "${value % 1 == 0 ? value.toInt() : value.toStringAsFixed(2)} Ltr",
          style: AppFonts.fUrbanistBold12.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _buildSelisihInfo({required double selisih, required bool isOver}) {
    final Color color = isOver ? const Color(0xFFE53935) : const Color(0xFF4CAF50);
    final IconData icon = isOver ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    final String label = isOver ? "Lebih" : "Kurang";

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows_rounded, size: 13, color: AppColors.secondaryText),
            const SizedBox(width: 4),
            Text("Selisih", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 2),
            Text(
              "${selisih.abs() % 1 == 0 ? selisih.abs().toInt() : selisih.abs().toStringAsFixed(2)} Ltr",
              style: AppFonts.fUrbanistBold12.copyWith(color: color),
            ),
          ],
        ),
        Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: color)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.title.value,
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildDateFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
              }
              if (controller.transactionList.isEmpty) {
                return Center(
                  child: Text("Tidak ada data pengeluaran", style: AppFonts.fUrbanistRegular16),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: controller.transactionList.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildCard(controller.transactionList[index]);
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}