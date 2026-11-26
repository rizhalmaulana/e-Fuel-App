import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/configs/app_fonts.dart';

class CustomSnackbar {
  static OverlayEntry? _currentOverlay;
  static VoidCallback? _currentDismiss;

  static void show({
    required String title,
    required String message,
    Color? backgroundColor,
    Color? textColor,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    // Gunakan overlayContext terlebih dahulu jika tersedia untuk menghindari context Navigator root
    final context = Get.overlayContext ?? Get.context;
    if (context == null) return;

    dismiss();

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) {
      // Fallback ke ScaffoldMessenger standar jika tidak ada Overlay widget di context saat ini
      try {
        final messenger = ScaffoldMessenger.maybeOf(context);
        if (messenger != null) {
          messenger.hideCurrentSnackBar();
          messenger.showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: backgroundColor ?? AppColors.primary,
              duration: duration,
            ),
          );
        }
      } catch (e) {
        print("Fallback SnackBar failed: $e");
      }
      return;
    }
    
    bool isRemoved = false;
    bool isInserted = false;
    late OverlayEntry newOverlay;

    void safeRemove() {
      if (!isRemoved) {
        isRemoved = true;
        if (isInserted) {
          newOverlay.remove();
        }
      }
    }

    newOverlay = OverlayEntry(
      builder: (context) => Align(
        alignment: Alignment.topCenter,
        child: _TopSnackbarWidget(
          title: title,
          message: message,
          backgroundColor: backgroundColor ?? AppColors.primary,
          textColor: textColor ?? Colors.white,
          icon: icon,
          duration: duration,
          onDismiss: () {
            if (_currentOverlay == newOverlay) {
              _currentOverlay = null;
              _currentDismiss = null;
            }
            safeRemove();
          },
        ),
      ),
    );

    _currentOverlay = newOverlay;
    _currentDismiss = safeRemove;
    
    // Gunakan post-frame callback agar pemanggilan safe jika dipicu saat fase build widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        if (!isRemoved && overlay.mounted) {
          overlay.insert(newOverlay);
          isInserted = true;
        }
      } catch (e) {
        print("Gagal memasukkan overlay snackbar: $e");
      }
    });
  }

  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: Colors.green.shade600,
      textColor: Colors.white,
      icon: Icons.check_circle,
      duration: duration,
    );
  }

  static void showError({
    required String title,
    required String message,
    IconData icon = Icons.error_outline_rounded,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.alertSoftRed,
      textColor: Colors.white,
      icon: icon,
      duration: duration,
    );
  }

  static void showWarning({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.primaryOrange,
      textColor: Colors.white,
      icon: Icons.warning_amber_rounded,
      duration: duration,
    );
  }

  static void showInfo({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      title: title,
      message: message,
      backgroundColor: AppColors.info,
      textColor: Colors.white,
      icon: Icons.info_outline_rounded,
      duration: duration,
    );
  }

  static void dismiss() {
    if (_currentDismiss != null) {
      _currentDismiss!();
      _currentOverlay = null;
      _currentDismiss = null;
    }
  }
}

class _TopSnackbarWidget extends StatefulWidget {
  final String title;
  final String message;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;
  final Duration duration;
  final VoidCallback onDismiss;

  const _TopSnackbarWidget({
    required this.title,
    required this.message,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_TopSnackbarWidget> createState() => _TopSnackbarWidgetState();
}

class _TopSnackbarWidgetState extends State<_TopSnackbarWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _controller.forward();

    // Auto dismiss setelah durasi selesai
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.icon != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.textColor.withOpacity(0.16),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.icon,
                        color: widget.textColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.title.isNotEmpty)
                          Text(
                            widget.title,
                            style: AppFonts.fUrbanistBold14.copyWith(
                              color: widget.textColor,
                            ),
                          ),
                        if (widget.title.isNotEmpty) const SizedBox(height: 3),
                        Text(
                          widget.message,
                          style: AppFonts.fUrbanistRegular12.copyWith(
                            color: widget.textColor.withOpacity(0.95),
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
