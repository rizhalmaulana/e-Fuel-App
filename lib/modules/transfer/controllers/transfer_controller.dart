import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helpers/lotties_helper.dart';
import '../services/transfer_offline_service.dart';
import '../../../../datas/models/transfer/transfer_solar_model.dart';
import '../../../../configs/app_colors.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../helpers/network_error_helper.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';

class TransferController extends GetxController {
  final isLoading = false.obs;
  final isSyncing = false.obs;
  final isCheckingUpload = false.obs;

  final pendingList = <TransferSolarModel>[].obs;
  final savedList = <TransferSolarModel>[].obs;

  final searchQuery = ''.obs;
  final TextEditingController searchController = TextEditingController();
  final lastSyncTime = '-'.obs;
  
  final startDateFilter = Rxn<DateTime>();
  final endDateFilter = Rxn<DateTime>();

  late TransferOfflineService offlineService;
  final LoginService _loginService = Get.find<LoginService>();

  @override
  void onInit() {
    super.onInit();
    offlineService = Get.put(TransferOfflineService());
    _initData();
  }

  Future<void> _initData() async {
    isLoading.value = true;
    await offlineService.initBox();

    // Cek koneksi
    bool hasInternet = await ConnectivityHelper.isConnected();

    if (hasInternet) {
      // Jika online, tunggu sync selesai. Selama proses ini isLoading = true (muncul loading)
      await syncData(isAuto: true);
    }

    // Load data lokal (jika offline langsung ke sini, jadi instan. Jika online, load data hasil sync)
    loadLocalData();

    isLoading.value = false;
  }

  void loadLocalData() {
    pendingList.assignAll(offlineService.getPendingTransfers());
    savedList.assignAll(offlineService.getSavedTransfers());
    lastSyncTime.value = offlineService.getLastSyncTime();
  }

  List<TransferSolarModel> get filteredPendingList {
    var result = pendingList.toList();

    if (startDateFilter.value != null && endDateFilter.value != null) {
      result = result.where((item) {
        if (item.dateInbound.isEmpty || item.dateInbound == '-') return false;
        try {
          final itemDate = DateTime.parse(item.dateInbound);
          final start = startDateFilter.value!;
          final end = endDateFilter.value!.add(const Duration(hours: 23, minutes: 59, seconds: 59));
          return itemDate.isAfter(start.subtract(const Duration(seconds: 1))) && itemDate.isBefore(end.add(const Duration(seconds: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) => 
        item.namaUnit.toLowerCase().contains(query) || 
        item.noDoc.toLowerCase().contains(query) ||
        item.kodeUnit.toLowerCase().contains(query)
      ).toList();
    }

    result.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.dateInbound);
        DateTime dateB = DateTime.parse(b.dateInbound);
        int dateComparison = dateB.compareTo(dateA);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return b.noDoc.compareTo(a.noDoc);
      } catch (e) {
        return 0;
      }
    });

    return result;
  }

  List<TransferSolarModel> get filteredSavedList {
    var result = savedList.toList();

    if (startDateFilter.value != null && endDateFilter.value != null) {
      result = result.where((item) {
        if (item.dateInbound.isEmpty || item.dateInbound == '-') return false;
        try {
          final itemDate = DateTime.parse(item.dateInbound);
          final start = startDateFilter.value!;
          final end = endDateFilter.value!.add(const Duration(hours: 23, minutes: 59, seconds: 59));
          return itemDate.isAfter(start.subtract(const Duration(seconds: 1))) && itemDate.isBefore(end.add(const Duration(seconds: 1)));
        } catch (e) {
          return false;
        }
      }).toList();
    }

    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      result = result.where((item) => 
        item.namaUnit.toLowerCase().contains(query) || 
        item.noDoc.toLowerCase().contains(query) ||
        item.kodeUnit.toLowerCase().contains(query)
      ).toList();
    }

    result.sort((a, b) {
      try {
        DateTime dateA = DateTime.parse(a.dateInbound);
        DateTime dateB = DateTime.parse(b.dateInbound);
        int dateComparison = dateB.compareTo(dateA);
        if (dateComparison != 0) {
          return dateComparison;
        }
        return b.noDoc.compareTo(a.noDoc);
      } catch (e) {
        return 0;
      }
    });

