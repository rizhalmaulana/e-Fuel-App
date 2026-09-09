import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../configs/app_icons.dart';
import '../../../datas/models/auth/auth_response_model.dart';
import '../../../datas/models/inbound/inbound_model.dart';
import '../../../datas/models/master_storage/master_storage_model.dart';
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
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';

// Models
import 'package:e_fuel/datas/models/unit_to_storage/unit_to_storage_model.dart';
import '../services/home_service.dart';

class HomeController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final NotificationService _notificationService = Get.find<NotificationService>();
  final MasterDataService _masterDataService = MasterDataService();
  final ApprovalService _approvalService = ApprovalService();
  final HomeService _homeService = Get.put(HomeService(), permanent: true);
  StreamSubscription? _connectivitySubscription;

  // Data User
  final userName = 'User'.obs;
  final userAddress = 'E000 - Unknown Estate'.obs;
  final unitTitle = 'FLE'.obs;
  final greeting = 'Selamat Datang di Aplikasi e-Fuel'.obs;
  final profileInitials = 'UU'.obs;
  final selectedApprovalFilter = 'Semua'.obs;

  final isApprover = false.obs;
  final isLoading = false.obs;
  final isTankDetailExpanded = false.obs;

  // Menu List dan Unit List (Reactive)
  final selectedMenuCategory = 0.obs;
  final menuList = <Map<String, dynamic>>[].obs;
  final availableUnits = <Map<String, dynamic>>[].obs;
  final availableMenuTabs = <Map<String, dynamic>>[].obs;

  // Data Storage Location
  final storageLocations = <String>[].obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final selectedUnitCode = ''.obs;

  // DATA TANGKI MANUAL (API + Offline Cache)
  final manualTanksList = <VolumeTankDetailModel>[].obs;

  // UI Display
  final totalVolumeDisplay = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final lastUpdateTime = '-'.obs;

  // Status offline/online pada tampilan tangki
  final isUsingOfflineData = false.obs;

  // True selama API pertama kali dipanggil — banner offline tidak ditampilkan dulu
  // agar tidak muncul sesaat saat app buka padahal HP online
  final _isInitialLoad = true.obs;

  /// Gabungan: benar-benar offline (bukan sekadar loading pertama)
  bool get showOfflineBanner => isUsingOfflineData.value && !_isInitialLoad.value;

  // Transaksi
  final selectedTransactionTab = 0.obs;
  final approvalTransactions = <Map<String, dynamic>>[].obs;
  final outstandingTransactions = <Map<String, dynamic>>[].obs;
  final selectedDraftFilter = 'Semua'.obs;

  List<Map<String, dynamic>> get filteredOutstandingTransactions {
    if (selectedDraftFilter.value == 'Penerimaan') {
      return outstandingTransactions.where((tx) => tx['type'] == 'FIN').toList();
    } else if (selectedDraftFilter.value == 'Pengeluaran') {
      return outstandingTransactions.where((tx) => tx['type'] == 'FOT').toList();
    }
    return outstandingTransactions;
  }

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
      try {
        if (success) {
          await _initialDataSync();
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      } catch (e) {
        print("Error in initial load: $e");
      } finally {
        isLoading.value = false;
      }
    }).catchError((e) {
      print("Error loading active user: $e");
      isLoading.value = false;
    });

    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((result) {
      final isOnline = result is List
          ? !result.contains(ConnectivityResult.none)
          : result != ConnectivityResult.none;
      if (isOnline && isUsingOfflineData.value) {
        isUsingOfflineData.value = false;
        final storageCode = _getStorageCode(selectedStorage.value);
        _fetchManualTanksApi(selectedUnitCode.value, storageCode);
      } else {
        isUsingOfflineData.value = true;
      }
    });
  }

  Future<void> _syncMasterDataFromServer() async {
    try {
      final authData = _loginService.getCurrentAuth();
      if (authData == null) return;

      final unitCode = authData.currentKodeUnit;

      if (unitCode != null && unitCode.isNotEmpty) {
        final apiStorages = await _masterDataService.getStorageFromUnit(unitId: unitCode);

        if (apiStorages.isNotEmpty) {
          // Update cache storage (offline-first: selalu simpan jika berhasil)
          await _fuelDataService.saveLocalStorages(apiStorages);
          _cachedStorages = apiStorages;
          loadStorageLocations(unitCode);
        }
      }
    } catch (e) {
      print("⚠️ [HomeController] Sync Error: $e");
      // Tidak crash — data storage tetap terbaca dari Hive
    }
  }

  Future<void> _initialDataSync() async {
    final online = await ConnectivityHelper.isConnected();
    if (!online) return;

    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

    outstandingTransactions.clear();
    approvalTransactions.clear();

    if (auth.user.isApprover) {
      await _loadApproverTransactions();
    } else {
      await _loadServerOpenTransactions();
    }

    _syncMasterDataFromServer();
  }

  Future<bool> _loadDataForActiveUser() async {
    final authData = await _loginService.getAuthOrLoad();
    if (authData == null) return false;

    final username = authData.user.username;

    await _sensorService.initSensorBox(username);
    await _fuelDataService.openFuelDataBox(username);

    loadUserData(authData: authData);
    _fetchAndSetUnitTitle(selectedUnitCode.value);

    // Muat data storage dari cache lokal
    _cachedStorages = _fuelDataService.getLocalStorages();
    if (_cachedStorages.isNotEmpty) {
      loadStorageLocations(selectedUnitCode.value);
    }

    selectedStorage.value = _fuelDataService.getLastSelectedStorage();

    final cachedTanks = _fuelDataService.getApiManualTanks();
    if (cachedTanks.isNotEmpty) {
      manualTanksList.assignAll(cachedTanks);
      _updateUiFromManualData();
      isUsingOfflineData.value = true; // tandai sementara sebagai offline
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

      DateTime? serverTime = DateTime.tryParse(tank.updatedAt ?? tank.createdAt ?? '');
      DateTime localTime = serverTime != null ? serverTime.toLocal() : DateTime.now();
      String formattedTime = DateFormat('dd MMM, HH:mm', 'id_ID').format(localTime);

      tempList.add({
        'code': tankCode.replaceAll('_', ' '),
        'volume': "${TextConvertHelper().formatNumber(vol)} L",
        'capacity': "${TextConvertHelper().formatNumber(tank.capacity.toDouble())} L",
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

  List<Map<String, dynamic>> get filteredMenuList {
    if (selectedMenuCategory.value == 0) {
      return menuList.where((menu) {
        String action = menu['action'].toString();
        return action.contains('input_penerimaan') || action.contains('input_pengembalian');
      }).toList();
    } else if (selectedMenuCategory.value == 1) {
      return menuList.where((menu) {
        String action = menu['action'].toString();
        return action.contains('input_pengeluaran') || action.contains('input_e_bpb') || action.contains('input_transfer');
      }).toList();
    } else {
      return menuList.where((menu) => menu['action'].toString().contains('riwayat')).toList();
    }
  }

  void changeMenuCategory(int index) {
    selectedMenuCategory.value = index;
  }

  Future<void> onRefreshData() async {
    if (!await ConnectivityHelper.validateNetwork()) return;

    isLoading.value = true;
    try {
      await Future.wait([
        _initialDataSync(),
        _refreshTankData(),
      ]);

      if (selectedUnitCode.value.isNotEmpty && selectedStorage.value.isNotEmpty) {
        final storageCode = _getStorageCode(selectedStorage.value);
        await _homeService.initDataFlow(selectedUnitCode.value, storageCode);
        await _fetchManualTanksApi(selectedUnitCode.value, storageCode);
      }
    } catch (e) {
      debugPrint("Error saat refresh: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _refreshTankData() async {
    if (selectedUnitCode.value.isNotEmpty && selectedStorage.value.isNotEmpty) {
      final storageCode = _getStorageCode(selectedStorage.value);

      await Future.wait([
        _homeService.initDataFlow(selectedUnitCode.value, storageCode),
        _fetchManualTanksApi(selectedUnitCode.value, storageCode),
      ]).timeout(const Duration(seconds: 15));
    }
  }

  List<Map<String, dynamic>> get filteredApprovalTransactions {
    if (selectedApprovalFilter.value == 'Penerimaan') {
      return approvalTransactions.where((tx) => tx['type'] == 'FIN').toList();
    } else if (selectedApprovalFilter.value == 'E-BPB') {
      return approvalTransactions.where((tx) => tx['type'] == 'EBPB').toList();
    }
    return approvalTransactions;
  }

  void goToPenerimaan() {
    if (manualTanksList.isEmpty) {
      Get.dialog(
        DialogFlexible(
          title: "Tangki Tidak Tersedia",
          message: "Storage ${selectedStorage.value} tidak memiliki data tangki yang terdaftar.",
          primaryButtonText: "Mengerti",
          onPrimaryPressed: () => Get.back(),
          logo: Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
        ),
        barrierDismissible: true,
      );
      return;
    }

    Get.toNamed(Routes.PENERIMAAN_SEBELUM_FORM, arguments: {
      'unit_id': selectedUnitCode.value,
      'storage_code': _getStorageCode(selectedStorage.value),
    });
  }

  Future<void> _loadApproverTransactions() async {
    final authData = _loginService.getCurrentAuth();
    if (authData == null) return;

    final userLevel = authData.user.otorisasi.isNotEmpty ? authData.user.otorisasi.first : '';
    final kodeUnit = authData.currentKodeUnit ?? '';

    try {
      final List<Map<String, dynamic>> tempApproval = [];

      final apiResult = await _approvalService.getApprovalList(
        kodeUnit: kodeUnit,
        levelApproval: null,
        transactionType: "FIN",
        statusApprove: "PENDING",
      );

      Map<String, List<dynamic>> groupedApprovals = {};
      for (var item in apiResult) {
        String noBast = item.noBast ?? '-';
        if (!groupedApprovals.containsKey(noBast)) {
          groupedApprovals[noBast] = [];
        }
        groupedApprovals[noBast]!.add(item);
      }

      groupedApprovals.forEach((noBast, approvalList) {
        int getLevelNum(String levelStr) {
          final match = RegExp(r'\d+').firstMatch(levelStr);
          return match != null ? int.parse(match.group(0)!) : 99;
        }

        approvalList.sort((a, b) {
          int levelA = getLevelNum(a.levelApproval ?? '');
          int levelB = getLevelNum(b.levelApproval ?? '');
          return levelA.compareTo(levelB);
        });

        final activePendingNode = approvalList.first;
        final activePendingLevel = activePendingNode.levelApproval;

        if (activePendingLevel == userLevel) {
          String tglApprove = activePendingNode.tglApprove ?? activePendingNode.createdAt ?? '';
          tempApproval.add({
            'noBast': noBast,
            'title': 'Penerimaan Solar',
            'type': activePendingNode.transactionType,
            'date': TextConvertHelper().formatDate(tglApprove),
            'rawDate': DateTime.tryParse(tglApprove) ?? DateTime.now(),
            'status': activePendingNode.statusApprove,
            'unit': kodeUnit,
            'id': activePendingNode.id,
            'source': 'api',
          });
        }
      });

      try {
        final ebpbResult = await _approvalService.getApprovalListEbpb(
          kodeUnit: kodeUnit,
          levelApproval: "", // Kosongkan agar dapat semua level yang pending
          statusApprove: "PENDING",
        );

        Map<String, List<dynamic>> groupedEbpb = {};
        for (var item in ebpbResult) {
          String noDoc = item['no_doc'] ?? '-';
          if (!groupedEbpb.containsKey(noDoc)) {
            groupedEbpb[noDoc] = [];
          }
          groupedEbpb[noDoc]!.add(item);
        }

        groupedEbpb.forEach((noDoc, ebpbList) {
          int getLevelNum(String levelStr) {
            final match = RegExp(r'\d+').firstMatch(levelStr);
            return match != null ? int.parse(match.group(0)!) : 99;
          }

          ebpbList.sort((a, b) {
            int levelA = getLevelNum(a['level_approve']?.toString() ?? '');
            int levelB = getLevelNum(b['level_approve']?.toString() ?? '');
            return levelA.compareTo(levelB);
          });

          final activePendingNode = ebpbList.first;
          final activeLevelNum = getLevelNum(activePendingNode['level_approve']?.toString() ?? '');
          final userLevelNum = getLevelNum(userLevel);

          if (activeLevelNum == userLevelNum) {
            String dateRaw = activePendingNode['created_at'] ?? activePendingNode['tgl_approve'] ?? DateTime.now().toString();
            tempApproval.add({
              'noBast': noDoc,
              'title': 'Approval E-BPB',
              'type': 'EBPB',
              'date': TextConvertHelper().formatDate(dateRaw),
              'rawDate': DateTime.tryParse(dateRaw) ?? DateTime.now(),
              'status': activePendingNode['status_approve'] ?? 'PENDING',
              'unit': kodeUnit,
              'id': activePendingNode['id'],
              'source': 'api_ebpb',
            });
          }
        });
      } catch (e) {
        print("⚠️ Gagal memuat Approval E-BPB: $e");
      }

      tempApproval.sort((a, b) {
        DateTime dateA = a['rawDate'] as DateTime;
        DateTime dateB = b['rawDate'] as DateTime;
        return dateA.compareTo(dateB);
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
      final List<Map<String, dynamic>> tempOutstanding = [];

      // 1. Fetch Drafts from API Server (status_inbound == 'O')
      try {
        List<InboundModel> apiFINList = await _masterDataService.getInboundOpenList(
          kodeUnit: kodeUnit,
          statusInbound: 'O',
          docType: 'FIN',
        );

        List<InboundModel> apiFOTList = await _masterDataService.getInboundOpenList(
          kodeUnit: kodeUnit,
          statusInbound: 'O',
          docType: 'FOT',
        );

        for (var item in apiFINList) {
          bool isDraft = (item.tanks == null || item.tanks!.isEmpty) &&
              (item.approvals == null || item.approvals!.isEmpty);

          if (isDraft) {
            tempOutstanding.add({
              'noBast': item.noDoc ?? '-',
              'title': 'Draft Penerimaan',
              'type': 'FIN',
              'date': TextConvertHelper().formatDate(item.dateInbound),
              'amount': "${(item.volumeVendor ?? 0).toInt()} L",
              'status': 'Draft',
              'unit': item.kodeUnit,
              'source': 'api',
            });
          }
        }

        for (var item in apiFOTList) {
          bool isDraft = (item.tanks == null || item.tanks!.isEmpty) &&
              (item.approvals == null || item.approvals!.isEmpty);

          if (isDraft) {
            tempOutstanding.add({
              'noBast': item.noDoc ?? '-',
              'title': 'Draft Pengeluaran',
              'type': 'FOT',
              'date': TextConvertHelper().formatDate(item.dateInbound),
              'amount': "${(item.volumeVendor ?? 0).toInt()} L",
              'status': 'Draft',
              'unit': item.kodeUnit,
              'source': 'api',
            });
          }
        }
      } catch (e) {
        print("Error fetching server open transactions: $e");
      }

      // 2. Fetch Drafts from Local Hive Outstanding (if not already fetched or offline)
      try {
        final outstandingService = OutstandingService(authData.user.username);
        final localList = await outstandingService.getAllCombinedTransactions();

        for (var item in localList) {
          if (item is TransactionModel && item.status != 'selesai') {
            bool exists = tempOutstanding.any((tx) => tx['noBast'] == item.noBast);
            if (!exists) {
              tempOutstanding.add({
                'noBast': item.noBast,
                'title': 'Draft Penerimaan',
                'type': 'FIN',
                'date': TextConvertHelper().formatDate(item.dataSebelum?.dateInbound ?? item.dateCreated),
                'amount': "${(item.dataSebelum?.volumeVendor ?? 0).toInt()} L",
                'status': 'Draft',
                'unit': item.dataSebelum?.kodeUnit ?? kodeUnit,
                'source': 'local',
              });
            }
          } else if (item is TransactionPengeluaranModel && item.status != 'selesai') {
            bool exists = tempOutstanding.any((tx) => tx['noBast'] == item.noBast);
            if (!exists) {
              tempOutstanding.add({
                'noBast': item.noBast,
                'title': 'Draft Pengeluaran',
                'type': 'FOT',
                'date': TextConvertHelper().formatDate(item.dataPengeluaran?.dateOutbound ?? item.dateCreated),
                'amount': "${(item.dataPengeluaran?.jumlahPengisianSolar ?? 0).toInt()} L",
                'status': 'Draft',
                'unit': item.dataPengeluaran?.kodeUnit ?? kodeUnit,
                'source': 'local',
              });
            }
          }
        }
      } catch (e) {
        print("Error loading local outstanding transactions: $e");
      }

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

  Future<void> changeStorageLocation(String? newStorage) async {
    if (newStorage != null && newStorage != 'Tidak ada Storage') {
      selectedStorage.value = newStorage;

      final unitCode = selectedUnitCode.value;
      final storageCode = _getStorageCode(newStorage);
      await _fuelDataService.saveLastSelectedStorage(newStorage, storageCode);

      final cachedForStorage = _fuelDataService
          .getApiManualTanks()
          .where((t) => t.masterStorage?.kodeStorage == storageCode)
          .toList();

      if (cachedForStorage.isNotEmpty) {
        manualTanksList.assignAll(cachedForStorage);
        _updateUiFromManualData();
        isUsingOfflineData.value = true;
      } else {
        // Tidak ada cache untuk storage ini, kosongkan tampilan dulu
        totalVolumeDisplay.value = 0.0;
        tankListDisplay.clear();
        manualTanksList.clear();
      }

      // Fetch terbaru dari API (akan replace data di atas jika berhasil)
      _fetchManualTanksApi(unitCode, storageCode);
      await _homeService.initDataFlow(unitCode, storageCode);
    }
  }

  Future<void> _fetchManualTanksApi(String unitCode, String storageCode) async {
    bool online = await ConnectivityHelper.isConnected();
    isUsingOfflineData.value = !online;

    try {
      final results = await _homeService.repository.syncSensorStockWithLocal(
        unitId: unitCode,
        storageCode: storageCode,
      );

      if (results.isNotEmpty) {
        manualTanksList.assignAll(results);
        _updateUiFromManualData();

        if (online) isUsingOfflineData.value = false;

        await _fuelDataService.saveLastInputType("A");
      } else {
        _loadFallbackData(storageCode);
      }
    } catch (e) {
      _loadFallbackData(storageCode);
    } finally {
      _isInitialLoad.value = false;
    }
  }

  void _loadFallbackData(String storageCode) {
    final localData = _fuelDataService
        .getApiManualTanks()
        .where((t) => t.masterStorage?.kodeStorage == storageCode)
        .toList();

    if (localData.isNotEmpty) {
      manualTanksList.assignAll(localData);
      _updateUiFromManualData();
    }
    isUsingOfflineData.value = true; // Force true karena gagal API/Offline
    _fuelDataService.saveLastInputType("M");
  }

  Future<void> navigateToTransactionDetail(Map<String, dynamic> tx) async {
    String source = tx['source'] ?? 'local';
    String noBast = tx['noBast'] ?? tx['no_doc'] ?? '';
    String type = tx['type'] ?? '';
    String status = tx['status'] ?? '';

    // --- Approval Items (Kasie & Manager) ---
    if (source == 'api' && status.toUpperCase() == 'PENDING') {
      Get.toNamed(Routes.APPROVAL, arguments: {'noBast': noBast, 'type': type});
      return;
    }

    if (source == 'api_ebpb' && status.toUpperCase() == 'PENDING') {
      Get.toNamed(Routes.APPROVAL_EBPB, arguments: {'noDoc': noBast, 'type': type});
      return;
    }

    // --- Draft Transaksi Items (Kepala Gudang / Asst. Traksi) ---
    if (status.toLowerCase() == 'draft' || status.isEmpty) {
      final auth = _loginService.getCurrentAuth();
      if (auth == null) return;
      final outstandingService = OutstandingService(auth.user.username);

      if (type == 'FIN') {
        // --- ALUR PENERIMAAN DRAFT ---
        final localTrx = await outstandingService.getTransactionByNoBastService(noBast);
        if (localTrx != null) {
          String subStatus = localTrx.status;
          if (subStatus == 'pengisian_solar') {
            Get.toNamed(Routes.PENGISIAN_SOLAR, arguments: {
              'noBast': localTrx.noBast,
              'noPO': localTrx.dataSebelum?.purchNo ?? '-',
              'noPolisi': localTrx.dataSebelum?.nopolVendor ?? '-',
              'manual_json_backup': localTrx.dataSebelum?.manualTankDetailsJson,
              'iot_json_backup': localTrx.dataSebelum?.iotTankDetailsJson,
              'tanggal': localTrx.dataSebelum?.dateInbound ?? '-',
              'waktu_sounding': localTrx.dateCreated,
              'status': 'pengisian_solar',
              'storage_code': localTrx.dataSebelum?.storageCode ?? '',
            });
            return;
          } else if (subStatus == 'penerimaan_setelah') {
            Get.toNamed(Routes.PENERIMAAN_SETELAH, arguments: {'noBast': localTrx.noBast});
            return;
          } else if (subStatus == 'verifikasi_bast') {
            Get.toNamed(Routes.PENERIMAAAN_VERIFIKASI_BAST, arguments: {'noBast': localTrx.noBast});
            return;
          }
        }

        // Fallback jika tidak ada di Hive lokal
        Get.toNamed(Routes.PENGISIAN_SOLAR, arguments: {
          'noBast': noBast,
          'noPO': '-',
          'noPolisi': '-',
          'tanggal': tx['date'] ?? '-',
          'status': 'pengisian_solar',
          'storage_code': _getStorageCode(selectedStorage.value),
        });
        return;

      } else if (type == 'FOT') {
        // --- ALUR PENGELUARAN DRAFT ---
        final localTrx = await outstandingService.getTransactionPengeluaranByNoBast(noBast);
        if (localTrx != null) {
          String subStatus = localTrx.status;
          if (subStatus == 'verifikasi_doc') {
            Get.toNamed(Routes.PENGELUARAN_VERIFIKASI_DOC, arguments: {'noDoc': localTrx.noBast});
            return;
          } else {
            final String resumeUnitIO = (localTrx.dataPengeluaran?.unitIO?.isNotEmpty == true && localTrx.dataPengeluaran?.unitIO != '-')
                ? localTrx.dataPengeluaran!.unitIO!
                : '-';

            final String rawResumeTanggal = localTrx.dataPengeluaran?.dateOutbound ?? '';
            final String resumeTanggal = rawResumeTanggal.contains('T')
                ? rawResumeTanggal.split('T').first
                : (rawResumeTanggal.contains(' ') ? rawResumeTanggal.split(' ').first : rawResumeTanggal.isNotEmpty ? rawResumeTanggal : DateFormat('yyyy-MM-dd').format(DateTime.now()));

            Get.toNamed(Routes.PENGISIAN_SOLAR_PENGELUARAN, arguments: {
              'noDoc': localTrx.noBast,
              'unitIO': resumeUnitIO,
              'tanggal': resumeTanggal,
              'status': 'pengisian_solar_pengeluaran',
              'payload': {
                'no_doc': localTrx.noBast,
                'no_io': localTrx.dataPengeluaran?.noIo,
                'nopol_check': localTrx.dataPengeluaran?.nopolCheck,
                'status_supir': localTrx.dataPengeluaran?.statusSupir,
                'supir_check': localTrx.dataPengeluaran?.supirCheck,
                'km_pengisian': localTrx.dataPengeluaran?.kmPengisian,
                // jumlahPengisianSolar = estimasi; fallback ke liter jika null
                'jumlah_pengisian_solar': localTrx.dataPengeluaran?.jumlahPengisianSolar ?? localTrx.dataPengeluaran?.liter,
                'doc_type': localTrx.dataPengeluaran?.docType ?? 'FOT',
                'hm_km_akhir': localTrx.dataPengeluaran?.hmKmAkhir,
                'liter': localTrx.dataPengeluaran?.liter,
                'hm_km_awal': localTrx.dataPengeluaran?.hmKmAwal,
                'kategori_kendaraan': localTrx.dataPengeluaran?.kategoriKendaraan,
                'jenis_pengeluaran': localTrx.dataPengeluaran?.jenisPengeluaran,
                'cost_center': localTrx.dataPengeluaran?.costCenter,
                'ratio': localTrx.dataPengeluaran?.ratio,
                'tipe_unit_io': localTrx.dataPengeluaran?.tipeUnitIo,
                'varian': localTrx.dataPengeluaran?.varian,
                'tanggal_akhir': localTrx.dataPengeluaran?.tanggalAkhir,
                'tanggal_awal': localTrx.dataPengeluaran?.tanggalAwal,
                'satuan': localTrx.dataPengeluaran?.satuan,
                'kode_unit': localTrx.dataPengeluaran?.kodeUnit,
              },
              'isManualInput': false,
              'jenis_pengeluaran': localTrx.dataPengeluaran?.jenisPengeluaran ?? 'Bon Sementara',
            });
            return;
          }
        }

        // Fallback: data tidak ada di Hive lokal → hit endpoint detail-pengeluaran
        try {
          final PengeluaranApiService pengeluaranApiService = PengeluaranApiService();
          final detail = await pengeluaranApiService.getDetailPengeluaran(noBast);

          if (detail != null) {
            // Ambil hanya bagian YYYY-MM-DD dari dateInbound
            // Handle format ISO 8601 dengan 'T' atau dengan spasi
            String rawDate = detail.dateInbound;
            final String tanggalBersih = rawDate.contains('T')
                ? rawDate.split('T').first
                : (rawDate.contains(' ') ? rawDate.split(' ').first : rawDate);

            // Gunakan namaUnit jika ada, fallback ke kodeUnit
            final String unitDisplay = (detail.namaUnit.isNotEmpty && detail.namaUnit != '-')
                ? detail.namaUnit
                : detail.kodeUnit;

            Get.toNamed(Routes.PENGISIAN_SOLAR_PENGELUARAN, arguments: {
              'noDoc': detail.noDoc,
              'unitIO': unitDisplay,
              'tanggal': tanggalBersih,
              'status': 'pengisian_solar_pengeluaran',
              'isManualInput': detail.inputType.toLowerCase() == 'manual',
              'jenis_pengeluaran': 'Bon Sementara',
              'payload': {
                'no_doc': detail.noDoc,
                'no_io': detail.noIo ?? '-',
                'nopol_check': detail.nopolCheck ?? '-',
                'supir_check': detail.supirCheck ?? '-',
                'status_supir': 'Internal',
                'km_pengisian': detail.hmKmAkhir,
                'jumlah_pengisian_solar': detail.estimasiLiter,
                'doc_type': detail.docType,
                'hm_km_awal': detail.hmKmAwal,
                'hm_km_akhir': detail.hmKmAkhir,
                'ratio': detail.ratioInput,
                'cost_center': detail.costCenter,
                'tipe_unit_io': 'AB',
                'varian': detail.varianLiter,
                'tanggal_akhir': tanggalBersih,
                'tanggal_awal': tanggalBersih,
                'keterangan': detail.keterangan,
              },
            });
          } else {
            // Detail API juga gagal → minimal navigasi dengan noDoc saja
            Get.toNamed(Routes.PENGISIAN_SOLAR_PENGELUARAN, arguments: {
              'noDoc': noBast,
              'tanggal': tx['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now()),
              'status': 'pengisian_solar_pengeluaran',
              'payload': {'no_doc': noBast},
              'isManualInput': false,
              'jenis_pengeluaran': 'Bon Sementara',
            });
          }
        } catch (e) {
          print('Error fetching detail pengeluaran on resume: $e');
          Get.snackbar(
            'Gagal Memuat Data',
            'Tidak dapat mengambil detail transaksi. Coba lagi.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return;
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
      isApprover.value = (authData.user.otorisasi.first == "fuel_level_1") ? false : true;

      final nameParts = userName.value.trim().split(RegExp(r'\s+'));
      if (nameParts.isNotEmpty) {
        profileInitials.value = (nameParts.length > 1)
            ? "${nameParts[0][0]}${nameParts[1][0]}".toUpperCase()
            : nameParts[0][0].toUpperCase();
      }

      _prepareAvailableUnits(authData);
      await _fetchAndSetUnitTitle(unitCode);
      _generateUserMenu(user);

      _cachedStorages = _fuelDataService.getLocalStorages();
      if (_cachedStorages.isNotEmpty) {
        loadStorageLocations(unitCode);
      }
    }
  }

  void _prepareAvailableUnits(AuthResponseModel authData) {
    availableUnits.clear();
    if (authData.otorisasiData?.unit != null) {
      for (var u in authData.otorisasiData!.unit!) {
        availableUnits.add({'id': u.id, 'kode_unit': u.kodeUnit, 'nama_unit': u.namaUnit});
      }
    } else if (authData.user.userKaryawan != null) {
      final u = authData.user.userKaryawan!.unit;
      availableUnits.add({'id': u.id, 'kode_unit': u.kodeUnit, 'nama_unit': u.namaUnit});
    }
  }

  Future<void> switchUnit(Map<String, dynamic> unit) async {
    selectedUnitCode.value = unit['kode_unit'];
    userAddress.value = "${unit['kode_unit']} - ${unit['nama_unit']}";

    await _fetchAndSetUnitTitle(unit['kode_unit']);
    await _syncMasterDataFromServer();
    _initialDataSync();
  }

  void _generateUserMenu(UserModel user) {
    menuList.clear();

    final menuInputPenerimaan = {'icon': AppIcons.icPenerimaan, 'label': 'Penerimaan', 'action': 'input_penerimaan', 'category': 0};
    final menuEBPB = {'icon': AppIcons.icBpbHarian, 'label': 'E-BPB', 'action': 'input_e_bpb', 'category': 1};
    final menuInputPengeluaran = {'icon': AppIcons.icPengeluaran, 'label': 'Pengeluaran', 'action': 'input_pengeluaran', 'category': 1};
    final menuInputPengeluaranManual = {'icon': AppIcons.icPengeluaranManual, 'label': 'Input Manual', 'action': 'input_pengeluaran_manual', 'category': 1};
    final menuTransfer = {'icon': AppIcons.icTransfer, 'label': 'Transfer', 'action': 'input_transfer', 'category': 1};
    final menuPengembalianSolar = {'icon': AppIcons.icPengembalianSolar, 'label': 'Pengembalian', 'action': 'input_pengembalian', 'category': 0};
    final menuRiwayatPenerimaan = {'icon': AppIcons.icReportPenerimaan, 'label': 'Laporan Penerimaan', 'action': 'riwayat_penerimaan', 'category': 2};
    final menuRiwayatPengeluaran = {'icon': AppIcons.icReportPengeluaran, 'label': 'Laporan Pengeluaran', 'action': 'riwayat_pengeluaran', 'category': 2};
    final menuRiwayatEBPB = {'icon': AppIcons.icReportEBPB, 'label': 'Laporan E-BPB', 'action': 'riwayat_e_bpb', 'category': 2};
    final menuRiwayatTransfer = {'icon': AppIcons.icReportTransfer, 'label': 'Laporan Transfer', 'action': 'riwayat_transfer', 'category': 2};

    if (user.isKepalaGudang) {
      menuList.addAll([
        menuInputPenerimaan, menuPengembalianSolar, menuInputPengeluaran, menuTransfer, menuInputPengeluaranManual, menuEBPB,
        menuRiwayatPenerimaan, menuRiwayatPengeluaran, menuRiwayatEBPB, menuRiwayatTransfer,
      ]);
    } else if (user.isApprover) {
      menuList.addAll([
        menuRiwayatPenerimaan, menuRiwayatPengeluaran, menuRiwayatEBPB, menuRiwayatTransfer,
      ]);
    }

    availableMenuTabs.clear();

    bool hasPenerimaan = menuList.any((menu) => menu['category'] == 0);
    bool hasPengeluaran = menuList.any((menu) => menu['category'] == 1);
    bool hasLaporan = menuList.any((menu) => menu['category'] == 2);

    if (hasPenerimaan) availableMenuTabs.add({'label': 'Penerimaan', 'index': 0});
    if (hasPengeluaran) availableMenuTabs.add({'label': 'Pengeluaran', 'index': 1});
    if (hasLaporan) availableMenuTabs.add({'label': 'Laporan', 'index': 2});

    if (availableMenuTabs.isNotEmpty) {
      selectedMenuCategory.value = availableMenuTabs.first['index'];
    }
  }

  void handleMenuTap(String action, BuildContext context) async {
    debugPrint("Selected Storage: ${_getStorageCode(selectedStorage.value)}");

    // Cek Koneksi Internet (Khusus untuk menu input)
    if (action == 'input_penerimaan' || action == 'input_pengeluaran' || action == 'input_pengeluaran_manual' || action == 'input_e_bpb' || action == 'input_pengembalian') {
      bool isOnline = await ConnectivityHelper.isConnected();
      if (!isOnline) {
        Get.snackbar(
          "Akses Terbatas (Offline)", 
          "Koneksi internet diperlukan untuk mengakses menu transaksi.",
          backgroundColor: Colors.red.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
        );
        return; // Hentikan navigasi
      }
    }

    switch (action) {
      case 'input_penerimaan': goToPenerimaan(); break;
      case 'input_pengeluaran': Get.toNamed(Routes.PENGELUARAN, arguments: {'isManualInput': false}); break;
      case 'input_pengeluaran_manual': Get.toNamed(Routes.PENGELUARAN, arguments: {'isManualInput': true}); break;
      case 'input_pengembalian': Get.toNamed(Routes.PENGEMBALIAN); break;
      case 'input_transfer': Get.toNamed(Routes.TRANSFER); break;
      case 'input_e_bpb': Get.toNamed(Routes.PENGELUARAN_EBPB); break;
      case 'riwayat_penerimaan': Get.toNamed(Routes.REPORT_PENERIMAAN); break;
      case 'riwayat_pengeluaran': Get.toNamed(Routes.REPORT_PENGELUARAN); break;
      // case 'riwayat_transfer': Get.toNamed(Routes.REPORT_TRANSFER); break;
      case 'riwayat_transfer': _showDevelopmentModal(context); break;
      case 'riwayat_e_bpb': _showDevelopmentModal(context); break;
      default: _showDevelopmentModal(context);
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
          formattedList.add("${storage.namaStorage} - ${storage.kodeStorage}");
        }
      }
    }

    if (formattedList.isNotEmpty) {
      storageLocations.addAll(formattedList);

      if (selectedStorage.value == 'Pilih Lokasi Storage' || selectedStorage.value.isEmpty) {
        changeStorageLocation(storageLocations.first);
      } else if (!storageLocations.contains(selectedStorage.value)) {
        changeStorageLocation(storageLocations.first);
      } else {
        final storageCode = _getStorageCode(selectedStorage.value);
        _fetchManualTanksApi(selectedUnitCode.value, storageCode);
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
        logo: LottiesHelper().getLottieOnDevelopment(),
        title: "Konfirmasi Keluar",
        message: "Apakah Anda yakin ingin keluar dari aplikasi? Sesi Anda akan diakhiri.",
        secondaryButtonText: "Batal",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Ya, Keluar",
        onPrimaryPressed: () async {
          Get.back();
          // Hanya hapus data auth/token — data tangki dan storage tetap di Hive per user
          await _loginService.clearAuthData();
          Get.offAllNamed(Routes.LOGIN);
        },
      ),
      barrierDismissible: true,
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

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}