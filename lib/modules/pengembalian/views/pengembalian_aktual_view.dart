import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../controllers/pengembalian_aktual_controller.dart';

class PengembalianAktualView extends GetView<PengembalianAktualController> {
  const PengembalianAktualView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Pengembalian Solar',
            style: AppFonts.fUrbanistBold18
                .copyWith(color: AppColors.primary)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                color: AppColors.primary, size: 20),
            onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTotalVolumeCard(),
            const SizedBox(height: 24),
            
            // Banner Mode Sensor
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9), // Light green
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sensors, color: Color(0xFF2E7D32), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Mode Sensor Aktif: Data diisi otomatis dan dikunci.',
                      style: AppFonts.fUrbanistMedium12.copyWith(color: const Color(0xFF2E7D32), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            Text('Data Volume Sensor (Auto)', style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText)),
            const SizedBox(height: 16),
            
            _buildTankSection('TANK01', controller.tank1Tinggi, controller.tank1Volume),
            const SizedBox(height: 16),
            _buildTankSection('TANK02', controller.tank2Tinggi, controller.tank2Volume),
            
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: controller.submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 4,
                  shadowColor: AppColors.primary.withOpacity(0.4),
                ),
                child: Text(
                  'Submit',
                  style: AppFonts.fUrbanistBold16.copyWith(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalVolumeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Volume', style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.secondaryText)),
              GestureDetector(
                onTap: controller.refreshStock,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF004D40)),
                    );
                  }
                  return const Icon(Icons.refresh, color: Color(0xFF004D40), size: 20);
                }),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Text(
            '${controller.totalVolume.value} L',
            style: AppFonts.fUrbanistBold24.copyWith(color: const Color(0xFF004D40)),
          )),
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallTankInfo('TANK01', controller.tank1Volume),
              const SizedBox(width: 12),
              _buildSmallTankInfo('TANK02', controller.tank2Volume),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallTankInfo(String label, RxString volumeObs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppFonts.fUrbanistMedium10.copyWith(color: AppColors.secondaryText)),
          const SizedBox(width: 8),
          Obx(() => Text('${volumeObs.value} L', style: AppFonts.fUrbanistBold12.copyWith(color: AppColors.primaryText))),
        ],
      ),
    );
  }

  Widget _buildTankSection(String title, RxString tinggiObs, RxString volumeObs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppFonts.fUrbanistBold14.copyWith(color: AppColors.primaryText)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tinggi', style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => Text(tinggiObs.value, style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.primaryText))),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Volume', style: AppFonts.fUrbanistMedium12.copyWith(color: AppColors.primaryText)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF7F7F7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Obx(() => Text(volumeObs.value, style: AppFonts.fUrbanistRegular14.copyWith(color: AppColors.primaryText))),
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
