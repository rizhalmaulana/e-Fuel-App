import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../configs/app_colors.dart';
import '../../../configs/app_fonts.dart';
import '../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../controllers/pengembalian_controller.dart';
import '../../../routes/app_pages.dart';
import 'package:sticky_headers/sticky_headers.dart';

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

        if (controller.filteredTransaksiList.isEmpty) {
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
          child: Builder(
            builder: (context) {
              // Group data by date
              Map<String, List<PengembalianSolarModel>> groupedData = {};
              for (var item in controller.filteredTransaksiList) {
                String date = _extractDate(item.createdAt);
                if (!groupedData.containsKey(date)) {
                  groupedData[date] = [];
                }
                groupedData[date]!.add(item);
              }

              final dateKeys = groupedData.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 80), // extra bottom padding for floating button
                itemCount: dateKeys.length,
                itemBuilder: (context, index) {
                  final dateKey = dateKeys[index];
                  final items = groupedData[dateKey]!;

                  return StickyHeader(
                    header: _buildDateHeader(dateKey),
                    content: Column(
                      children: items.map((item) => _buildCard(item)).toList(),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showSearchBottomSheet(),
        backgroundColor: AppColors.white,
        mini: true,
        child: const Icon(Icons.search, color: AppColors.primary),
      ),
    );
  }

  void _showSearchBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 24, bottom: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Pencarian / Filter', style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText)),
                Obx(() {
                  if (controller.searchQuery.value.isNotEmpty || controller.startDateFilter.value != null) {
                    return GestureDetector(
                      onTap: () {
                        controller.resetFilters();
                      },
                      child: Text('Reset Filter', style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primary)),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.searchController,
              onChanged: (value) => controller.searchQuery.value = value,
              style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primaryText),
              decoration: InputDecoration(
                hintText: 'Cari Nama Unit, No Doc...',
                hintStyle: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                filled: true,
                fillColor: AppColors.backgroundGrey,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Rentang Tanggal', style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => controller.pickDateRange(Get.context!),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Obx(() {
                      final start = controller.startDateFilter.value;
                      final end = controller.endDateFilter.value;
                      if (start != null && end != null) {
                        return Text(
                          '${start.day.toString().padLeft(2, '0')}/${start.month.toString().padLeft(2, '0')}/${start.year} - ${end.day.toString().padLeft(2, '0')}/${end.month.toString().padLeft(2, '0')}/${end.year}',
                          style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primaryText),
                        );
                      }
                      return Text(
                        'Pilih Rentang Tanggal...',
                        style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
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

    return Container(
      width: double.infinity,
      color: AppColors.backgroundGrey,
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
                    style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildVolumeItem(
                      'Pengambilan',
                      '${item.aktualLiter}',
                      'Ltr',
                      Icons.arrow_upward_rounded,
                      Colors.blue,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                  Expanded(
                    child: _buildVolumeItem(
                      'Aktual',
                      '${item.aktualLiterTransfer}',
                      'Ltr',
                      Icons.check_circle_outline_rounded,
                      Colors.green,
                    ),
                  ),
                  Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                  Expanded(
                    child: _buildVolumeItem(
                      'Sisa',
                      '${item.varianLiterTransfer}',
                      'Ltr',
                      Icons.info_outline_rounded,
                      AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildVolumeItem(String title, String value, String unit, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          title,
          style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText),
            ),
          ],
        ),
      ],
    );
  }
}
