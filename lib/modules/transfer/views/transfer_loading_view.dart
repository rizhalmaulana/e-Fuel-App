import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import 'transfer_konfirmasi_view.dart';
import '../controllers/transfer_konfirmasi_controller.dart';

import '../../../../datas/models/transfer/transfer_solar_model.dart';

class TransferLoadingView extends StatelessWidget {
  final TransferSolarModel data;
  
  const TransferLoadingView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGrey, // Warna latar sedikit abu agar card terlihat
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryOrange, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Proses Transfer',
          style: AppFonts.fUrbanistBold18.copyWith(color: AppColors.primaryOrange),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Main Status Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryOrange.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Lottie Animation inside a subtle circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withOpacity(0.05),
                            shape: BoxShape.circle,
                          ),
                          child: LottiesHelper().getLottieFuelPengeluaran(),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Sedang Memproses',
                          style: AppFonts.fUrbanistBold20.copyWith(color: AppColors.primaryOrange),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Silahkan lakukan Transfer Solar\ndari Baby Tank ke Alat Berat!!',
                          textAlign: TextAlign.center,
                          style: AppFonts.fUrbanistMedium14.copyWith(color: AppColors.primaryText, height: 1.5),
                        ),
                        const SizedBox(height: 32),
                        // Information Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundGrey.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline, color: AppColors.primaryOrange, size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Pastikan selang terhubung dengan baik dan aliran solar lancar sebelum menekan tombol selesai.',
                                  style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText, height: 1.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Action Container with Shadow
          Container(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.15),
                  offset: const Offset(0, -4),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {
                  Get.off(
                    () => const TransferKonfirmasiView(),
                    binding: BindingsBuilder(() {
                      Get.put(TransferKonfirmasiController(data: data));
                    }),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Selesai Transfer',
                      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
