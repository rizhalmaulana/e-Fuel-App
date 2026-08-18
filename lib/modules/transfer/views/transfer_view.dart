import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/transfer_controller.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import 'transfer_proses_view.dart' as e_fuel_transfer_proses;
import '../controllers/transfer_proses_controller.dart' as e_fuel_transfer_proses_controller;
import '../../../../datas/models/transfer/transfer_solar_model.dart';

class TransferView extends GetView<TransferController> {
  const TransferView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundGrey,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(
            'Transfer Solar',
            style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
          ),
          actions: [
            Obx(() => controller.isSyncing.value
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: AppColors.primaryOrange, strokeWidth: 2),
                    ),
                  )
                : IconButton(
                    icon: const Icon(Icons.sync, color: AppColors.primaryOrange),
                    onPressed: () => controller.syncData(),
                  )),
          ],
          bottom: TabBar(
            labelColor: AppColors.primaryOrange,
            unselectedLabelColor: AppColors.secondaryText,
            indicatorColor: AppColors.primaryOrange,
            indicatorWeight: 3,
            labelStyle: AppFonts.fUrbanistBold14,
            unselectedLabelStyle: AppFonts.fUrbanistMedium14,
            tabs: const [
              Tab(text: 'Daftar Alat Berat'),
              Tab(text: 'Menunggu Upload'),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryOrange));
          }

          return TabBarView(
            children: [
              _buildSyncTab(),
              _buildSavedTab(),
            ],
          );
        }),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showSearchBottomSheet(),
          backgroundColor: AppColors.white,
          mini: true,
          child: const Icon(Icons.search, color: AppColors.primaryOrange),
        ),
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
                      child: Text('Reset Filter', style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryOrange)),
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
                hintText: 'Cari Nama Unit, No Doc, Kode Unit...',
                hintStyle: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                prefixIcon: const Icon(Icons.search, color: AppColors.primaryOrange, size: 20),
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
                    const Icon(Icons.date_range, color: AppColors.primaryOrange, size: 20),
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

  Widget _buildSyncInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 14, color: AppColors.secondaryText),
          const SizedBox(width: 6),
          Obx(() => Text(
            'Terakhir Sync: ${controller.lastSyncTime.value}',
            style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
          )),
        ],
      ),
    );
  }

  Widget _buildSyncTab() {
    return RefreshIndicator(
      onRefresh: () => controller.syncData(),
      color: AppColors.primaryOrange,
      child: Column(
        children: [
          _buildSyncInfo(),
          Expanded(
            child: Obx(() {
              if (controller.filteredPendingList.isEmpty) {
                return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: SizedBox(
              height: Get.height * 0.7,
              child: Center(
                child: Text(
                  'Belum ada Pengeluaran Alat Berat',
                  style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
                ),
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.filteredPendingList.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = controller.filteredPendingList[index];
            return _buildCard(
              item: item,
              actionLabel: 'Proses',
              onAction: () {
                Get.to(
                  () => const e_fuel_transfer_proses.TransferProsesView(),
                  binding: BindingsBuilder(() {
                    Get.put(e_fuel_transfer_proses_controller.TransferProsesController(data: item));
                  }),
                );
              },
            );
          },
        );
      }),
    ),
  ],
),
    );
  }

  Widget _buildSavedTab() {
    return Obx(() {
      if (controller.filteredSavedList.isEmpty) {
        return Center(
          child: Text(
            'Belum ada Data Transaksi yang tersimpan',
            style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText),
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: controller.filteredSavedList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = controller.filteredSavedList[index];
          return _buildCard(
            item: item,
            actionLabel: 'Upload ke Server',
            onAction: () => controller.uploadData(item),
            isUpload: true,
          );
        },
      );
    });
  }

  Widget _buildCard({
    required TransferSolarModel item,
    required String actionLabel,
    required VoidCallback onAction,
    bool isUpload = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_gas_station_rounded,
                color: AppColors.primaryOrange,
                size: 24,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.namaUnit,
                  style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                item.dateInbound,
                style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.confirmation_num_outlined, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Text(item.noDoc, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 14, color: AppColors.secondaryText),
                  const SizedBox(width: 6),
                  Text(item.supirCheck, style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isUpload ? AppColors.alertSoftOrangeSecond : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.show_chart, size: 16, color: AppColors.secondaryText),
                    const SizedBox(width: 6),
                    Text(isUpload ? 'Aktual Pengisian' : 'Total Pengambilan', style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.secondaryText)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${isUpload ? item.inputAktualLiter : item.aktualLiter} Ltr',
                  style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: isUpload ? Colors.green : AppColors.primaryOrange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(isUpload ? Icons.cloud_upload_outlined : Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    actionLabel,
                    style: AppFonts.fUrbanistBold14.copyWith(fontSize: 13, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
