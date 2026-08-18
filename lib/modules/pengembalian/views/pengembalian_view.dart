import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../controllers/pengembalian_controller.dart';
import '../../../routes/app_pages.dart';

class PengembalianView extends GetView<PengembalianController> {
  const PengembalianView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey,
      appBar: AppBar(
        title: Text('Pengembalian Solar',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primary, size: 20),
            onPressed: () => Get.back()),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (controller.transaksiList.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchData,
            color: AppColors.primary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: Get.height * 0.7,
                  child: Center(
                    child: Text(
                      'Belum ada Transaksi Pengembalian',
                      style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchData,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: controller.transaksiList.length,
            itemBuilder: (context, index) {
              final item = controller.transaksiList[index];
              bool showHeader = false;

              if (index == 0) {
                showHeader = true;
              } else {
                final prevItem = controller.transaksiList[index - 1];
                final currentDate = _extractDate(item.createdAt);
                final prevDate = _extractDate(prevItem.createdAt);
                if (currentDate != prevDate) {
                  showHeader = true;
                }
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader) _buildDateHeader(item.createdAt),
                  _buildCard(item),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  String _extractDate(String dateTimeStr) {
    if (dateTimeStr.isEmpty || dateTimeStr == '-') return '-';
    try {
      final date = DateTime.parse(dateTimeStr);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (e) {
      return dateTimeStr;
    }
  }

  Widget _buildDateHeader(String dateTimeStr) {
    String displayDate = '-';
    try {
      final date = DateTime.parse(dateTimeStr);
      displayDate = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      displayDate = dateTimeStr;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        displayDate,
        style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
      ),
    );
  }

  Widget _buildCard(PengembalianSolarModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item.namaUnit,
                    style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F5FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Pengembalian',
                    style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('No. Transaksi', item.noDoc),
            const SizedBox(height: 8),
            _buildInfoRow('No. IO', item.noIo),
            const SizedBox(height: 8),
            _buildInfoRow('Liter Pengambilan', '${item.liter} ${item.satuan}'),
            const SizedBox(height: 8),
            _buildInfoRow('Aktual Pengisian', '${item.aktualLiter} ${item.satuan}'),
            const SizedBox(height: 8),
            _buildInfoRow('Varian/Sisa', '${item.varianLiter} ${item.satuan}', isHighlighted: true),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed(Routes.PENGEMBALIAN_PROSES, arguments: item);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Proses',
                  style: AppFonts.fUrbanistBold14.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
          ),
        ),
        const Text(': ', style: TextStyle(color: AppColors.secondaryText)),
        Expanded(
          child: Text(
            value,
            style: isHighlighted 
              ? AppFonts.fUrbanistBold12.copyWith(color: AppColors.primary)
              : AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText),
          ),
        ),
      ],
    );
  }
}
