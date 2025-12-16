import 'package:flutter/material.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';

class DialogFlexible extends StatelessWidget {
  final Widget? logo;
  final String? title;
  final String? message;
  final String? primaryButtonText;
  final VoidCallback? onPrimaryPressed;
  final String? secondaryButtonText;
  final VoidCallback? onSecondaryPressed;
  final Color? primaryColor;
  final Color? secondaryColor;

  const DialogFlexible({
    super.key,
    this.logo,
    this.title,
    this.message,
    this.primaryButtonText,
    this.onPrimaryPressed,
    this.secondaryButtonText,
    this.onSecondaryPressed,
    this.primaryColor,
    this.secondaryColor,
  });

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
            if (logo != null) ...[
              logo!,
              const SizedBox(height: 16),
            ],

            if (title != null) ...[
              Text(
                title!,
                style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.darkText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
            ],

            // 3. Pesan (Jika ada)
            if (message != null) ...[
              Text(
                message!,
                style: AppFonts.fUrbanistRegular10.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            _buildButtonArea(context),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonArea(BuildContext context) {
    final bool hasPrimary = primaryButtonText != null && onPrimaryPressed != null;
    final bool hasSecondary = secondaryButtonText != null && onSecondaryPressed != null;

    if (!hasPrimary && !hasSecondary) {
      return const SizedBox.shrink();
    }

    final Color themeColor = primaryColor ?? AppColors.primary;
    Widget buttonWidgets;

    if (hasPrimary && !hasSecondary) {
      buttonWidgets = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPrimaryPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: AppColors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(primaryButtonText!, style: AppFonts.fUrbanistSemiBold12),
        ),
      );
    } else if (!hasPrimary && hasSecondary) {
      buttonWidgets = SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: onSecondaryPressed,
          style: TextButton.styleFrom(
            backgroundColor: themeColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: Text(secondaryButtonText!, style: AppFonts.fUrbanistSemiBold12.copyWith(color: themeColor)),
        ),
      );
    } else {
      buttonWidgets = Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: onSecondaryPressed,
              style: TextButton.styleFrom(
                backgroundColor: themeColor.withOpacity(0.1),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(secondaryButtonText!, style: AppFonts.fUrbanistSemiBold12.copyWith(color: themeColor)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: onPrimaryPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: themeColor,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(primaryButtonText!, style: AppFonts.fUrbanistSemiBold12),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: buttonWidgets,
    );
  }
}