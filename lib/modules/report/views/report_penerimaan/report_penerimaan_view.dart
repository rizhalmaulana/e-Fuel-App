import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../datas/models/report/report_transaction_model.dart';
import '../../controllers/report_penerimaan_controller.dart';

class ReportPenerimaanView extends GetView<ReportPenerimaanController> {
  const ReportPenerimaanView({super.key});

  Widget _buildDateFilter(BuildContext context) {
    return Obx(() => Padding(
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
    ));
  }

  Widget _dateField(BuildContext context, String label, TextEditingController textCon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await controller.pickDate(context, textCon);
            controller.transactionList.refresh();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.fieldBackground,
              borderRadius: BorderRadius.circular(8),
            ),
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
    bool isOpen = item.statusInbound == 'O';
    Color statusColorBg = isOpen ? const Color(0xFFFFF3E0) : const Color(0xFFE8F5E9);
    Color statusColorText = isOpen ? const Color(0xFFFF9800) : const Color(0xFF4CAF50);

    return InkWell(
      onTap: isOpen ? null : () {
        Get.toNamed('/report-detail-penerimaan', arguments: {'no_doc': item.noDoc});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.01),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.noDoc ?? "-", style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColorBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isOpen ? "Dalam Proses" : "Selesai",
                        style: AppFonts.fUrbanistBold10.copyWith(color: statusColorText),
                      ),
                    ),
                    if (!isOpen)
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: GestureDetector(
                          onTap: () => Get.toNamed('/report-detail-penerimaan', arguments: {'no_doc': item.noDoc}),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.fieldBackground,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text(
                    "PO: ${item.noPo ?? '-'}",
                    style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text(
                    item.dateInbound ?? "-",
                    style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)
                ),
              ],
            ),
            const SizedBox(height: 6),

            Row(
              children: [
                const Icon(Icons.store_mall_directory_outlined, size: 14, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "${item.storageName ?? '-'} (${item.storageCode ?? '-'})",
                    style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const Divider(height: 24, color: AppColors.fieldBackground),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Vol. Vendor", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 2),
                          Text(
                            "${item.volumeVendor ?? 0} Ltr",
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Aktual Liter", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 2),
                          Text(
                            "${item.aktualLiter ?? 0} Ltr",
                            style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Varian Liter", style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
                          const SizedBox(height: 2),
                          Text(
                            "${item.varianLiter ?? 0} Ltr",
                            style: AppFonts.fUrbanistBold14.copyWith(
                              color: (item.varianLiter ?? 0) < 0 ? Colors.red : AppColors.primary
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ],
        ),
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
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary),
        )),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          _buildDateFilter(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (controller.transactionList.isEmpty) {
                return Center(
                  child: Text("Tidak ada data penerimaan", style: AppFonts.fUrbanistRegular16),
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