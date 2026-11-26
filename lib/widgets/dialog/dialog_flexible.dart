import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_fonts.dart';
import '../../helpers/network_error_helper.dart';
import '../component/custom_snackbar.dart';

/// Hasil eksekusi dialog aksi tunggal ([DialogFlexible.confirmAndRun] / [DialogFlexible.runWithLoading]).
class ActionDialogResult<T> {
  final bool confirmed;
  final bool succeeded;
  final T? data;
  final String? errorMessage;

  const ActionDialogResult._({
    required this.confirmed,
    required this.succeeded,
    this.data,
    this.errorMessage,
  });

  const ActionDialogResult.cancelled()
      : confirmed = false,
        succeeded = false,
        data = null,
        errorMessage = null;

  const ActionDialogResult.success(T? value)
      : confirmed = true,
        succeeded = true,
        data = value,
        errorMessage = null;

  const ActionDialogResult.failed(String message)
      : confirmed = true,
        succeeded = false,
        data = null,
        errorMessage = message;
}

class DialogFlexible extends StatelessWidget {
  static bool _isAtomicDialogOpen = false;
  static bool _isInfoDialogOpen = false;

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
  /// Dijaga oleh lock global agar tidak menumpuk jika tombol ditekan berulang.
  static Future<void> showInfo({
    required String title,
    required String message,
    String buttonText = 'Mengerti',
    Color? color,
    IconData icon = Icons.info_outline_rounded,
  }) async {
    if (_isInfoDialogOpen || _isAtomicDialogOpen) return;
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    _isInfoDialogOpen = true;
    try {
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
    } finally {
      _isInfoDialogOpen = false;
    }
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
    if (_isAtomicDialogOpen) return false;
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    _isAtomicDialogOpen = true;
    try {
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
    } finally {
      _isAtomicDialogOpen = false;
    }
  }

  /// Alur SATU DIALOG TUNGGAL (Konfirmasi -> Loading in-place -> Tutup otomatis saat sukses
  /// atau tampilkan error in-place saat gagal).
  ///
  /// Menghilangkan sepenuhnya race condition penumpukan 3 dialog beruntun
  /// (Konfirmasi -> Loading -> Berhasil/Gagal) dan kebal terhadap double-tap.
  static Future<ActionDialogResult<T>> confirmAndRun<T>({
    required String title,
    required String message,
    Widget? logo,
    String confirmText = 'Ya, Submit',
    String cancelText = 'Batal',
    Color? primaryColor,
    String loadingTitle = 'Sedang Memproses...',
    String loadingSubtitle = 'Mohon tunggu sebentar',
    String errorTitle = 'Gagal Memproses',
    required Future<T> Function() onConfirm,
    bool showErrorInDialog = true,
  }) async {
    if (_isAtomicDialogOpen) return const ActionDialogResult.cancelled();
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    _isAtomicDialogOpen = true;
    try {
      final ctx = Get.overlayContext ?? Get.context;
      final ActionDialogResult<T>? result;
      final widget = _AtomicActionDialog<T>(
        initialStage: _AtomicActionStage.confirm,
        logo: logo,
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        primaryColor: primaryColor ?? AppColors.primary,
        loadingTitle: loadingTitle,
        loadingSubtitle: loadingSubtitle,
        errorTitle: errorTitle,
        onExecute: onConfirm,
        showErrorInDialog: showErrorInDialog,
      );

      if (ctx != null) {
        result = await showDialog<ActionDialogResult<T>>(
          context: ctx,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (_) => widget,
        );
      } else {
        result = await Get.dialog<ActionDialogResult<T>>(
          widget,
          barrierDismissible: false,
        );
      }

      return result ?? const ActionDialogResult.cancelled();
    } finally {
      _isAtomicDialogOpen = false;
    }
  }

