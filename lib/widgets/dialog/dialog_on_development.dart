import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';
import '../../configs/app_lotties.dart';

class DialogOnDevelopment extends StatelessWidget {
  const DialogOnDevelopment({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: Lottie.asset(
                AppLotties.onDevelopment,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Dalam Pengembangan',
              style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Fitur ini sedang dalam tahap pengembangan dan akan segera tersedia.',
              style: AppFonts.fUrbanistRegular10.copyWith(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Mengerti',
                  style: AppFonts.fUrbanistSemiBold12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}