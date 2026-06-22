import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';
import 'package:e_fuel/configs/app_lotties.dart';
import 'package:e_fuel/configs/app_config.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              const Spacer(flex: 2),
              
              // Animasi Loading / Lottie
              Obx(() {
                final bool isReady = controller.isUpdateReady.value;
                if (isReady) {
                  // Jika update selesai, tampilkan ikon centang/sukses
                  return const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.primary,
                    size: 100,
                  );
                } else {
                  return Lottie.asset(
                    AppLotties.loadingTPA,
                    width: 150,
                    height: 150,
                    animate: true,
                    repeat: true,
                    frameRate: FrameRate.max,
                  );
                }
              }),
              
              const SizedBox(height: 24),
              
              // Status Teks
              Obx(() => Text(
                controller.statusText.value,
                textAlign: TextAlign.center,
                style: AppFonts.fUrbanistBold16.copyWith(
                  color: AppColors.primaryText,
                  height: 1.5,
                ),
              )),
              
              const SizedBox(height: 16),
              
              // Loading indicator tambahan saat mendownload
              Obx(() {
                if (controller.isDownloading.value) {
                  return const SizedBox(
                    width: 120,
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      backgroundColor: AppColors.backgroundGrey,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              const SizedBox(height: 32),
              
              // Tombol Muat Ulang Aplikasi
              Obx(() {
                if (controller.isUpdateReady.value) {
                  return SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.restartApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.white,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Muat Ulang Aplikasi",
                        style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.white),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
              
              const Spacer(flex: 2),
              
              // Informasi Versi di bawah
              Text(
                'versi ${AppConfig.versionProd}',
                textAlign: TextAlign.center,
                style: AppFonts.fUrbanistMedium12.copyWith(
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    ),
  );
}
}