  /// Alur SATU DIALOG TUNGGAL langsung masuk ke Loading -> Tutup otomatis saat sukses
  /// atau tampilkan error in-place saat gagal (untuk aksi tanpa tahap konfirmasi, mis. Approval).
  static Future<ActionDialogResult<T>> runWithLoading<T>({
    Color? primaryColor,
    String loadingTitle = 'Sedang Memproses...',
    String loadingSubtitle = 'Mohon tunggu sebentar',
    String errorTitle = 'Gagal Memproses',
    required Future<T> Function() task,
    bool showErrorInDialog = true,
  }) async {
    if (_isAtomicDialogOpen) return const ActionDialogResult.cancelled();
    FocusManager.instance.primaryFocus?.unfocus();
    CustomSnackbar.dismiss();
    if (Get.isSnackbarOpen) Get.closeAllSnackbars();

    _isAtomicDialogOpen = true;
    try {
      final ctx = Get.overlayContext ?? Get.context;
      final ActionDialogResult<T>? result;
      final widget = _AtomicActionDialog<T>(
        initialStage: _AtomicActionStage.loading,
        primaryColor: primaryColor ?? AppColors.primary,
        loadingTitle: loadingTitle,
        loadingSubtitle: loadingSubtitle,
        errorTitle: errorTitle,
        onExecute: task,
        showErrorInDialog: showErrorInDialog,
      );

      if (ctx != null) {
        result = await showDialog<ActionDialogResult<T>>(
          context: ctx,
          useRootNavigator: true,
          barrierDismissible: false,
          builder: (_) => widget,
        );
      } else {
        result = await Get.dialog<ActionDialogResult<T>>(
          widget,
          barrierDismissible: false,
        );
      }

      return result ?? const ActionDialogResult.cancelled();
    } finally {
      _isAtomicDialogOpen = false;
    }
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

enum _AtomicActionStage { confirm, loading, error }

class _AtomicActionDialog<T> extends StatefulWidget {
  final _AtomicActionStage initialStage;
  final Widget? logo;
  final String? title;
  final String? message;
  final String confirmText;
  final String cancelText;
  final Color primaryColor;
  final String loadingTitle;
  final String loadingSubtitle;
  final String errorTitle;
  final Future<T> Function() onExecute;
  final bool showErrorInDialog;

  const _AtomicActionDialog({
    required this.initialStage,
    this.logo,
    this.title,
    this.message,
    this.confirmText = 'Ya, Submit',
    this.cancelText = 'Batal',
    required this.primaryColor,
    required this.loadingTitle,
    required this.loadingSubtitle,
    required this.errorTitle,
    required this.onExecute,
    required this.showErrorInDialog,
  });

  @override
  State<_AtomicActionDialog<T>> createState() => _AtomicActionDialogState<T>();
}

class _AtomicActionDialogState<T> extends State<_AtomicActionDialog<T>> {
  late _AtomicActionStage _stage;
  String? _errorMessage;
  bool _isExecuting = false;
  bool _isPopped = false;

  @override
  void initState() {
    super.initState();
    _stage = widget.initialStage;
    if (_stage == _AtomicActionStage.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _runExecution();
      });
    }
  }

  void _safePop(ActionDialogResult<T> result) {
    if (_isPopped || !mounted) return;
    _isPopped = true;
    final nav = Navigator.of(context, rootNavigator: true);
    if (nav.canPop()) {
      nav.pop(result);
    }
  }

  Future<void> _runExecution() async {
    if (_isExecuting || _isPopped) return;
    _isExecuting = true;

    if (mounted && _stage != _AtomicActionStage.loading) {
      setState(() {
        _stage = _AtomicActionStage.loading;
        _errorMessage = null;
      });
    }

    try {
      final T data = await widget.onExecute();
      _safePop(ActionDialogResult<T>.success(data));
    } catch (e) {
      final friendly = NetworkErrorHelper.getFriendlyErrorMessage(e);
      if (!widget.showErrorInDialog) {
        _safePop(ActionDialogResult<T>.failed(friendly));
        return;
      }
      if (mounted) {
        setState(() {
          _stage = _AtomicActionStage.error;
          _errorMessage = friendly;
          _isExecuting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isNetworkError = (_errorMessage ?? '').toLowerCase().contains('internet') ||
        (_errorMessage ?? '').toLowerCase().contains('jaringan') ||
        (_errorMessage ?? '').toLowerCase().contains('koneksi');

    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SafeArea(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: _buildStageContent(isNetworkError),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStageContent(bool isNetworkError) {
    switch (_stage) {
      case _AtomicActionStage.confirm:
        return SingleChildScrollView(
          key: const ValueKey('confirm'),
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.logo != null) ...[
                widget.logo!,
                const SizedBox(height: 16),
              ],
              if (widget.title != null) ...[
                Text(
                  widget.title!,
                  style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              if (widget.message != null)
                Text(
                  widget.message!,
                  style: AppFonts.fUrbanistRegular12.copyWith(
                    color: AppColors.secondaryText,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _safePop(const ActionDialogResult.cancelled()),
                      style: TextButton.styleFrom(
                        backgroundColor: widget.primaryColor.withOpacity(0.1),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.cancelText,
                        style: AppFonts.fUrbanistSemiBold12
                            .copyWith(color: widget.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _runExecution,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.primaryColor,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        widget.confirmText,
                        style: AppFonts.fUrbanistSemiBold12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      case _AtomicActionStage.loading:
        return Padding(
          key: const ValueKey('loading'),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: widget.primaryColor),
              const SizedBox(height: 20),
              Text(
                widget.loadingTitle,
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.primaryText),
                textAlign: TextAlign.center,
              ),
              if (widget.loadingSubtitle.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.loadingSubtitle,
                  style: AppFonts.fUrbanistRegular12
                      .copyWith(color: AppColors.secondaryText),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );

      case _AtomicActionStage.error:
        return SingleChildScrollView(
          key: const ValueKey('error'),
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.alertSoftRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isNetworkError
                      ? Icons.wifi_off_rounded
                      : Icons.error_outline_rounded,
                  size: 42,
                  color: AppColors.alertSoftRed,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.errorTitle,
                style: AppFonts.fUrbanistBold16.copyWith(color: AppColors.darkText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Terjadi kendala saat memproses data.',
                style: AppFonts.fUrbanistRegular12.copyWith(
                  color: AppColors.secondaryText,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _safePop(
                    ActionDialogResult<T>.failed(
                      _errorMessage ?? 'Terjadi kendala saat memproses data.',
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.alertSoftRed,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Tutup', style: AppFonts.fUrbanistSemiBold12),
                ),
              ),
            ],
          ),
        );
    }
  }
}