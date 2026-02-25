import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../datas/models/report/report_transaction_model.dart';
import '../../controllers/report_pengeluaran_controller.dart';

class ReportPengeluaranView extends GetView<ReportPengeluaranController> {
  const ReportPengeluaranView({Key? key}) : super(key: key);

  Widget _buildDateFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: _dateField(context, "Date From", controller.dateFromC),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _dateField(context, "Date To", controller.dateToC),
          ),
        ],
      ),
    );
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
    bool isCompleted = (item.statusInbound == 'C' || item.statusInbound == 'P');
    Color statusColorBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    Color statusColorText = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    return Container(
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
                child: Text(isCompleted ? "Selesai" : "Proses", style: AppFonts.fUrbanistBold10.copyWith(color: statusColorText)),
              )
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
              const SizedBox(width: 4),
              Text(item.dateInbound ?? "-", style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
              const SizedBox(width: 12),
              const Icon(Icons.local_gas_station_outlined, size: 14, color: AppColors.primaryOrange),
              const SizedBox(width: 4),
              Text("${item.jumlahPengisianSolar ?? 0} Ltr", style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryOrange)),
            ],
          ),

          const SizedBox(height: 12),

          // TOMBOL LIHAT DETAIL
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primaryOrange),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                // Sesuai dengan route yang ada di app_pages.dart Anda
                Get.toNamed('/report-detail-pengeluaran', arguments: {'no_doc': item.noDoc});
              },
              child: Text("Lihat Detail", style: AppFonts.fUrbanistSemiBold12.copyWith(color: AppColors.primaryOrange)),
            ),
          )
        ],
      ),
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
                  child: Text("Tidak ada data pengeluaran",
                      style: AppFonts.fUrbanistRegular16),
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