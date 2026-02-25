import 'dart:io';
import 'dart:ui';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../configs/app_icons.dart';
import '../../../configs/app_lotties.dart';
import '../../../datas/models/auth/auth_response_model.dart';
import '../../../datas/models/inbound/inbound_model.dart';
import '../../../datas/models/master_storage/master_storage_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../../datas/models/user/user_model.dart';
import '../../../datas/models/volume_tank_detail/volume_tank_detail_model.dart';
import '../../../helpers/connectivity_helper.dart';
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
import '../services/home_service.dart';

class HomeController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final MasterDataService _masterDataService = MasterDataService();
  final ApprovalService _approvalService = ApprovalService();
  final HomeService _homeService = Get.put(HomeService(), permanent: true);

  // Data User
  final userName = 'User'.obs;
  final userAddress = 'E000 - Unknown Estate'.obs;
  final unitTitle = 'FLE'.obs;
  final greeting = 'Selamat Datang di Aplikasi e-Fuel'.obs;
  final profileInitials = 'UU'.obs;
  final isLoading = false.obs;
  final isTankDetailExpanded = false.obs;

  // Menu List dan Unit List (Reactive)
  final selectedMenuCategory = 0.obs;
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
  final lastUpdateTime = '-'.obs;

  // Transaksi
  final selectedTransactionTab = 0.obs;
  final approvalTransactions = <Map<String, dynamic>>[].obs; // Transaksi yang berjalan dan membutuhkan approval
  final outstandingTransactions = <Map<String, dynamic>>[].obs; // Transaksi yang belum dibuat karena tidak dilanjutkan

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

    isLoading.value = true;

    _loadDataForActiveUser().then((success) async {
      if (success) {
        await _initialDataSync();

        isLoading.value = false;
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
    // Cek Koneksi sebelum submit
    if (!await ConnectivityHelper.validateNetwork()) return;

    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

    // Reset list sebelum load ulang agar tidak duplikat saat refresh unit
    outstandingTransactions.clear();
    approvalTransactions.clear();

    if (auth.user.isApprover) {
      await _loadApproverTransactions();
    } else {
      // Load Server
      await _loadServerOpenTransactions();
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

    activeTanks.sort((a, b) {
      String codeA = a.masterSolarTank?.kodeTank ?? '';
      String codeB = b.masterSolarTank?.kodeTank ?? '';
      return codeA.compareTo(codeB);
    });

    for (var tank in activeTanks) {
      final tankCode = tank.masterSolarTank?.kodeTank ?? 'Unknown';
      double vol = (tank.volume ?? 0).toDouble();
      totalVol += vol;

      DateTime? serverTime = DateTime.tryParse(tank.createdAt.toString());
      DateTime localTime = serverTime != null ? serverTime.toLocal() : DateTime.now();
      String formattedTime = DateFormat('dd MMM, HH:mm', 'id_ID').format(localTime);

      tempList.add({
        'code': tankCode.replaceAll('_', ' '), // TANK_01 jadi TANK 01
        'volume': "${TextConvertHelper().formatNumber(vol)} L", // Format angka langsung disini
        'last_update': formattedTime,
      });
    }

    totalVolumeDisplay.value = totalVol;
    tankListDisplay.assignAll(tempList);
  }

  void toggleTankDetail() {
    isTankDetailExpanded.value = !isTankDetailExpanded.value;
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

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  List<Map<String, dynamic>> get filteredMenuList {
    // Kategori Penerimaan
    if (selectedMenuCategory.value == 0) {
      return menuList.where((menu) {
        String action = menu['action'].toString();
        return action.contains('input_penerimaan');
      }).toList();
    } else if (selectedMenuCategory.value == 1) {
      return menuList.where((menu) {
        String action = menu['action'].toString();
        return action.contains('input_pengeluaran') ||
            action.contains('input_e_bpb');
      }).toList();
    } else {
      return menuList.where((menu) {
        String action = menu['action'].toString();
        return action.contains('riwayat');
      }).toList();
    }
  }

  void changeMenuCategory(int index) {
    selectedMenuCategory.value = index;
  }

  Future<void> onRefreshData() async {
    if (!await ConnectivityHelper.validateNetwork()) return;

    isLoading.value = true;

    try {
      await _initialDataSync();

      // Ambil kode saat ini
      if (selectedUnitCode.value.isNotEmpty && selectedStorage.value.isNotEmpty) {
        final storageCode = _getStorageCode(selectedStorage.value);

        // Refresh Firebase dengan path spesifik
        await _homeService.initDataFlow(selectedUnitCode.value, storageCode);

        await _fetchManualTanksApi(selectedUnitCode.value, storageCode);
      }
    } catch (e) {
      print("Error saat refresh: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadApproverTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final user = authData.user;
    // Mengambil level user
    String userLevel = user.otorisasi.isNotEmpty ? user.otorisasi.first : '';
    // Mengambil kode unit
    String kodeUnit = authData.currentKodeUnit ?? '';

    try {
      // Panggil API TANPA memfilter level_approval.
      // Tujuannya agar kita mendapat seluruh rantai approval yang masih PENDING.
      final apiResult = await _approvalService.getApprovalList(
          kodeUnit: kodeUnit,
          levelApproval: null, // <-- Ubah parameter ini menjadi null
          transactionType: "FIN",
          statusApprove: "PENDING"
      );

      // Kelompokkan data berdasarkan noBast
      Map<String, List<dynamic>> groupedApprovals = {};

      for (var item in apiResult) {
        String noBast = item.noBast ?? '-';
        if (!groupedApprovals.containsKey(noBast)) {
          groupedApprovals[noBast] = [];
        }
        groupedApprovals[noBast]!.add(item);
      }

      final List<Map<String, dynamic>> tempApproval = [];

      // Evaluasi setiap dokumen (noBast)
      groupedApprovals.forEach((noBast, approvalList) {

        // Fungsi bantu untuk mengekstrak angka dari string level
        int getLevelNum(String levelStr) {
          final match = RegExp(r'\d+').firstMatch(levelStr);
          return match != null ? int.parse(match.group(0)!) : 99; // Jika tidak ada angka, beri nilai besar
        }

        // Urutkan list approval dari level terkecil ke terbesar
        approvalList.sort((a, b) {
          int levelA = getLevelNum(a.levelApproval ?? '');
          int levelB = getLevelNum(b.levelApproval ?? '');
          return levelA.compareTo(levelB);
        });

        // Cek siapa yang berhak approve saat ini
        // Karena sudah diurutkan, index pertama (.first) adalah level terendah yang masih PENDING
        final activePendingNode = approvalList.first;
        final activePendingLevel = activePendingNode.levelApproval;

        // Jika level yang berhak approve SAMA dengan level user yang sedang login, tampilkan!
        if (activePendingLevel == userLevel) {
          String tglApprove = activePendingNode.tglApprove ?? activePendingNode.createdAt ?? '';

          final mapData = {
            'noBast': noBast,
            'title': 'Penerimaan Solar',
            'type': activePendingNode.transactionType,
            'date': TextConvertHelper().formatDate(tglApprove),
            'status': activePendingNode.statusApprove,
            'unit': kodeUnit,
            'id': activePendingNode.id,
            'source': 'api'
          };

          tempApproval.add(mapData);
        }
      });

      approvalTransactions.assignAll(tempApproval);
    } catch (e) {
      print("Error loading approval transactions: $e");
    }
  }

  Future<void> _loadServerOpenTransactions() async {
    try {
      final authData = _loginService.getCurrentAuth();
      if (authData == null) return;

      final kodeUnit = selectedUnitCode.value;

      // Panggil API untuk mendapatkan list Inbound FIN berstatus Open (O)
      List<InboundModel> apiList = await _masterDataService.getInboundOpenList(
          kodeUnit: kodeUnit,
          statusInbound: 'O',
          docType: 'FIN'
      );

      final List<Map<String, dynamic>> tempOutstanding = [];

      for (var item in apiList) {
        // Cek apakah arrays tanks dan approvals kosong
        bool isDraft = (item.tanks == null || item.tanks!.isEmpty) &&
            (item.approvals == null || item.approvals!.isEmpty);

        // Jika dia adalah Draft, masukkan ke dalam list
        if (isDraft) {
          final mapData = {
            'noBast': item.noDoc ?? '-',
            'title': 'Draft Penerimaan',
            'type': 'FIN',
            'date': TextConvertHelper().formatDate(item.dateInbound),
            'amount': "${(item.volumeVendor ?? 0).toInt()} L",
            'status': 'Draft',
            'unit': item.kodeUnit,
            'source': 'api'
          };

          tempOutstanding.add(mapData);
        }
      }

      // Masukkan ke dalam outstandingTransactions
      outstandingTransactions.assignAll(tempOutstanding);

    } catch (e) {
      print("Error loading server transactions: $e");
    }
  }

  String _getStorageCode(String storageString) {
    final parts = storageString.split(' - ');
    if (parts.length > 1) return parts.last.trim();
    return storageString.trim();
  }

  Future<void> changeStorageLocation(String? newLocation) async {
    if (newLocation != null && newLocation != 'Tidak ada Storage') {
      selectedStorage.value = newLocation;

      // 1. Dapatkan Kode Unit dan Kode Storage
      final unitCode = selectedUnitCode.value;
      final storageCode = _getStorageCode(newLocation);

      totalVolumeDisplay.value = 0.0;
      tankListDisplay.clear();
      manualTanksList.clear();

      // 2. Fetch Data Tangki API (Existing)
      await _fetchManualTanksApi(unitCode, storageCode);

      // 3. Trigger Sync Firebase berdasarkan Unit & Storage terpilih
      // Data HM/KM akan menyesuaikan dengan lokasi ini
      await _homeService.initDataFlow(unitCode, storageCode);
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
    String source = tx['source'] ?? 'local';
    String noBast = tx['noBast'] ?? '';
    String type = tx['type'] ?? '';
    String status = tx['status'] ?? ''; // Ambil status untuk mengecek apakah ini PENDING approval

    // CEK JIKA INI TRANSAKSI APPROVAL (PENDING) DARI SERVER
    if (source == 'api' && status.toUpperCase() == 'PENDING') {
      // Arahkan ke halaman Approval untuk diproses
      Get.toNamed(Routes.APPROVAL, arguments: {
        'noBast': noBast,
        'type': type,
      });
      return; // Hentikan eksekusi di sini agar tidak lanjut ke logika di bawahnya
    }

    // LOGIKA DEFAULT UNTUK TRANSAKSI TRACKING / DRAFT (NON-APPROVER)
    if (source == 'api') {
      if (type == 'FIN') {
        Get.toNamed(Routes.PENERIMAAN_TRACKING, arguments: {'noBast': noBast});
      } else {
        Get.toNamed(Routes.PENGELUARAN_TRACKING, arguments: {'noBast': noBast});
      }
    } else {
      if (type == 'FIN') {
        Get.toNamed(Routes.PENERIMAAN_TRACKING, arguments: {'noBast': noBast});
      } else if (type == 'FOT') {
        Get.toNamed(Routes.PENGELUARAN_TRACKING, arguments: {'noBast': noBast});
      }
    }
  }

  void loadUserData({AuthResponseModel? authData}) async {
    if (authData != null) {
      final user = authData.user;

      final unitCode = authData.currentKodeUnit ?? 'E000';
      final unitName = authData.currentNamaUnit ?? 'Unknown Estate';

      selectedUnitCode.value = unitCode;
      userAddress.value = '$unitCode - $unitName';
      userName.value = authData.currentFullName;

      final nameParts = userName.value.trim().split(RegExp(r'\s+'));
      if (nameParts.isNotEmpty) {
        profileInitials.value = (nameParts.length > 1)
            ? "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase()
            : nameParts[0][0].toUpperCase();
      }

      _prepareAvailableUnits(authData);
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
      'icon': AppIcons.icReportPenerimaan,
      'label': 'Laporan Penerimaan',
      'action': 'riwayat_penerimaan',
    };

    final menuRiwayatPengeluaran = {
      'icon': AppIcons.icReportPengeluaran,
      'label': 'Laporan Pengeluaran',
      'action': 'riwayat_pengeluaran',
    };

    final menuRiwayatEBPB = {
      'icon': AppIcons.icReportEBPB,
      'label': 'Laporan E-BPB',
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

    for (var unitData in _cachedStorages) {
      for (MasterStorageModel storage in unitData.masterStorage) {
        if (storage.storageStatus == 'Y') {
          String item = "${storage.namaStorage} - ${storage.kodeStorage}";
          formattedList.add(item);
        } else {
          print("🛠️ [DEBUG]    -> Skip (Status bukan Y)");
        }
      }
    }

    if (formattedList.isNotEmpty) {
      storageLocations.addAll(formattedList);

      // Logic pemilihan storage awal
      if (selectedStorage.value == 'Pilih Lokasi Storage' ||
          selectedStorage.value.isEmpty) {

        // Pilih storage pertama sebagai default
        final firstStorage = storageLocations.first;

        Future.delayed(Duration.zero, () {
          changeStorageLocation(firstStorage); // Ini akan memicu sync Firebase
        });

      } else if (!storageLocations.contains(selectedStorage.value)) {
        changeStorageLocation(storageLocations.first);
      } else {
        // Jika Storage yang tersimpan valid, kita Trigger Sync manual di sini
        // Karena changeStorageLocation mungkin tidak terpanggil jika value tidak berubah
        final storageCode = _getStorageCode(selectedStorage.value);
        _homeService.initDataFlow(selectedUnitCode.value, storageCode);
      }
    } else {
      // Handle jika tidak ada storage
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
