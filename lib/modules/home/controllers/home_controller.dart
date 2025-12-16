import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../configs/app_icons.dart';
import '../../../configs/app_lotties.dart';
import '../../../datas/models/auth/auth_response_model.dart';
import '../../../datas/models/master_storage/master_storage_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';

// Services
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../fuel/services/fuel_sensor_service.dart';
import '../../fuel/services/master_data_service.dart';
import '../../notifications/services/notification_service.dart';
import '../../transactions/outstanding_service.dart';

// Models
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';

class HomeController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final FuelSensorService _sensorService = Get.find<FuelSensorService>(); // Tetap di keep jika butuh background process
  final NotificationService _notificationService = Get.find<NotificationService>();
  final MasterDataService _masterDataService = MasterDataService();

  // Data User
  final userName = 'User'.obs;
  final userAddress = 'E000 - Unknown Estate'.obs;
  final unitTitle = 'FLE'.obs;
  final greeting = 'Selamat Datang di Aplikasi e-Fuel'.obs;
  final profileInitials = 'UU'.obs;

  // Data Storage Location
  final storageLocations = <String>[].obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final selectedUnitCode = ''.obs;

  // DATA TANGKI MANUAL (API) - Dipisahkan dari Sensor Service
  final manualTanksList = <VolumeTankDetailModel>[].obs;

  // UI Display
  final totalVolumeDisplay = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;

  // Transaksi
  final ongoingTransactions = <Map<String, dynamic>>[].obs;
  final historyTransactions = <Map<String, dynamic>>[].obs;
  final selectedTransactionTab = 0.obs;
  final outstandingTransactions = <Map<String, dynamic>>[].obs;

  // Permissions
  final deniedPermissionsList = <String>[].obs;
  bool get isPermissionComplete => deniedPermissionsList.isEmpty;

  // Cache Local
  List<UnitToStorageModel> _cachedStorages = [];

  @override
  void onInit() {
    super.onInit();
    _initNotificationPermission();
    checkAndRequestPermissions();

    _loadDataForActiveUser().then((success) {
      if (success) {
        _loadOutstandingTransactions();
        // Jalankan Sync API (Storage -> lalu Tank)
        _syncMasterDataFromServer();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  Future<void> _syncMasterDataFromServer() async {
    try {
      final authData = _loginService.getCurrentAuth();
      final unitCode = authData?.user.userKaryawan.unit.kodeUnit;

      if (unitCode != null && unitCode.isNotEmpty) {
        final apiStorages = await _masterDataService.getStorageFromUnit(unitId: unitCode);

        if (apiStorages.isNotEmpty) {
          await _fuelDataService.saveLocalStorages(apiStorages);
          _cachedStorages = apiStorages;
          loadStorageLocations(unitCode);

          if (storageLocations.isNotEmpty) {
            final firstStorageString = storageLocations.first;
            changeStorageLocation(firstStorageString);
          }
        }
      }
    } catch (e) {
      print("⚠️ [HomeController] Sync Error: $e");
    }
  }

  Future<bool> _loadDataForActiveUser() async {
    final authData = await _loginService.getAuthOrLoad();

    if (authData == null) return false;
    final username = authData.user.username;

    // Init Box
    await _sensorService.initSensorBox(username); // Sensor box tetap di init (jika perlu)
    await _fuelDataService.openFuelDataBox(username); // Manual box

    loadUserData(authData: authData);

    _cachedStorages = _fuelDataService.getLocalStorages();
    if (_cachedStorages.isNotEmpty) {
      loadStorageLocations(selectedUnitCode.value);
    }

    final cachedTanks = _fuelDataService.getApiManualTanks();
    if (cachedTanks.isNotEmpty) {
      manualTanksList.assignAll(cachedTanks);
      _updateUiFromManualData();
    }

    return true;
  }

  void _updateUiFromManualData() {
    double totalVol = 0.0;
    List<Map<String, String>> tempList = [];

    final currentStorageCode = _getStorageCode(selectedStorage.value);

    final activeTanks = manualTanksList.where((t) {
      if (t.masterStorage != null) {
        return t.masterStorage!.kodeStorage == currentStorageCode;
      }
      return true;
    }).toList();

    // Sorting
    activeTanks.sort((a, b) {
      String codeA = a.masterSolarTank?.kodeTank ?? '';
      String codeB = b.masterSolarTank?.kodeTank ?? '';
      return codeA.compareTo(codeB);
    });

    for (var tank in activeTanks) {
      final tankCode = tank.masterSolarTank?.kodeTank ?? 'Unknown';

      double vol = (tank.volume ?? 0).toDouble();
      double h = (tank.height ?? 0).toDouble();

      totalVol += vol;

      tempList.add({
        'code': tankCode.replaceAll('_', ' '),
        'volume': "${vol.toStringAsFixed(0)} Ltr",
        'height': "${h.toStringAsFixed(0)} cm",
      });
    }

    totalVolumeDisplay.value = totalVol;
    tankListDisplay.assignAll(tempList);
  }

  Future<void> _initNotificationPermission() async {
    try {
      await _notificationService.init();
      _notificationService.syncTokenToServer();
    } catch (e) {
      print("Gagal inisialisasi notifikasi: $e");
    }
  }

  Future<void> _loadOutstandingTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final username = authData.user.username;
    final outstandingService = OutstandingService(username);

    // Ambil data gabungan
    final List<dynamic> dataList = await outstandingService.getAllCombinedTransactions();

    final List<Map<String, dynamic>> tempOngoing = [];
    final List<Map<String, dynamic>> tempHistory = [];

    for (var trx in dataList) {
      String title = '';
      String iconPath = '';
      String typeCode = '';
      String noBast = '';
      String noIO = '';
      String dateCreated = '';
      String status = '';
      String amountStr = '';
      String platStr = '';
      String unitStr = '';
      Color iconColor = AppColors.primary; // Default Color

      if (trx is TransactionModel) {
        // --- PENERIMAAN (FIN) ---
        final detail = trx.dataSebelum;
        noBast = trx.noBast;
        status = trx.status;
        dateCreated = trx.dateCreated;
        typeCode = 'FIN';
        title = 'Penerimaan Solar';
        iconPath = AppIcons.icPenerimaan;
        iconColor = AppColors.primary;

        amountStr = "${(detail?.volumeVendor ?? 0).toInt()} Ltr";
        platStr = (detail?.nopolVendor ?? 'Tidak Ada Plat').toUpperCase();
        unitStr = (detail?.kodeUnit ?? '-').toString();

      } else if (trx is TransactionPengeluaranModel) {
        // --- PENGELUARAN (FOT) ---
        final detail = trx.dataPengeluaran;
        noBast = trx.noBast;
        status = trx.status;
        noIO = detail?.noIo ?? '-';
        dateCreated = trx.dateCreated;
        typeCode = 'FOT';
        title = 'Pengeluaran Solar';
        iconPath = AppIcons.icPengeluaran;
        iconColor = AppColors.primaryOrange;

        amountStr = "${(detail?.jumlahPengisianSolar ?? 0).toInt()} Ltr";
        platStr = (detail?.nopolCheck ?? 'Tidak Ada Plat').toUpperCase();
        unitStr = (detail?.unitIO ?? '-').toString();
      }

      final mapData = {
        'noIO': noIO,
        'noBast': noBast,
        'title': title,
        'type': typeCode,
        'date': TextConvertHelper().formatDate(dateCreated),
        'amount': amountStr,
        'plat': platStr,
        'status': status,
        'unit': unitStr,
        'icon': iconPath,
        'desc': unitStr,
        'color': iconColor,
      };

      String statusLower = status.toLowerCase();
      if (statusLower == 'selesai') {
        tempHistory.add(mapData);
      } else {
        tempOngoing.add(mapData);
      }
    }

    ongoingTransactions.assignAll(tempOngoing);
    historyTransactions.assignAll(tempHistory);
  }

  String _getStorageCode(String storageString) {
    final parts = storageString.split(' - ');
    if (parts.length > 1) return parts.last;
    return storageString;
  }

  Future<void> changeStorageLocation(String? newLocation) async {
    if (newLocation != null && newLocation != 'Tidak ada Storage') {
      selectedStorage.value = newLocation;

      final storageCode = _getStorageCode(newLocation);
      final unitCode = selectedUnitCode.value;

      // Reset UI loading state
      totalVolumeDisplay.value = 0.0;
      tankListDisplay.clear();

      await _fetchManualTanksApi(unitCode, storageCode);
    }
  }

  Future<void> _fetchManualTanksApi(String unitCode, String storageCode) async {
    try {
      final tanks = await _masterDataService.getTankDetailFromStorage(
          unitId: unitCode,
          storageId: storageCode
      );

      manualTanksList.assignAll(tanks);
      await _fuelDataService.saveApiManualTanks(tanks);

      // Update UI
      _updateUiFromManualData();

    } catch (e) {
      print("⚠️ Gagal fetch tank manual: $e");
    }
  }

  Future<void> _fetchTanksForStorage(String unitCode, String storageCode) async {
    try {
      final tanks = await _masterDataService.getTankDetailFromStorage(
          unitId: unitCode,
          storageId: storageCode
      );

      if (tanks.isNotEmpty) {
        _sensorService.iotData.assignAll(tanks);
      } else {
        _sensorService.iotData.clear();
      }
    } catch (e) {
      print("⚠️ Gagal fetch tank: $e");
    }
  }

  Future<void> navigateToTransactionDetail(Map<String, dynamic> tx) async {
    String unitVal = tx['unit'] ?? '-';
    String noBast = tx['noBast'] ?? '';
    String status = (tx['status'] ?? '').toString().toLowerCase();
    String type = tx['type'] ?? '';

    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;
    final outstandingService = OutstandingService(authData.user.username);

    if (type == 'FIN') {
      // --- NAVIGASI PENERIMAAN ---
      switch (status) {
        case 'draft':
        case 'proses':
          Get.toNamed(Routes.PENERIMAAN,
              arguments: {'noBast': noBast, 'isResume': true});
          break;
        case 'setelah_pengisian':
          Get.toNamed(Routes.PENERIMAAN_SETELAH, arguments: {'noBast': noBast});
          break;
        case 'verifikasi_bast':
          Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST,
              arguments: {'noBast': noBast});
          break;
        case 'approval_kasie':
        case 'approval_manager':
        case 'selesai':
          Get.toNamed(
              Routes.PENERIMAAN_TRACKING, arguments: {'noBast': noBast});
          break;
        default:
          Get.snackbar("Info", "Status transaksi tidak dikenali: $status");
      }
    } else if (type == 'FOT') {
      final trxPengeluaran = await outstandingService
          .getTransactionPengeluaranByNoBast(noBast);

      if (trxPengeluaran != null) {
        final detail = trxPengeluaran.dataPengeluaran;

        switch (status) {
          case 'pengisian_solar':
          case 'pengisian_solar_pengeluaran':
            Get.toNamed(
                Routes.PENGISIAN_SOLAR_PENGELUARAN,
                arguments: {
                  'noDoc': noBast,
                  'noIO': detail?.noIo,
                  'unitIO': unitVal,
                  'noPolisi': detail?.nopolCheck,
                  'supir_check': detail?.supirCheck,
                  'tanggal': TextConvertHelper().formatDate(trxPengeluaran.dateCreated),
                  'km_pengisian': detail?.kmPengisian?.toString(),
                  'jumlah_pengisian_solar': detail?.jumlahPengisianSolar?.toString(),
                  'status': status,
                }
            );
            break;

          case 'verifikasi_pengeluaran':
            Get.toNamed(
                Routes.PENGISIAN_SOLAR_PENGELUARAN,
                arguments: {
                  'noDoc': noBast,
                  'noIO': detail?.noIo,
                  'unitIO': unitVal,
                  'noPolisi': detail?.nopolCheck,
                  'supir_check': detail?.supirCheck,
                  'tanggal': TextConvertHelper().formatDate(trxPengeluaran.dateCreated),
                  'km_pengisian': detail?.kmPengisian?.toString(),
                  'jumlah_pengisian_solar': detail?.jumlahPengisianSolar?.toString(),
                  'status': status,
                }
            );
            break;

          case 'approval_kasie':
          case 'approval_manager':
          case 'selesai':
            Get.toNamed(
                Routes.PENGELUARAN_TRACKING,
                arguments: {'noBast': noBast}
            );
            break;

          default:
            Get.snackbar("Info", "Status transaksi pengeluaran tidak dikenali: $status");
        }
      } else {
        Get.snackbar("Error", "Data transaksi tidak ditemukan");
      }
    }
  }

  void loadUserData({AuthResponseModel? authData}) {
    final data = authData ?? _loginService.getCurrentAuth();

    if (data != null) {
      final user = data.user;
      final karyawan = user.userKaryawan;

      final firstName = user.firstName ?? '';
      final lastName = user.lastName ?? '';
      final name = firstName.isNotEmpty ? '$firstName $lastName' : user.username;

      final unitCode = karyawan.unit.kodeUnit.isNotEmpty ? karyawan.unit.kodeUnit : 'E000';
      final unitName = karyawan.unit.namaUnit.isNotEmpty ? karyawan.unit.namaUnit : 'Unknown Estate';

      userName.value = name;
      userAddress.value = '$unitCode - $unitName';
      selectedUnitCode.value = unitCode;

      final nameParts = name.trim().split(RegExp(r'\s+'));
      if (nameParts.isNotEmpty) {
        profileInitials.value = (nameParts.length > 1)
            ? "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase()
            : nameParts[0][0].toUpperCase();
      }

      // Load Dropdown dari Cache
      loadStorageLocations(unitCode);
    } else {
      print("❌ [HomeController] loadUserData gagal: Auth Data null");
    }
  }

  void loadStorageLocations(String unitCode) {
    storageLocations.clear();
    List<String> formattedList = [];

    // Loop List<UnitToStorageModel>
    for (var unitData in _cachedStorages) {
      for (MasterStorageModel storage in unitData.masterStorage) {
        if (storage.storageStatus == 'Y') {
          formattedList.add("${storage.namaStorage} - ${storage.kodeStorage}");
        }
      }
    }

    if (formattedList.isNotEmpty) {
      storageLocations.addAll(formattedList);

      if (selectedStorage.value == 'Pilih Lokasi Storage' || selectedStorage.value.isEmpty) {
        Future.delayed(Duration.zero, () {
          changeStorageLocation(storageLocations.first);
        });
      } else if (!storageLocations.contains(selectedStorage.value)) {
        changeStorageLocation(storageLocations.first);
      }

    } else {
      selectedStorage.value = 'Tidak ada Storage';
      _sensorService.iotData.clear();
    }
  }

  void openAppSettingsPage() async {
    await openAppSettings();
    checkAndRequestPermissions();
  }

  void logout() {
    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(AppLotties.question, width: 120, height: 120, repeat: true),
        title: "Konfirmasi Keluar",
        message: "Apakah Anda yakin ingin keluar dari aplikasi? Sesi Anda akan diakhiri.",

        // Tombol Batal
        secondaryButtonText: "Batal",
        onSecondaryPressed: () => Get.back(),

        primaryButtonText: "Ya, Keluar",
        onPrimaryPressed: () async {
          Get.back();

          // Proses Logout
          await _loginService.clearAuthData();
          Get.offAllNamed(Routes.LOGIN);
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> checkAndRequestPermissions() async {
    List<String> currentlyDenied = [];
    var cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) currentlyDenied.add('Kamera');
    }
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
      if (!locationStatus.isGranted) currentlyDenied.add('Lokasi');
    }
    bool needStoragePermission = true;
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      if (androidInfo.version.sdkInt >= 29) {
        needStoragePermission = false;
      }
    }
    if (needStoragePermission) {
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) currentlyDenied.add('Penyimpanan');
      }
    }
    deniedPermissionsList.assignAll(currentlyDenied);
  }
}