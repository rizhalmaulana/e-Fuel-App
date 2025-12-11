import 'dart:convert';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_fuel/helpers/string_helper.dart';
import 'package:e_fuel/modules/auth/services/login_service.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../configs/app_icons.dart';
import '../../../datas/dummy/master_tank_dummy.dart';
import '../../../datas/dummy/master_unit_dummy.dart';
import '../../../datas/dummy/master_storage_dummy.dart';
import '../../../datas/dummy/master_unit_storage_dummy.dart';
import '../../../datas/dummy/child_storage_tank_dummy.dart';
import '../../../datas/models/fuel/fuel_model.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../routes/app_pages.dart';
import '../../fuel/services/fuel_sensor_service.dart';
import '../../notifications/services/notification_service.dart';
import '../../penerimaan/services/draft_penerimaan_service.dart';
import '../../transactions/penerimaan/services/outstanding_service.dart';

class HomeController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();

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

  final totalVolumeDisplay = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;

  final ongoingTransactions = <Map<String, dynamic>>[].obs;
  final historyTransactions = <Map<String, dynamic>>[].obs;
  final selectedTransactionTab = 0.obs;

  final outstandingTransactions = <Map<String, dynamic>>[].obs;

  final deniedPermissionsList = <String>[].obs;
  bool get isPermissionComplete => deniedPermissionsList.isEmpty;

  List<StorageModel> _cachedStorages = [];

  @override
  void onInit() {
    super.onInit();
    checkAndRequestPermissions();

    _loadDataForActiveUser().then((_) {
      _loadOutstandingTransactions();

      if (selectedStorage.value != 'Pilih Lokasi Storage') {
        _updateUiWithManualData(selectedStorage.value);
      }

      _checkDraftForHomeCard();
      _updateFcmToken();
    });
  }

  Future<void> reloadTransactions() async {
    await _loadOutstandingTransactions();
  }

  Future<void> _checkDraftForHomeCard() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final draftService = DraftPenerimaanService(authData.user.username);

    // GANTI: getDraft() -> getDraftBefore()
    final draft = await draftService.getDraftBefore();

    if (draft != null && draft.manualTankDetailsJson != null) {
      totalVolumeDisplay.value = draft.totalVolumeManual ?? 0.0;

      List<dynamic> manualList = jsonDecode(draft.manualTankDetailsJson!);
      List<Map<String, String>> displayList = [];

      for (var item in manualList) {
        displayList.add({
          'code': item['tank_code'].toString().replaceAll('_', ' '),
          'volume': "${item['volume_manual']} Ltr",
          'height': "${item['height_manual']} cm",
        });
      }
      tankListDisplay.assignAll(displayList);

      if (draft.storageCode != null) {
        selectedStorage.value = draft.storageCode!;
      }

    } else {
      // Logic else tetap sama
      if (selectedStorage.value != 'Pilih Lokasi Storage') {
        _updateUiWithManualData(selectedStorage.value);
      } else {
        totalVolumeDisplay.value = 0.0;
        tankListDisplay.clear();
      }
    }
  }

  void _updateFcmToken() {
    try {
      final notifService = Get.find<NotificationService>();
      notifService.syncTokenToServer();
    } catch (e) {
      print("Notification Service belum siap: $e");
    }
  }

  Future<void> _loadOutstandingTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final username = authData.user.username;
    final outstandingService = OutstandingService(username);
    final List<TransactionModel> dataList = await outstandingService.getAllTransactions();

    final List<Map<String, dynamic>> tempOngoing = [];
    final List<Map<String, dynamic>> tempHistory = [];

    for (var trx in dataList) {
      // Akses detail dari property dataSebelum
      final detail = trx.dataSebelum;

      String typeCode = detail?.docTypeCode ?? 'FIN';
      String title = 'Transaksi Solar';
      String iconPath = AppIcons.icTransaction;

      if (typeCode == 'FIN') {
        title = 'Penerimaan Solar';
        iconPath = AppIcons.icPenerimaan;
      } else if (typeCode == 'FOT') {
        title = 'Pengeluaran Solar';
        iconPath = AppIcons.icPengeluaran;
      }

      final mapData = {
        'id': trx.noBast,
        'title': title,
        'type': typeCode,
        'date': StringHelper().formatDate(trx.dateCreated),
        'amount': "${(detail?.volumeVendor ?? 0).toInt()} Ltr",
        'plat': (detail?.nopolVendor ?? 'Tidak Ada Plat').toUpperCase(),
        'status': trx.status, // Ambil dari Header
        'unit': (detail?.kodeUnit ?? '-').toString(),
        'icon': iconPath,
        'desc': (detail?.kodeUnit ?? '-').toString(),
      };

      String statusLower = trx.status.toLowerCase();

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

  void changeStorageLocation(String? newLocation) {
    if (newLocation != null && newLocation != selectedStorage.value) {
      selectedStorage.value = newLocation;
      _updateUiWithManualData(newLocation);
    }
  }

  void navigateToTransactionDetail(Map<String, dynamic> tx) {
    String noBast = tx['id'];
    String status = tx['status'].toString().toLowerCase();
    String type = tx['type'];

    print("Navigasi Transaksi: $noBast, Status: $status");

    if (type == 'FIN') {
      switch (status) {
        case 'draft':
        case 'proses':
          Get.toNamed(Routes.PENERIMAAN, arguments: {
            'noBast': noBast,
            'isResume': true
          });
          break;

        case 'setelah_pengisian':
          Get.toNamed(Routes.PENERIMAAN_SETELAH, arguments: {
            'noBast': noBast
          });
          break;

        case 'approval':
        case 'verifikasi':
          Get.toNamed(Routes.PENERIMAAN_TRACKING, arguments: {
            'noBast': noBast
          });
          break;

        case 'selesai':
          Get.toNamed(Routes.PENERIMAAN_TRACKING, arguments: {
            'noBast': noBast
          });
          break;

        default:
          Get.snackbar("Info", "Status transaksi tidak dikenali: $status");
      }
    } else if (type == 'FOT') {
      Get.snackbar("Info", "Fitur Pengeluaran dalam pengembangan");
    }
  }

  void _updateUiWithManualData(String storageLocation) {
    final storageCode = _getStorageCode(storageLocation);

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();

    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    double totalVol = 0.0;
    List<Map<String, String>> tempList = [];

    for (var tank in activeTanks) {
      final manualState = _fuelDataService.getLastManualState(tank.tankCode);
      double vol = manualState['volume']!;
      double h = manualState['height']!;

      totalVol += vol;

      tempList.add({
        'code': tank.tankCode.replaceAll('_', ' '),
        'volume': "${vol.toStringAsFixed(0)} Ltr", // Akan tampil "0 Ltr" jika awal
        'height': "${h.toStringAsFixed(0)} cm",
      });
    }

    totalVolumeDisplay.value = totalVol;
    tankListDisplay.assignAll(tempList);
  }

  Future<void> _loadDataForActiveUser() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final username = authData.user.username;
    await _sensorService.loadInitialData(username);
    await _fuelDataService.openFuelDataBox(username);
    var existingStorages = _fuelDataService.getStorages();

    loadUserData();

    if (storageLocations.isNotEmpty) {
      if (selectedStorage.value == 'Pilih Lokasi Storage') {
        selectedStorage.value = storageLocations.first;
      }
      _updateUiWithManualData(selectedStorage.value);
    }

    if (existingStorages.isEmpty) {
      print('📥 Hive Kosong. Mengisi Master Data dari Dummy...');
      List<StorageModel> storageList = masterStorageDummy.map((e) => StorageModel.fromJson(e)).toList();
      List<TankModel> tankList = mappingMasterTank.map((e) => TankModel.fromJson(e)).toList();
      List<StorageTankModel> iotList = mappingStorageTank.map((e) => StorageTankModel.fromJson(e)).toList();

      await _fuelDataService.saveMasterStorages(storageList);
      await _fuelDataService.saveMasterTanks(tankList);
      await _fuelDataService.saveStorageTankIotData(iotList);

      existingStorages = storageList;
      _sensorService.iotData.assignAll(iotList);
    }

    _cachedStorages = existingStorages;
    loadUserData();
  }

  void loadUserData() {
    final authData = _loginService.getCurrentAuth();
    if (authData != null) {
      final name = (authData.user.firstName.isNotEmpty) ? '${authData.user.firstName} ${authData.user.lastName}' : 'User';
      final unitId = (authData.user.userKaryawan.unit.id != 0) ? authData.user.userKaryawan.unit.id : 0;
      final unitCode = (authData.user.userKaryawan.unit.kodeUnit.isNotEmpty) ? authData.user.userKaryawan.unit.kodeUnit : 'E021';
      final estateAddress = (authData.user.userKaryawan.unit.namaUnit.isNotEmpty) ? authData.user.userKaryawan.unit.namaUnit : 'Estate';
      final unitAndEstate = '$unitCode - $estateAddress';

      final masterUnit = mappingMasterUnit.firstWhereOrNull((item) => item['id'] == unitId);
      final title = masterUnit != null ? masterUnit['title_unit'] : 'FLE';

      userName.value = name;
      userAddress.value = unitAndEstate;
      unitTitle.value = title;
      selectedUnitCode.value = unitCode;

      loadStorageLocations(unitCode);

      if (storageLocations.isNotEmpty) {
        selectedStorage.value = storageLocations.first;
        _updateUiWithManualData(selectedStorage.value);
      }

      final nameParts = name.trim().split(RegExp(r'\s+'));
      String initials = 'UU';
      if (nameParts.isNotEmpty) {
        initials = nameParts[0][0].toUpperCase();
        if (nameParts.length > 1) initials += nameParts[1][0].toUpperCase();
      }
      profileInitials.value = initials;
    }
  }

  void loadStorageLocations(String unitCode) {
    storageLocations.clear();
    final List<String>? codes = unitToStorageCodes[unitCode];
    if (codes != null && codes.isNotEmpty) {
      final List<String> availableStorages = [];
      for (var code in codes) {
        final storageItem = _cachedStorages.firstWhereOrNull((model) => model.storageCode == code);
        if (storageItem != null && storageItem.storageActive == 'Y') {
          availableStorages.add(storageItem.storageName);
        }
      }
      storageLocations.addAll(availableStorages);
    }
  }

  void openAppSettingsPage() async {
    await openAppSettings();
    checkAndRequestPermissions();
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