    return result;
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('id', 'ID'),
      initialDateRange: startDateFilter.value != null && endDateFilter.value != null
          ? DateTimeRange(start: startDateFilter.value!, end: endDateFilter.value!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryOrange,
              onPrimary: Colors.white,
              onSurface: AppColors.primaryText,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDateFilter.value = picked.start;
      endDateFilter.value = picked.end;
    }
  }

  void resetFilters() {
    searchController.clear();
    searchQuery.value = '';
    startDateFilter.value = null;
    endDateFilter.value = null;
  }

  Future<void> syncData({bool isAuto = false}) async {
    if (isSyncing.value) return;
    isSyncing.value = true;

    try {
      if (!isAuto) {
        final hasInternet = await ConnectivityHelper.validateNetwork(
          title: 'Tidak Ada Jaringan',
          message:
              'Gagal menyinkronkan data Transfer Solar karena tidak ada koneksi internet. Pastikan jaringan Anda aktif, lalu coba lagi.',
        );
        if (!hasInternet) return;
      }

      // Get current kode_unit from active user
      final auth = _loginService.getCurrentAuth();
      final kodeUnit = auth?.currentKodeUnit ?? '';

      if (kodeUnit.isEmpty) {
        if (!isAuto) {
          DialogFlexible.showInfo(
            title: 'Gagal Sinkronisasi',
            message: 'Kode Unit tidak ditemukan. Silakan muat ulang halaman.',
            color: AppColors.alertSoftRed,
            icon: Icons.error_outline_rounded,
          );
        }
        return;
      }

      bool success = await offlineService.syncDataFromBE(kodeUnit);
      if (success) {
        loadLocalData();
        if (!isAuto) {
          Get.snackbar('Sukses', 'Data berhasil disinkronisasi',
              backgroundColor: Colors.green, colorText: Colors.white);
        }
      } else {
        if (!isAuto) {
          DialogFlexible.showInfo(
            title: 'Gagal Sinkronisasi',
            message:
                'Gagal menyinkronkan data dari server. Periksa koneksi internet Anda lalu coba lagi.',
            color: AppColors.alertSoftRed,
            icon: Icons.wifi_off_rounded,
          );
        }
      }
    } finally {
      isSyncing.value = false;
    }
  }

  bool _isProcessRunning = false;

  Future<void> uploadData(TransferSolarModel data) async {
    if (_isProcessRunning) return;
    _isProcessRunning = true;
    isCheckingUpload.value = true;

    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();

      final isOnline = await ConnectivityHelper.validateNetwork(
        title: 'Tidak Ada Jaringan',
        message:
            'Gagal mengunggah data Transfer Solar karena tidak ada koneksi internet. Pastikan jaringan Anda aktif, lalu coba lagi.',
      );
      isCheckingUpload.value = false;

      if (!isOnline) {
        _isProcessRunning = false;
        return;
      }

      final confirm = await DialogFlexible.showConfirm(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Konfirmasi Upload',
        message: 'Apakah Anda yakin ingin mengunggah transaksi ini ke server?',
        primaryColor: AppColors.primaryOrange,
        confirmText: 'Ya, Upload',
        cancelText: 'Batal',
      );

      if (confirm) {
        await Future.delayed(const Duration(milliseconds: 150));
        await _processUpload(data);
      } else {
        _isProcessRunning = false;
      }
    } catch (e) {
      isCheckingUpload.value = false;
      _isProcessRunning = false;
      DialogFlexible.showInfo(
        title: 'Gagal Upload',
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.wifi_off_rounded,
      );
    }
  }

  Future<void> uploadAllData() async {
    if (_isProcessRunning) return;

    final dataToUpload = filteredSavedList.toList();
    if (dataToUpload.isEmpty) return;

    _isProcessRunning = true;
    isCheckingUpload.value = true;
    try {
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isSnackbarOpen) Get.closeAllSnackbars();

      final isOnline = await ConnectivityHelper.validateNetwork(
        title: 'Tidak Ada Jaringan',
        message:
            'Gagal mengunggah ${dataToUpload.length} data Transfer Solar karena tidak ada koneksi internet. Pastikan jaringan Anda aktif, lalu coba lagi.',
      );
      isCheckingUpload.value = false;

      if (!isOnline) {
        _isProcessRunning = false;
        return;
      }

      final confirm = await DialogFlexible.showConfirm(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Konfirmasi Upload Semua',
        message:
            'Apakah Anda yakin ingin mengunggah ${dataToUpload.length} transaksi ini ke server?',
        primaryColor: AppColors.primaryOrange,
        confirmText: 'Upload Semua',
        cancelText: 'Batal',
      );

      if (confirm) {
        await Future.delayed(const Duration(milliseconds: 150));
        await _processUploadAll(dataToUpload);
      } else {
        _isProcessRunning = false;
      }
    } catch (e) {
      isCheckingUpload.value = false;
      _isProcessRunning = false;
      DialogFlexible.showInfo(
        title: 'Gagal Upload',
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.wifi_off_rounded,
      );
    }
  }

  Future<void> _processUpload(TransferSolarModel data) async {
    final closeLoading = DialogFlexible.showLoading(
      title: "Proses Upload...",
      subtitle: "Mohon tunggu sebentar",
      color: AppColors.primaryOrange,
    );

    try {
      bool success = await offlineService.uploadTransfer(data);
      closeLoading();

      if (success) {
        loadLocalData();
        Get.snackbar('Sukses', 'Data berhasil diupload.',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        DialogFlexible.showInfo(
          title: 'Gagal Upload',
          message: 'Data gagal diupload. Silakan coba lagi.',
          color: AppColors.alertSoftRed,
          icon: Icons.error_outline_rounded,
        );
      }
    } catch (e) {
      closeLoading();
      DialogFlexible.showInfo(
        title: 'Gagal Upload',
        message: NetworkErrorHelper.getFriendlyErrorMessage(e),
        color: AppColors.alertSoftRed,
        icon: Icons.wifi_off_rounded,
      );
    } finally {
      closeLoading();
      _isProcessRunning = false;
    }
  }

  Future<void> _processUploadAll(List<TransferSolarModel> dataList) async {
    final closeLoading = DialogFlexible.showLoading(
      title: "Proses Upload...",
      subtitle: "Mohon tunggu sebentar",
      color: AppColors.primaryOrange,
    );

    int successCount = 0;
    int failCount = 0;
    String? lastErrorMessage;

    try {
      for (var data in dataList) {
        try {
          bool success = await offlineService.uploadTransfer(data);
          if (success) {
            successCount++;
          } else {
            failCount++;
          }
        } catch (e) {
          failCount++;
          lastErrorMessage = NetworkErrorHelper.getFriendlyErrorMessage(e);
        }
      }

      closeLoading();
      loadLocalData();

      if (failCount == 0) {
        Get.snackbar('Sukses', '$successCount data berhasil diupload.',
            backgroundColor: Colors.green, colorText: Colors.white);
      } else if (successCount == 0) {
        DialogFlexible.showInfo(
          title: 'Gagal Upload',
          message: lastErrorMessage ??
              'Semua ($failCount) data gagal diupload. Pastikan koneksi internet Anda stabil lalu coba lagi.',
          color: AppColors.alertSoftRed,
          icon: Icons.wifi_off_rounded,
        );
      } else {
        final detail = lastErrorMessage != null ? '\n$lastErrorMessage' : '';
        DialogFlexible.showInfo(
          title: 'Upload Sebagian Gagal',
          message:
              '$successCount berhasil, $failCount gagal diupload. Silakan coba lagi.$detail',
          color: AppColors.primaryOrange,
          icon: Icons.warning_amber_rounded,
        );
      }
    } finally {
      closeLoading();
      _isProcessRunning = false;
    }
  }

  // Not used anymore since date is from API, but keep if needed elsewhere
  final selectedDate = DateTime.now().obs;

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE67E22),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate.value) {
      selectedDate.value = picked;
    }
  }

  String get formattedDate {
    return "${selectedDate.value.day.toString().padLeft(2, '0')}/${selectedDate.value.month.toString().padLeft(2, '0')}/${selectedDate.value.year}";
  }
}
