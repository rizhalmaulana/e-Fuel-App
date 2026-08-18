import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../configs/app_icons.dart';
import '../../controllers/report_transfer_controller.dart';

class ReportTransferView extends GetView<ReportTransferController> {
  const ReportTransferView({super.key});

  Widget _buildDateFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _dateField(context, "dari Tanggal", controller.dateFrom),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _dateField(context, "ke Tanggal", controller.dateTo),
          ),
        ],
      ),
    );
  }

  Widget _dateField(BuildContext context, String label, RxString dateObs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => controller.pickDate(context, dateObs),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E6), // Light orange background as per mockup
              borderRadius: BorderRadius.circular(8)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(dateObs.value, style: AppFonts.fUrbanistRegular12)),
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primaryOrange),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(Map<String, dynamic> item) {
    bool isCompleted = item['status'] == 'Selesai';
    Color statusColorBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    Color statusColorText = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    final double estimasi = item['estimasi'] ?? 0;
    final double aktual = item['aktual'] ?? 0;
    final double selisih = (aktual - estimasi).abs();
    final bool isOver = aktual > estimasi;
    
    // As per mockup, if aktual < estimasi, selisih is usually green (under budget) or orange (over budget)
    // We will follow the mockup design which shows 150 Ltr in green.
    Color selisihColor = const Color(0xFF4CAF50); // Green

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
              Row(
                children: [
                  Image.asset(AppIcons.icTransfer, width: 24, height: 24, color: AppColors.primaryOrange),
                  const SizedBox(width: 8),
                  Text(item['no_doc'] ?? "-", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColorBg, borderRadius: BorderRadius.circular(6)),
                child: Text(
                  item['status'],
                  style: AppFonts.fUrbanistBold10.copyWith(color: statusColorText),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(item['date'] ?? "-", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.directions_car_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(item['nopol'] ?? "-", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 4),
                  Text(item['operator'] ?? "-", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
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
                child: _buildSelisihInfo(selisih: selisih, color: selisihColor),
              ),
            ],
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Navigate to detail
              },
              child: Text("Lihat Detail", style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primaryOrange)),
            ),
          ),
        ],
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
          style: AppFonts.fUrbanistBold14.copyWith(color: valueColor),
        ),
      ],
    );
  }

  Widget _buildSelisihInfo({required double selisih, required Color color}) {
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
        Text(
          "${selisih % 1 == 0 ? selisih.toInt() : selisih.toStringAsFixed(2)} Ltr",
          style: AppFonts.fUrbanistBold14.copyWith(color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
                  child: Text("Tidak ada data laporan", style: AppFonts.fUrbanistRegular16),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: controller.transactionList.length,
                separatorBuilder: (c, i) => const SizedBox(height: 16),
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
