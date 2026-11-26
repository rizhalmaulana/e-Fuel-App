import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';
import '../component/custom_snackbar.dart';

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

  /// Menampilkan dialog informasi/validasi yang ringkas dan jelas di tengah layar.
  static Future<void> showInfo({
    required String title,
    required String message,
    String buttonText = 'Mengerti',
    Color? color,
    IconData icon = Icons.info_outline_rounded,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    final accentColor = color ?? AppColors.primary;
    await Get.dialog(
      DialogFlexible(
        logo: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 42, color: accentColor),
        ),
        title: title,
        message: message,
        primaryColor: accentColor,
        primaryButtonText: buttonText,
      ),
      barrierDismissible: true,
    );
  }

  /// Menampilkan dialog konfirmasi dengan hasil `true` (konfirmasi) atau `false` (batal).
  static Future<bool> showConfirm({
    required String title,
    required String message,
    Widget? logo,
    String confirmText = 'Ya, Submit',
    String cancelText = 'Batal',
    Color? primaryColor,
  }) async {
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    final bool? result = await Get.dialog<bool>(
      DialogFlexible(
        logo: logo,
        title: title,
        message: message,
        primaryColor: primaryColor,
        primaryButtonText: confirmText,
        secondaryButtonText: cancelText,
      ),
      barrierDismissible: false,
    );
    return result == true;
  }

  /// Menampilkan dialog tunggu dan mengembalikan fungsi penutup yang aman
  /// (hanya menutup dialog tunggu ini saja, tidak akan menutup dialog/snackbar lain
  /// maupun tertinggal terbuka jika [closeLoading] dipanggil sebelum dialog ter-mount).
  static VoidCallback showLoading({
    String title = 'Sedang Memproses...',
    String? subtitle = 'Mohon tunggu sebentar',
    Color? color,
  }) {
    FocusManager.instance.primaryFocus?.unfocus();
    BuildContext? loadingDialogContext;
    bool isClosed = false;
    bool isPopped = false;

    void popIfPossible(BuildContext? ctx) {
      if (isPopped) return;
      if (ctx != null && ctx.mounted) {
        final nav = Navigator.of(ctx, rootNavigator: true);
        if (nav.canPop()) {
          isPopped = true;
          nav.pop();
        }
      }
    }

    void closeLoading() {
      if (isClosed) return;
      isClosed = true;
      popIfPossible(loadingDialogContext);
    }

    Get.dialog(
      PopScope(
        canPop: false,
        child: Builder(
          builder: (dialogCtx) {
            loadingDialogContext = dialogCtx;
            if (isClosed && !isPopped) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                popIfPossible(dialogCtx);
              });
              return const SizedBox.shrink();
            }
            return Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: color ?? AppColors.primary),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                      textAlign: TextAlign.center,
                    ),
                    if (subtitle != null && subtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppFonts.fUrbanistRegular12.copyWith(color: AppColors.secondaryText),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );

    return closeLoading;
  }

  void _handlePrimary(BuildContext context) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    if (onPrimaryPressed != null) {
      onPrimaryPressed!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop(true);
          }
        }
      });
    } else {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(true);
      }
    }
  }

  void _handleSecondary(BuildContext context) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    if (onSecondaryPressed != null) {
      onSecondaryPressed!();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted && ModalRoute.of(context)?.isCurrent == true) {
          if (Navigator.of(context, rootNavigator: true).canPop()) {
            Navigator.of(context, rootNavigator: true).pop(false);
          }
        }
      });
    } else {
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop(false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
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
                    style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                ],

                // 3. Pesan (Jika ada)
                if (message != null) ...[
                  Text(
                    message!,
                    style: AppFonts.fUrbanistRegular12.copyWith(
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
        ),
      ),
    );
  }

  Widget _buildButtonArea(BuildContext context) {
    final bool hasPrimary = primaryButtonText != null;
    final bool hasSecondary = secondaryButtonText != null;

    if (!hasPrimary && !hasSecondary) {
      return const SizedBox.shrink();
    }

    final Color themeColor = primaryColor ?? AppColors.primary;
    Widget buttonWidgets;

    if (hasPrimary && !hasSecondary) {
      buttonWidgets = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => _handlePrimary(context),
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
          onPressed: () => _handleSecondary(context),
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
              onPressed: () => _handleSecondary(context),
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
              onPressed: () => _handlePrimary(context),
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