import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../helpers/lotties_helper.dart';
import '../services/transfer_offline_service.dart';
import '../../../../datas/models/transfer/transfer_solar_model.dart';
import '../../../../configs/app_colors.dart';
import '../../../../configs/app_fonts.dart';
import '../../../../helpers/connectivity_helper.dart';
import '../../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';

class TransferController extends GetxController {
  final isLoading = false.obs;
  final isSyncing = false.obs;

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
        return dateB.compareTo(dateA);
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
        return dateB.compareTo(dateA);
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
    isSyncing.value = true;

    // Get current kode_unit from active user
    final auth = _loginService.getCurrentAuth();
    final kodeUnit = auth?.currentKodeUnit ?? '';

    if (kodeUnit.isEmpty) {
      if (!isAuto) {
        Get.snackbar('Error', 'Kode Unit tidak ditemukan',
            backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      }
      isSyncing.value = false;
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
        Get.snackbar('Gagal',
            'Gagal mensinkronisasi data, periksa koneksi internet Anda',
            backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      }
    }

    isSyncing.value = false;
  }

  Future<void> uploadData(TransferSolarModel data) async {
    // Cek Koneksi
    bool isOnline = await ConnectivityHelper.isConnected();
    if (!isOnline) {
      Get.snackbar(
        'Offline',
        'Koneksi internet diperlukan untuk mengunggah data.',
        backgroundColor: AppColors.alertSoftRed,
        colorText: Colors.white,
      );
      return;
    }

    // Tampilkan Dialog Konfirmasi
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieQuestion(),
        title: 'Konfirmasi Upload',
        message: 'Apakah Anda yakin ingin mengunggah transaksi ini ke server?',
        primaryColor: AppColors.primaryOrange,
        secondaryColor: AppColors.secondaryOrange,
        primaryButtonText: 'Ya, Upload',
        onPrimaryPressed: () {
          Get.back(); // close dialog
          _processUpload(data);
        },
        secondaryButtonText: 'Batal',
        onSecondaryPressed: () => Get.back(),
      ),
    );
  }

  Future<void> _processUpload(TransferSolarModel data) async {
    // Show loading dialog
    Get.dialog(
      const Center(
          child: CircularProgressIndicator(color: AppColors.primaryOrange)),
      barrierDismissible: false,
    );

    try {
      bool success = await offlineService.uploadTransfer(data);
      Get.back(); // close dialog

      if (success) {
        loadLocalData();
        Get.snackbar('Sukses', 'Data berhasil diupload ke server',
            backgroundColor: Colors.green, colorText: Colors.white);
      }
    } catch (e) {
      Get.back(); // close dialog
      String displayError = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('Gagal', displayError,
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white, duration: const Duration(seconds: 5));
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
