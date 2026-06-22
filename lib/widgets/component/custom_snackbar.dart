import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';

class CustomSnackbar {
  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    final context = Get.context;
    if (context == null) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: AppFonts.fUrbanistBold14.copyWith(
                  color: textColor ?? Colors.white,
                ),
              ),
            if (title.isNotEmpty) const SizedBox(height: 4),
            Text(
              message,
              style: AppFonts.fUrbanistRegular12.copyWith(
                color: textColor ?? Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
      ),
    );
  }
}
