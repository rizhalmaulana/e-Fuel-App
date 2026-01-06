import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../configs/app_icons.dart';
import '../../../configs/app_lotties.dart';
import '../../../datas/models/auth/auth_response_model.dart';
import '../../../datas/models/master_storage/master_storage_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/user/user_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';

// Services
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../../widgets/dialog/dialog_on_development.dart';
import '../../approval/services/approval_service.dart';
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
  final FuelSensorService _sensorService = Get.find<
      FuelSensorService>(); // Tetap di keep jika butuh background process
  final NotificationService _notificationService =
      Get.find<NotificationService>();
  final MasterDataService _masterDataService = MasterDataService();
  final ApprovalService _approvalService = ApprovalService();

  // Data User
  final userName = 'User'.obs;
  final userAddress = 'E000 - Unknown Estate'.obs;
  final unitTitle = 'FLE'.obs;
  final greeting = 'Selamat Datang di Aplikasi e-Fuel'.obs;
  final profileInitials = 'UU'.obs;

  // Menu List dan Unit List (Reactive)
  final menuList = <Map<String, dynamic>>[].obs;
  final availableUnits = <Map<String, dynamic>>[].obs;

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
        _initialDataSync();
      } else {
        Get.offAllNamed(Routes.LOGIN);
      }
    });
  }

  Future<void> _syncMasterDataFromServer() async {
    try {
      final authData = _loginService.getCurrentAuth();

      if (authData == null) {
        print("⚠️ [LoginController] Auth Data null, skip sync.");
        return;
      }

      final unitCode = authData.currentKodeUnit;

      if (unitCode != null && unitCode.isNotEmpty) {
        final apiStorages =
            await _masterDataService.getStorageFromUnit(unitId: unitCode);

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

  Future<void> _initialDataSync() async {
    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

    if (auth.user.isApprover) {
      _loadApproverTransactions();
    } else {
      _loadOutstandingTransactions();
    }
    _syncMasterDataFromServer();
  }

  Future<bool> _loadDataForActiveUser() async {
    final authData = await _loginService.getAuthOrLoad();

    if (authData == null) return false;
    final username = authData.user.username;

    // Init Box
    await _sensorService
        .initSensorBox(username); // Sensor box tetap di init (jika perlu)
    await _fuelDataService.openFuelDataBox(username); // Manual box

    loadUserData(authData: authData);
    _fetchAndSetUnitTitle(selectedUnitCode.value);

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

  Future<void> _fetchAndSetUnitTitle(String unitCode) async {
    try {
      final allUnits = await _masterDataService.getAllUnits();
      if (allUnits.isNotEmpty) {
        final matched = allUnits.firstWhere(
          (u) => u['kode_unit'] == unitCode,
          orElse: () => {},
        );

        if (matched.isNotEmpty && matched['title_unit'] != null) {
          unitTitle.value = matched['title_unit'];
        }
      }
    } catch (e) {
      print("Error pairing unit title: $e");
    }
  }

  Future<void> _initNotificationPermission() async {
    try {
      await _notificationService.init();
      _notificationService.syncTokenToServer();
    } catch (e) {
      print("Gagal inisialisasi notifikasi: $e");
    }
  }

  Future<void> _loadApproverTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final user = authData.user;
    String userLevel = user.otorisasi.isNotEmpty ? user.otorisasi.first : '';
    String kodeUnit = authData.currentKodeUnit ?? '';

    try {
      final apiResult = await _approvalService.getApprovalList(
        kodeUnit: kodeUnit,
        transactionType: "FIN"
      );

      final List<Map<String, dynamic>> tempOngoing = [];
      final List<Map<String, dynamic>> tempHistory = [];

      for (var item in apiResult) {
        if (item.levelApproval != userLevel) {
          continue;
        }

        String title = 'Penerimaan Solar';
        String iconPath = AppIcons.icPenerimaan;
        Color iconColor = AppColors.primary;

        String displayInfo = item.noBast ?? item.noPo ?? '-';

        final mapData = {
          'noBast': item.noBast,
          'title': title,
          'type': item.transactionType,
          'date':
              TextConvertHelper().formatDate(item.createdAt ?? item.tglApprove),
          'amount': displayInfo,
          'status': item.statusApprove,
          'unit': kodeUnit,
          'icon': iconPath,
          'desc': 'Menunggu Approval Anda',
          'color': iconColor,
          'id': item.id
        };

        // 4. Pisahkan berdasarkan Status
        // Jika status PENDING -> Masuk Tab "Sedang Berjalan" (Agar bisa di klik untuk approval)
        // Jika status APPROVED -> Masuk Tab "Riwayat"

        if (item.statusApprove == 'PENDING') {
          tempOngoing.add(mapData);
        } else {
          mapData['desc'] =
              item.statusApprove == 'APPROVED' ? 'Disetujui' : 'Ditolak';
          tempHistory.add(mapData);
        }
      }

      ongoingTransactions.assignAll(tempOngoing);
      historyTransactions.assignAll(tempHistory);
    } catch (e) {
      print("Error loading approval transactions: $e");
    }
  }

  Future<void> _loadOutstandingTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final username = authData.user.username;
    final outstandingService = OutstandingService(username);

    final List<dynamic> dataList =
        await outstandingService.getAllCombinedTransactions();

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
          unitId: unitCode, storageId: storageCode);

      manualTanksList.assignAll(tanks);
      await _fuelDataService.saveApiManualTanks(tanks);

      // Update UI
      _updateUiFromManualData();
    } catch (e) {
      print("⚠️ Gagal fetch tank manual: $e");
    }
  }

  Future<void> _fetchTanksForStorage(
      String unitCode, String storageCode) async {
    try {
      final tanks = await _masterDataService.getTankDetailFromStorage(
          unitId: unitCode, storageId: storageCode);

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

    if (authData.user.isApprover) {
      Get.toNamed(Routes.APPROVAL, arguments: {
        'noBast': tx['noBast'],
        'type': tx['type'],
      });
      return;

    } else {
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
            Get.toNamed(Routes.PENERIMAAN_SETELAH,
                arguments: {'noBast': noBast});
            break;
          case 'verifikasi_bast':
            Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST,
                arguments: {'noBast': noBast});
            break;
          case 'approval_kasie':
          case 'approval_manager':
          case 'selesai':
            Get.toNamed(Routes.PENERIMAAN_TRACKING,
                arguments: {'noBast': noBast});
            break;
          default:
            Get.snackbar("Info", "Status transaksi tidak dikenali: $status");
        }
      } else if (type == 'FOT') {
        final trxPengeluaran =
            await outstandingService.getTransactionPengeluaranByNoBast(noBast);
        if (trxPengeluaran != null) {
          final detail = trxPengeluaran.dataPengeluaran;

          switch (status) {
            case 'pengisian_solar':
            case 'pengisian_solar_pengeluaran':
              Get.toNamed(Routes.PENGISIAN_SOLAR_PENGELUARAN, arguments: {
                'noDoc': noBast,
                'noIO': detail?.noIo,
                'unitIO': unitVal,
                'noPolisi': detail?.nopolCheck,
                'nama_supir': detail?.supirCheck,
                'tanggal':
                    TextConvertHelper().formatDate(trxPengeluaran.dateCreated),
                'km_pengisian': detail?.kmPengisian?.toString(),
                'jumlah_pengisian_solar':
                    detail?.jumlahPengisianSolar?.toString(),
                'status': status,
              });
              break;

            case 'verifikasi_pengeluaran':
              Get.toNamed(Routes.PENGISIAN_SOLAR_PENGELUARAN, arguments: {
                'noDoc': noBast,
                'noIO': detail?.noIo,
                'unitIO': unitVal,
                'noPolisi': detail?.nopolCheck,
                'nama_supir': detail?.supirCheck,
                'tanggal':
                    TextConvertHelper().formatDate(trxPengeluaran.dateCreated),
                'km_pengisian': detail?.kmPengisian?.toString(),
                'jumlah_pengisian_solar':
                    detail?.jumlahPengisianSolar?.toString(),
                'status': status,
              });
              break;

            case 'approval_kasie':
            case 'approval_manager':
            case 'selesai':
              Get.toNamed(Routes.PENGELUARAN_TRACKING,
                  arguments: {'noBast': noBast});
              break;

            default:
              Get.snackbar("Info",
                  "Status transaksi pengeluaran tidak dikenali: $status");
          }
        } else {
          Get.snackbar("Error", "Data transaksi tidak ditemukan");
        }
      }
    }
  }

  void loadUserData({AuthResponseModel? authData}) async {
    if (authData != null) {
      final user = authData.user;

      // Ambil unit aktif (menghandle level 1 & 2/3 via getter cerdas)
      final unitCode = authData.currentKodeUnit ?? 'E000';
      final unitName = authData.currentNamaUnit ?? 'Unknown Estate';

      selectedUnitCode.value = unitCode;
      userAddress.value = '$unitCode - $unitName';
      userName.value = authData.currentFullName;

      // Setup Inisial Profile
      final nameParts = userName.value.trim().split(RegExp(r'\s+'));
      if (nameParts.isNotEmpty) {
        profileInitials.value = (nameParts.length > 1)
            ? "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase()
            : nameParts[0][0].toUpperCase();
      }

      // Setup Daftar Unit (untuk multi-unit user)
      _prepareAvailableUnits(authData);

      // Ambil Title (TSE, LKE, dsb) via API
      await _fetchAndSetUnitTitle(unitCode);

      _generateUserMenu(user);

      // Load Storage
      _cachedStorages = _fuelDataService.getLocalStorages();
      if (_cachedStorages.isNotEmpty) {
        loadStorageLocations(unitCode);
      }
    }
  }

  void _prepareAvailableUnits(AuthResponseModel authData) {
    availableUnits.clear();
    // Jika User Level 2/3 (Otorisasi Data)
    if (authData.otorisasiData?.unit != null) {
      for (var u in authData.otorisasiData!.unit!) {
        availableUnits.add({
          'id': u.id,
          'kode_unit': u.kodeUnit,
          'nama_unit': u.namaUnit,
        });
      }
    }
    // Jika User Level 1 (Karyawan)
    else if (authData.user.userKaryawan != null) {
      final u = authData.user.userKaryawan!.unit;
      availableUnits.add({
        'id': u.id,
        'kode_unit': u.kodeUnit,
        'nama_unit': u.namaUnit,
      });
    }
  }

  Future<void> switchUnit(Map<String, dynamic> unit) async {
    selectedUnitCode.value = unit['kode_unit'];
    userAddress.value = "${unit['kode_unit']} - ${unit['nama_unit']}";

    // Refresh Data Dashboard
    await _fetchAndSetUnitTitle(unit['kode_unit']);
    await _syncMasterDataFromServer();

    // Refresh Transaksi
    _initialDataSync();
  }

  void _generateUserMenu(UserModel user) {
    menuList.clear();

    final menuInputPenerimaan = {
      'icon': AppIcons.icPenerimaan,
      'label': 'Penerimaan',
      'action': 'input_penerimaan',
    };

    final menuInputPengeluaran = {
      'icon': AppIcons.icPengeluaran,
      'label': 'Pengeluaran',
      'action': 'input_pengeluaran',
    };

    final menuEBPB = {
      'icon': AppIcons.icBpbHarian,
      'label': 'E-BPB',
      'action': 'input_e_bpb',
    };
    // final menuInputBonSementara = {
    //   'icon': AppIcons.icKalibrasi,
    //   'label': 'Bon Sementara',
    //   'action': 'bon_sementara',
    // };

    final menuRiwayatPenerimaan = {
      'icon': AppIcons.icTransactionPenerimaan,
      'label': 'Report Penerimaan',
      'action': 'riwayat_penerimaan',
    };

    final menuRiwayatPengeluaran = {
      'icon': AppIcons.icPenerimaan2,
      'label': 'Report Pengeluaran',
      'action': 'riwayat_pengeluaran',
    };

    final menuRiwayatEBPB = {
      'icon': AppIcons.icKalibrasi,
      'label': 'Report E-BPB',
      'action': 'riwayat_e_bpb',
    };

    if (user.isKrani) {
      menuList.addAll([
        menuInputPenerimaan,
        menuInputPengeluaran,
        menuEBPB,
        // menuInputBonSementara,
        menuRiwayatPenerimaan,
        menuRiwayatPengeluaran,
        menuRiwayatEBPB,
      ]);
    } else if (user.isApprover) {
      menuList.addAll([
        menuRiwayatPenerimaan,
        menuRiwayatPengeluaran,
        menuRiwayatEBPB,
      ]);
    }
  }

  void handleMenuTap(String action, BuildContext context) {
    switch (action) {
      case 'input_penerimaan':
        Get.toNamed(Routes.PENERIMAAN_SEBELUM_FORM);
        break;
      case 'input_pengeluaran':
        Get.toNamed(Routes.PENGELUARAN);
        break;
      case 'input_e_bpb':
        Get.toNamed(Routes.PENGELUARAN_BPB_HARIAN);
        break;
      // case 'bon_sementara':
      //   Get.toNamed(Routes.PENGELUARAN_INPUT_BON_SEMENTARA);
      //   break;
      case 'riwayat_penerimaan':
        Get.toNamed(Routes.REPORT_PENERIMAAN);
        break;
      case 'riwayat_pengeluaran':
        Get.toNamed(Routes.REPORT_PENGELUARAN);
        break;
      case 'riwayat_e_bpb':
        _showDevelopmentModal(context);
        break;
      default:
        _showDevelopmentModal(context);
    }
  }

  void _showDevelopmentModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return const DialogOnDevelopment();
      },
    );
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

      if (selectedStorage.value == 'Pilih Lokasi Storage' ||
          selectedStorage.value.isEmpty) {
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
        logo: Lottie.asset(AppLotties.question,
            width: 120, height: 120, repeat: true),
        title: "Konfirmasi Keluar",
        message:
            "Apakah Anda yakin ingin keluar dari aplikasi? Sesi Anda akan diakhiri.",

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
