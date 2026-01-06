import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/report/report_transaction_model.dart';
import '../controllers/report_penerimaan_controller.dart';

class ReportPenerimaanView extends GetView<ReportPenerimaanController> {
  const ReportPenerimaanView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Obx(() => Text(
          controller.title.value,
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildDateFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.transactionList.isEmpty) {
                return Center(
                  child: Text("Tidak ada data penerimaan",
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
                const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(ReportTransactionModel item) {
    // LOGIC TAMPILAN KHUSUS PENERIMAAN
    bool isCompleted = (item.statusInbound == 'C' || item.statusInbound == 'P');
    Color statusColorBg = isCompleted ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0);
    Color statusColorText = isCompleted ? const Color(0xFF4CAF50) : const Color(0xFFFF9800);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.fieldBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.local_shipping_outlined, color: AppColors.primary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.docTypeName ?? "-", style: AppFonts.fUrbanistBold14),
                    Text(item.dateInbound ?? "-", style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(color: statusColorBg, borderRadius: BorderRadius.circular(8)),
                child: Text(isCompleted ? "Selesai" : "Proses", style: AppFonts.fUrbanistMedium10.copyWith(color: statusColorText)),
              )
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.noDoc ?? "-", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.secondaryText)),
                  const SizedBox(height: 4),
                  // KHUSUS PENERIMAAN: Show Volume Vendor
                  Text("${item.volumeVendor ?? 0} Liter", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
                ],
              ),
              // Tombol Detail...
            ],
          )
        ],
      ),
    );
  }
}