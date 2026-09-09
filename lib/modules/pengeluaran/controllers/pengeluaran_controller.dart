import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:e_fuel/modules/home/services/home_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:e_fuel/datas/models/approval/konfigurasi_approval_model.dart';
import 'package:e_fuel/modules/home/controllers/home_controller.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/models/master_io/master_io_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_camera_view.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';
import '../services/draft_pengeluaran_service.dart';

class PengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final PengeluaranApiService _apiService = PengeluaranApiService();
  late DraftPengeluaranService _draftService;

  // final BonSementaraLocalService _bonLokalService = BonSementaraLocalService();
  final HomeService _homeService = Get.find<HomeService>();

  // --- Form Controllers ---
  final kmPengisianC = TextEditingController();
  final pengisianSolarC = TextEditingController();
  final ioController = TextEditingController();
  final platController = TextEditingController();
  final driverNameC = TextEditingController();
  final keteranganC = TextEditingController();
  final kodeUnitController = TextEditingController();
  final aktualSolarC = TextEditingController();
  final varianSolarC = TextEditingController();
  final tanggalTransaksiC = TextEditingController();
  final noDocInputC = TextEditingController();
  String? _createdNoDoc;

  // --- Data Logic ---
  final List<String> jenisBonList = ['Bon Sementara', 'BPB'];
  final jenisKategoriList = <String>[].obs;
  var userInitialTitle = "LKE";
  final List<String> statusSupirList = ['Internal', 'Eksternal'];

  var isLoadingUnit = false.obs;
  var filteredUnitList = <MasterIoModel>[].obs;
  List<MasterIoModel> _allUnitList = [];
  var selectedUnit = Rxn<MasterIoModel>();

  // --- Unit Pengganti ---
  var isUnitPengganti = false.obs;
  var selectedReplacedUnit = Rxn<MasterIoModel>(); // Unit Utama yang digantikan
  var filteredMainUnitList = <MasterIoModel>[].obs;  // Hanya Unit Utama (status U)
  String _lastSearchMainKeyword = '';

  var filterStatusUnit = Rxn<String>();
  var filterTipeUnit = Rxn<String>();
  String _lastSearchKeyword = '';

  var isLangsungPom = false.obs;

  var isLoadingUnitsPerArea = false.obs;

  var listTitleUnitPerArea = <String>[].obs;
  var listKodeUnitPerArea = <String>[].obs;
  var userTitleUnit = "".obs;
  var userKodeUnit = "".obs;

  var selectedKodeKebunPabrik = Rxn<String>();
  var selectedKodeUnitKebunPabrik = Rxn<String>();

  var selectedJenisBon = Rxn<String>();
  var selectedKategoriKendaraan = Rxn<String>();
  var selectedStatusSupir = Rxn<String>();
  var fotoOdometer = Rxn<File>();
  var fotoDispenser = Rxn<File>();
  var fotoSupir = Rxn<File>();

  final tipeUnit = Rxn<String>();
  final satuan = Rxn<String>();
  final hmKmAwal = Rxn<String>();
  final hmKmAkhir = Rxn<String>();
  final dateAwal = Rxn<String>();
  final dateAkhir = Rxn<String>();
  final varian = Rxn<String>();
  final ratio = Rxn<String>();
  final literAuto = Rxn<String>();
  final tanggalTransaksi = Rxn<String>();

  // State ReadOnly
  var isPlatReadOnly = true.obs;
  var isHmKmAwalReadOnly = false.obs;
  var isHmKmAkhirReadOnly = true.obs;
  var isDateAwalReadOnly = false.obs;
  var isDateAkhirReadOnly = true.obs;
  var isVarianReadOnly = true.obs;
  var isRatioReadOnly = true.obs;
  var isLiterReadOnly = true.obs;
  var isIoReadOnly = true.obs;
  var isTakingPhoto = false.obs;
  var isSubmitting = false.obs;
  var isGSReadOnly = false.obs;
  var isManualInput = false.obs;

  final tipeUnitC = TextEditingController();
  final satuanC = TextEditingController();
  final hmKmAwalC = TextEditingController();
  final hmKmAkhirC = TextEditingController();
  final dateAwalC = TextEditingController();
  final dateAkhirC = TextEditingController();
  final varianC = TextEditingController();
  final ratioC = TextEditingController();
  final ratioInput = TextEditingController();

  var isLoadingDriver = false.obs;
  late String _kodeUnit;

  bool get isTipeKendaraan {
    final tipe = tipeUnit.value?.toUpperCase() ?? '';
    return tipe == 'KD' || tipe == 'AB' || tipe == 'AD';
  }

  bool get isTipeGenset => (tipeUnit.value?.toUpperCase() ?? '') == 'GS';
  bool get isBpbMode => selectedJenisBon.value == 'BPB';
  bool get isTamu => selectedKategoriKendaraan.value == 'TAMU';

  @override
  void onInit() {
    super.onInit();

    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _kodeUnit = auth.currentKodeUnit ?? "Null";
      _draftService = DraftPengeluaranService(auth.user.username);

      String namaUnit = auth.currentNamaUnit ?? "";
      if (namaUnit.isNotEmpty) {
        var parts = namaUnit.trim().split(" ");
        if (parts.isNotEmpty) {
          userInitialTitle = parts.last;
        }
      }
    }

    if (Get.arguments != null && Get.arguments['isManualInput'] != null) {
      isManualInput.value = Get.arguments['isManualInput'];
    }

    jenisKategoriList.assignAll([
      'INTERNAL $userInitialTitle',
      'INTERNAL NON $userInitialTitle',
      'VENDOR',
      'TAMU'
    ]);

    selectedJenisBon.value = jenisBonList.first;
    selectedKategoriKendaraan.value = jenisKategoriList.first;
    selectedStatusSupir.value = statusSupirList.first;

    selectedKodeKebunPabrik.value =
        userTitleUnit.value.isNotEmpty ? userTitleUnit.value : null;
    selectedKodeUnitKebunPabrik.value =
        userKodeUnit.value.isNotEmpty ? userKodeUnit.value : null;

    _setupInternalMode();
    fetchUnitsPerArea();

    // Listener yang sudah ada
    hmKmAwalC.addListener(_calculateAutomatedValues);
    hmKmAkhirC.addListener(_calculateAutomatedValues);
    ratioInput.addListener(_calculateAutomatedValues);
    dateAwalC.addListener(_calculateAutomatedValues);
    dateAkhirC.addListener(_calculateAutomatedValues);
    aktualSolarC.addListener(_calculateVarianSolar);
    pengisianSolarC.addListener(_calculateVarianSolar);
  }

  @override
  void onClose() {
    hmKmAwalC.removeListener(_calculateAutomatedValues);
    hmKmAkhirC.removeListener(_calculateAutomatedValues);
    ratioInput.removeListener(_calculateAutomatedValues);
    dateAwalC.removeListener(_calculateAutomatedValues);
    dateAkhirC.removeListener(_calculateAutomatedValues);
    aktualSolarC.removeListener(_calculateVarianSolar);
    pengisianSolarC.removeListener(_calculateVarianSolar);

    kmPengisianC.dispose();
    pengisianSolarC.dispose();
    ioController.dispose();
    platController.dispose();
    driverNameC.dispose();
    keteranganC.dispose();
    tipeUnitC.dispose();
    satuanC.dispose();
    hmKmAwalC.dispose();
    hmKmAkhirC.dispose();
    dateAwalC.dispose();
    dateAkhirC.dispose();
    varianC.dispose();
    ratioInput.dispose();
    kodeUnitController.dispose();
    aktualSolarC.dispose();
    varianSolarC.dispose();
    tanggalTransaksiC.dispose();
    noDocInputC.dispose();
    super.onClose();
  }

  void onKodeKebunPabrikChanged(String? val) {
    selectedKodeKebunPabrik.value = val;
    if (val != null) {
      int idx = listTitleUnitPerArea.indexOf(val);
      if (idx != -1 && idx < listKodeUnitPerArea.length) {
        selectedKodeUnitKebunPabrik.value = listKodeUnitPerArea[idx];
      }
    } else {
      selectedKodeUnitKebunPabrik.value = null;
    }

    fetchUnitList();
  }

  void switchKategoriKendaraan(String? val) {
    if (val == null) return;
    selectedKategoriKendaraan.value = val;

    _resetToManualInput();
    ioController.clear();
    platController.clear();
    isPlatReadOnly.value = false;

    if (val == 'TAMU') {
      _setupTamuMode(val);
      selectedKodeKebunPabrik.value = userTitleUnit.value;
      selectedKodeUnitKebunPabrik.value = userKodeUnit.value;
    } else {
      _setupInternalMode();
      searchUnit('');

      if (val == 'VENDOR' || (!val.contains('NON') && val.contains('INTERNAL'))) {
        selectedKodeKebunPabrik.value = userTitleUnit.value;
        selectedKodeUnitKebunPabrik.value = userKodeUnit.value;
      } else {
        selectedKodeKebunPabrik.value = null;
        selectedKodeUnitKebunPabrik.value = null;
      }

      fetchUnitList();
    }
    update();
  }

  void _setupInternalMode() {
    selectedUnit.value = null;

    ratioC.text = "0"; // Default 0
    ratioInput.text = ""; // UI 0
    isRatioReadOnly.value = false;

    pengisianSolarC.text = "";
    isLiterReadOnly.value = false;
    isIoReadOnly.value = true;
  }

  void _setupTamuMode(String kategori) {
    final tamuUnit = MasterIoModel(
        namaUnit: kategori,
        description: "External $kategori",
        internalOrder: "-",
        noPolisi: "-",
        isActive: true);
    selectedUnit.value = tamuUnit;

    tipeUnit.value = "KD";
    tipeUnitC.text = "KD";
    satuan.value = "KM";
    satuanC.text = "KM";

    hmKmAwalC.text = "0";
    hmKmAkhirC.text = "0";
    dateAwalC.text = "";
    dateAkhirC.text = "";
    varianC.text = "0";
    ratioC.text = "0";
    ratioInput.text = ""; // UI

    isHmKmAwalReadOnly.value = true;
    isHmKmAkhirReadOnly.value = true;
    isVarianReadOnly.value = true;
    isRatioReadOnly.value = true;

    pengisianSolarC.text = "0";
    isLiterReadOnly.value = false; // (Editable)

    isIoReadOnly.value = false;
    filteredUnitList.assignAll([tamuUnit]);
  }

  void switchJenisBon(String? val) {
    if (val == null) return;
    selectedJenisBon.value = val;
    update();
  }

  Future<void> pickDate(BuildContext context, bool isStart) async {
    DateTime initialDate = DateTime.now();
    try {
      String currentText = isStart ? dateAwalC.text : dateAkhirC.text;
      if (currentText.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(currentText);
      }
    } catch (_) {}

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
      String formattedDisplay = DateFormat('dd/MM/yyyy').format(picked);
      String formattedApi = DateFormat('yyyy-MM-dd').format(picked);

      if (isStart) {
        dateAwalC.text = formattedDisplay;
        dateAwal.value = formattedApi;
      } else {
        dateAkhirC.text = formattedDisplay;
        dateAkhir.value = formattedApi;
      }
      _calculateAutomatedValues();
    }
  }

  Future<void> pickTanggalTransaksi(BuildContext context) async {
    DateTime now = DateTime.now();
    DateTime maxDate = now;
    DateTime minDate = DateTime(now.year, now.month - 2, now.day);
    
    DateTime initialDate = now;
    try {
      if (tanggalTransaksiC.text.isNotEmpty) {
        initialDate = DateFormat('dd/MM/yyyy').parse(tanggalTransaksiC.text);
      }
    } catch (_) {}

    if (initialDate.isAfter(maxDate)) {
      initialDate = maxDate;
    } else if (initialDate.isBefore(minDate)) {
      initialDate = minDate;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: minDate,
      lastDate: maxDate,
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
      tanggalTransaksiC.text = DateFormat('dd/MM/yyyy').format(picked);
      tanggalTransaksi.value = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  void _calculateAutomatedValues() {
    if (isTamu) return;

    if (isTipeGenset) {
      _calculateGensetDiff();
      return;
    }

    String tipe = tipeUnit.value?.trim().toUpperCase() ?? "";
    double awal = TextConvertHelper().parseToDouble(hmKmAwalC.text);
    double akhir = TextConvertHelper().parseToDouble(hmKmAkhirC.text);
    double ratioVal = TextConvertHelper().parseToDouble(ratioInput.text);
    double diff = (akhir - awal) > 0 ? (akhir - awal) : 0;
    String newVarianStr =
        diff % 1 == 0 ? diff.toInt().toString() : diff.toString();

    if (varianC.text != newVarianStr) {
      varianC.text = newVarianStr;
    }

    double estimasiLiter = 0;

    if (diff > 0) {
      String tipe = tipeUnit.value?.trim().toUpperCase() ?? "";
      if (tipe == 'KD' || tipe == 'AD') {
        if (ratioVal > 0) {
          estimasiLiter = diff / ratioVal;
        }
      } else if (tipe == 'AB') {
        estimasiLiter = diff * ratioVal;
      }
    }

    String newLiterStr = estimasiLiter.round().toString();

    if (pengisianSolarC.text != newLiterStr) {
      if (!pengisianSolarC.text.endsWith('.')) {
        pengisianSolarC.text = newLiterStr;
      }
    }
  }

  void _calculateVarianSolar() {
    double estimasi = double.tryParse(pengisianSolarC.text.replaceAll(',', '.')) ?? 0;
    String cleanAktual = aktualSolarC.text.replaceAll(',', '.');
    double aktual = double.tryParse(cleanAktual) ?? 0;
    double result = aktual - estimasi;

    String formatted = result % 1 == 0
        ? result.toInt().toString()
        : result.toStringAsFixed(2).replaceAll('.', ',');

    varianSolarC.text = formatted;
  }

  DateTime? _parseFlexibleDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      if (dateStr.contains('/')) {
        return DateFormat('dd/MM/yyyy').parse(dateStr);
      } else {
        return DateFormat('yyyy-MM-dd').parse(dateStr);
      }
    } catch (_) {
      return null;
    }
  }

  void _calculateGensetDiff() {
    try {
      if (dateAwalC.text.isEmpty || dateAkhirC.text.isEmpty) return;
      DateTime? start = _parseFlexibleDate(dateAwalC.text);
      DateTime? end = _parseFlexibleDate(dateAkhirC.text);

      if (start != null && end != null) {
        int difference = end.difference(start).inDays;
        if (difference < 0) difference = 0;
        varianC.text = difference.toString();
      }
    } catch (e) {
      varianC.text = "0";
    }
  }

  void fetchUnitList() async {
    try {
      isLoadingUnit.value = true;

      final isVendor = (selectedKategoriKendaraan.value ?? '').toUpperCase() == 'VENDOR';
      final isTamuKategori = selectedKategoriKendaraan.value?.contains('TAMU') ?? false;
      String? currentUnitId = selectedKodeUnitKebunPabrik.value;

      List<MasterIoModel> data;

      if (isVendor) {
        data = await _apiService.getVendorList();
      } else {
        data = await _apiService.getMasterIoList(
            unitId: isTamuKategori ? null : currentUnitId);
      }

      _allUnitList = data;
      filteredUnitList.assignAll(data);

      update();
      // _checkAndRestoreDraft();
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        Get.snackbar(
          'Koneksi Terputus',
          'Gagal terhubung ke server. Pastikan perangkat Anda terhubung ke internet.',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          icon: const Icon(Icons.wifi_off, color: Colors.white),
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(16),
        );
      } else {
        // Error API lainnya (Misal 404, 500)
        Get.snackbar('Gagal Memuat Data',
            'Terjadi kesalahan server (${e.response?.statusCode ?? "Unknown"}).',
            backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      }
    } catch (e) {
      // Handling Error Umum Lainnya
      Get.snackbar('Error', 'Terjadi kesalahan aplikasi: $e',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    } finally {
      isLoadingUnit.value = false;
    }
  }

  Future<void> fetchUnitsPerArea() async {
    final auth = _loginService.getCurrentAuth();
    if (auth != null && auth.currentKodeUnit != null) {
      isLoadingUnitsPerArea.value = true;

      try {
        var data = await _apiService.getUnitsPerArea(auth.currentKodeUnit!);
        List<String> titles = [];
        List<String> units = [];

        String defaultTitle = userInitialTitle;
        String defaultUnit = auth.currentKodeUnit ?? "";
        if (data.isNotEmpty && defaultUnit.isEmpty) {
          defaultUnit = data.first['kode_unit']?.toString() ?? "";
        }

        for (var item in data) {
          String title = item['title_unit']?.toString() ?? "";
          String unit = item['kode_unit']?.toString() ?? "";

          if (title.isNotEmpty && !titles.contains(title)) titles.add(title);
          if (unit.isNotEmpty && !units.contains(unit)) units.add(unit);

          if (item['kode_unit'] == auth.currentKodeUnit) {
            defaultTitle = title;
            defaultUnit = unit;
          }
        }

        String oldCategory = selectedKategoriKendaraan.value ?? '';
        String? oldKebun = selectedKodeKebunPabrik.value;

        selectedKategoriKendaraan.value = null;
        selectedKodeKebunPabrik.value = null;

        listTitleUnitPerArea.assignAll(titles);
        listKodeUnitPerArea.assignAll(units);

        userTitleUnit.value = defaultTitle;
        userKodeUnit.value = defaultUnit;

        jenisKategoriList.assignAll([
          'INTERNAL $defaultTitle',
          'INTERNAL NON $defaultTitle',
          'VENDOR',
          'TAMU'
        ]);

        selectedKategoriKendaraan.value = 'INTERNAL $defaultTitle';
        selectedKodeKebunPabrik.value = defaultTitle;
        selectedKodeUnitKebunPabrik.value = defaultUnit;
      } catch (e) {
        print("Error fetchUnitsPerArea: $e");
      } finally {
        isLoadingUnitsPerArea.value = false;
        fetchUnitList();
      }
    }
  }

  void searchUnit(String keyword) {
    _lastSearchKeyword = keyword;
    applyUnitFilter();
  }

  void setFilterStatus(String? status) {
    filterStatusUnit.value = (status == null || filterStatusUnit.value == status) ? null : status;
    applyUnitFilter();
  }

  void resetUnitFilters() {
    filterStatusUnit.value = null;
    _lastSearchKeyword = '';
    filteredUnitList.assignAll(_allUnitList);
  }

  void applyUnitFilter() {
    var result = _allUnitList.where((unit) {
      bool matchKeyword = true;
      if (_lastSearchKeyword.isNotEmpty) {
        final input = _lastSearchKeyword.toLowerCase();
        matchKeyword =
            (unit.namaUnit ?? '').toLowerCase().contains(input) ||
                (unit.description ?? '').toLowerCase().contains(input) ||
                (unit.internalOrder ?? '').toLowerCase().contains(input) ||
                (unit.noPolisi ?? '').toLowerCase().contains(input);
      }

      bool matchStatus = true;
      if (filterStatusUnit.value != null) {
        matchStatus = (unit.statusUnit ?? '').toUpperCase() == filterStatusUnit.value;
      }

      return matchKeyword && matchStatus;
    }).toList();

    result.sort((a, b) {
      const order = {'U': 0, 'S': 1};
      int rankA = order[(a.statusUnit ?? '').toUpperCase()] ?? 2;
      int rankB = order[(b.statusUnit ?? '').toUpperCase()] ?? 2;
      if (rankA != rankB) return rankA.compareTo(rankB);
      return (a.namaUnit ?? '').compareTo(b.namaUnit ?? '');
    });

    filteredUnitList.assignAll(result);
  }

  void onUnitSelected(MasterIoModel unit) async {
    if (!await ConnectivityHelper.validateNetwork()) return;
    if (isTamu) return;

    tipeUnit.value = null;
    selectedUnit.value = unit;
    selectedReplacedUnit.value = null;

    _resetToManualInput();

    ratioInput.text = "";
    isRatioReadOnly.value = false;
    pengisianSolarC.text = "0";
    isLiterReadOnly.value = false;
    isIoReadOnly.value = true;

    // Cek apakah Unit Pengganti (status S)
    final statusUnit = (unit.statusUnit ?? '').toUpperCase();
    isUnitPengganti.value = (statusUnit == 'S');

    if (isUnitPengganti.value) {
      // No Plat dari Unit Pengganti
      String plat = (unit.noPolisi ?? "").trim();
      if (plat.isNotEmpty && plat != "-") {
        platController.text = plat;
        isPlatReadOnly.value = true;
      } else {
        platController.text = '';
        isPlatReadOnly.value = false;
      }
      // IO dikosongkan dulu, menunggu user pilih Unit Utama
      ioController.text = '';
      // Populate list Unit Utama (filter hanya status U)
      _populateMainUnitList();
    } else {
      isUnitPengganti.value = false;
      ioController.text = unit.internalOrder ?? '-';

      String plat = (unit.noPolisi ?? "").trim();
      if (plat.isNotEmpty && plat != "-") {
        platController.text = plat;
        isPlatReadOnly.value = true;
      } else {
        platController.text = '';
        isPlatReadOnly.value = false;
      }

      await _fetchDetailFromApi(unit.internalOrder);

      if (tipeUnit.value == null) {
        _determineTipeByNamaUnit(unit);
      }

      if (tipeUnit.value == 'AB' || tipeUnit.value == 'GS') {
        platController.text = unit.namaUnit ?? '';
        isPlatReadOnly.value = false;
      }
    }
    searchUnit('');
  }

  /// Dipanggil saat user memilih Unit Utama yang digantikan (field kedua)
  Future<void> onReplacedUnitSelected(MasterIoModel unit) async {
    selectedReplacedUnit.value = unit;
    // IO diambil dari Unit Utama yang dipilih
    ioController.text = unit.internalOrder ?? '-';
    isIoReadOnly.value = true;

    await _fetchDetailFromApi(unit.internalOrder);

    if (tipeUnit.value == null) {
      _determineTipeByNamaUnit(unit);
    }

    if (tipeUnit.value == 'AB' || tipeUnit.value == 'GS') {
      platController.text = selectedUnit.value?.namaUnit ?? '';
      isPlatReadOnly.value = false;
    }

    Get.back(); // tutup bottom sheet
  }

  void _populateMainUnitList() {
    // Filter hanya Unit Utama (status U) dari list yang sudah ada
    final mainUnits = _allUnitList
        .where((u) => (u.statusUnit ?? '').toUpperCase() == 'U')
        .toList();
    filteredMainUnitList.assignAll(mainUnits);
  }

  void searchMainUnit(String keyword) {
    _lastSearchMainKeyword = keyword;
    if (keyword.isEmpty) {
      _populateMainUnitList();
      return;
    }
    final input = keyword.toLowerCase();
    final result = _allUnitList
        .where((u) => (u.statusUnit ?? '').toUpperCase() == 'U')
        .where((u) =>
            (u.namaUnit ?? '').toLowerCase().contains(input) ||
            (u.description ?? '').toLowerCase().contains(input) ||
            (u.internalOrder ?? '').toLowerCase().contains(input) ||
            (u.noPolisi ?? '').toLowerCase().contains(input))
        .toList();
    filteredMainUnitList.assignAll(result);
  }

  void _determineTipeByNamaUnit(MasterIoModel unit) {
    String tipeUnitIo = (unit.tipeUnitIo ?? "").toUpperCase();

    String hasilTipe = "KD";
    String hasilSatuan = "KM";

    if (tipeUnitIo.startsWith("KR")) {
      hasilTipe = "KD";
      hasilSatuan = "KM";
    } else if (tipeUnitIo.startsWith("AB")) {
      hasilTipe = "AB";
      hasilSatuan = "HM";
    } else if (tipeUnitIo.startsWith("MS")) {
      hasilTipe = "GS";
      hasilSatuan = "Hour";
    } else {
      // Fallback
      String nama = (unit.namaUnit ?? "").toUpperCase();
      String deskripsi = (unit.description ?? "").toUpperCase();
      String gabungan = "$nama $deskripsi";

      if (gabungan.contains("DT") ||
          gabungan.contains("BUS") ||
          gabungan.contains("LV")) {
        hasilTipe = "KD";
        hasilSatuan = "KM";
      } else if (gabungan.contains("EXCA") ||
          gabungan.contains("DOZER") ||
          gabungan.contains("PC")) {
        hasilTipe = "AB";
        hasilSatuan = "HM";
      } else if (gabungan.contains("GENSET") ||
          gabungan.contains("GS") ||
          gabungan.contains("WP") ||
          gabungan.contains("GST")) {
        hasilTipe = "GS";
        hasilSatuan = "Hour";
      }
    }

    tipeUnit.value = hasilTipe;
    satuan.value = hasilSatuan;
    tipeUnitC.text = hasilTipe;
    satuanC.text = hasilSatuan;
  }

  /// Fetch detail unit dari API (HM/KM/Tanggal/Tipe/Ratio) berdasarkan internal order
  Future<void> _fetchDetailFromApi(String? io) async {
    if (io == null || io == '-') return;

    try {
      final detail = await _apiService.getMasterIoDetail(io);
      if (detail == null) {
        // Fallback ke data lokal jika API gagal
        final localDetail = _homeService.getUnitData(io);
        if (localDetail != null) {
          _applyLocalDetail(localDetail);
        }
        return;
      }

      // Tipe Unit dari API
      String? tipeApi = detail['tipe_unit_io']?.toString().toUpperCase();

      if (tipeApi != null && tipeApi.isNotEmpty) {
        tipeUnit.value = tipeApi;
        tipeUnitC.text = tipeApi;
        // Satuan berdasarkan tipe
        String satuanVal = (tipeApi == 'AB') ? 'HM' : (tipeApi == 'GS') ? 'Hour' : 'KM';
        satuan.value = satuanVal;
        satuanC.text = satuanVal;
      }

      // Ambil HM/KM (untuk tipe KD / AB)
      if (tipeApi == 'KD' || tipeApi == 'AB' || tipeApi == 'AD' || tipeApi == null || tipeApi.isEmpty) {
        String? hmKmAwalRaw = detail['hm_km_awal']?.toString();

        if (hmKmAwalRaw != null && hmKmAwalRaw != 'null' && hmKmAwalRaw != '0.0' && hmKmAwalRaw != '0') {
          double val = double.tryParse(hmKmAwalRaw) ?? 0.0;
          hmKmAwalC.text = (val % 1 == 0) ? val.toInt().toString() : val.toString();
          // isHmKmAwalReadOnly.value = true;
        }
      }

      // Ambil Tanggal (untuk tipe GS)
      if (tipeApi == 'GS') {
        String? tglAwal = detail['tanggal_awal']?.toString();
        String? tglAkhir = detail['tanggal_akhir']?.toString();

        if (tglAwal != null && tglAwal != 'null' && tglAwal.isNotEmpty) {
          try {
            final parsed = DateTime.parse(tglAwal);
            dateAwalC.text = '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
            dateAwal.value = tglAwal;
            isDateAwalReadOnly.value = true;
          } catch (_) {}
        }

        if (tglAkhir != null && tglAkhir != 'null' && tglAkhir.isNotEmpty) {
          try {
            final parsed = DateTime.parse(tglAkhir);
            dateAkhirC.text = '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
            dateAkhir.value = tglAkhir;
            isDateAkhirReadOnly.value = true;
          } catch (_) {}
        }
      }

      // Ambil Ratio
      String? ratioRaw = detail['ratio']?.toString();
      if (ratioRaw != null && ratioRaw != 'null') {
        double ratioVal = double.tryParse(ratioRaw) ?? 0.0;
        String ratioClean = (ratioVal % 1 == 0) ? ratioVal.toInt().toString() : ratioVal.toString();
        ratioC.text = ratioClean;
        ratioInput.text = ratioClean;
      } else {
        ratioC.text = "0";
        ratioInput.text = "";
      }

      _calculateAutomatedValues();
    } catch (e) {
      print("Error _fetchDetailFromApi: $e");
    }
  }

  void _applyLocalDetail(dynamic detail) {
    tipeUnit.value = detail.tipe;
    satuan.value = detail.satuan;
    tipeUnitC.text = detail.tipe ?? "";
    satuanC.text = detail.satuan ?? "";

    if (detail.hmKmAwal != null) {
      double val = double.tryParse(detail.hmKmAwal.toString()) ?? 0.0;
      hmKmAwalC.text = (val % 1 == 0) ? val.toInt().toString() : val.toString();
    }

    if (detail.ratio != null) {
      double ratioVal = double.tryParse(detail.ratio.toString()) ?? 0.0;
      String ratioClean = (ratioVal % 1 == 0) ? ratioVal.toInt().toString() : ratioVal.toString();
      ratioC.text = ratioClean;
      ratioInput.text = ratioClean;
    } else {
      ratioC.text = "0";
      ratioInput.text = "";
    }

    _calculateAutomatedValues();
  }

  void _resetToManualInput() {
    hmKmAwalC.clear();
    isHmKmAwalReadOnly.value = false;
    hmKmAkhirC.clear();
    isHmKmAkhirReadOnly.value = false;
    dateAwalC.clear();
    isDateAwalReadOnly.value = false;
    dateAkhirC.clear();
    isDateAkhirReadOnly.value = false;
    varianC.clear();
    isVarianReadOnly.value = false;

    ratioC.text = "0";
    ratioInput.text = "";
    isRatioReadOnly.value = false;

    pengisianSolarC.clear();
    isLiterReadOnly.value = false;

    isLangsungPom.value = false;

    aktualSolarC.clear();
    varianSolarC.clear();
    _createdNoDoc = null;
    fotoDispenser.value = null;
    fotoSupir.value = null;

    // Reset Unit Pengganti state
    isUnitPengganti.value = false;
    selectedReplacedUnit.value = null;
    filteredMainUnitList.clear();

    if (selectedUnit.value == null) {
      tipeUnit.value = null;
    }
  }

  void onStatusSupirChanged(String? val) {
    selectedStatusSupir.value = val;
  }

  void validateAndProceed() {
    if (isSubmitting.value) return;
    try {
      if (_validateForm()) _processSubmitToApi();
    } catch (e, stack) {
      print("Error validateAndProceed: $e\n$stack");
      Get.snackbar("Terjadi Kesalahan", "Gagal memproses data: $e",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }

  Future<void> takeOdometerPhoto() async {
    try {
      isTakingPhoto.value = true;

      // Membuka halaman Custom Camera bawaan aplikasi Anda
      final String? resultPath = await Get.to(() => const CustomCameraView(
            label: "Foto Odometer Kendaraan",
          ));

      // Jika user klik tombol back atau cancel
      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      // Mulai kompresi file foto
      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        fotoOdometer.value = compressedFile;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    } finally {
      isTakingPhoto.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
      if (lastIndex == -1)
        return file; // Jika ekstensi tidak dikenali, kembalikan aslinya

      final splitted = file.path.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";

      final outCheck = File(outPath);
      if (await outCheck.exists()) {
        await outCheck.delete();
      }

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        outPath,
        quality: 60,
        minWidth: 1024,
        minHeight: 1024,
      );

      await file.delete();
      return result != null ? File(result.path) : null;
    } catch (e) {
      return file; // Jika gagal compress, gunakan file asli
    }
  }

  void hapusFotoOdometer() {
    fotoOdometer.value = null;
  }

  Future<void> takePhotoTAMU(bool isSupir) async {
    try {
      isTakingPhoto.value = true;
      String labelCamera = isSupir ? "Foto Supir" : "Foto Angka Meter Dispenser";

      final String? resultPath = await Get.to(() => CustomCameraView(
            label: labelCamera,
          ));

      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      File originalFile = File(resultPath);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile != null) {
        if (isSupir) {
          fotoSupir.value = compressedFile;
        } else {
          fotoDispenser.value = compressedFile;
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    } finally {
      isTakingPhoto.value = false;
    }
  }

  void hapusFotoTAMU(bool isSupir) {
    if (isSupir) {
      fotoSupir.value = null;
    } else {
      fotoDispenser.value = null;
    }
  }

  bool _validateForm() {
    if (selectedJenisBon.value == null ||
        selectedUnit.value == null ||
        selectedStatusSupir.value == null ||
        driverNameC.text.isEmpty ||
        (!isTamu && pengisianSolarC.text.isEmpty) ||
        platController.text.isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Harap lengkapi semua form inputan!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (!isManualInput.value && fotoOdometer.value == null) {
      String msg = isTipeGenset ? 'Foto Jerigen / Genset wajib dilampirkan!' : (tipeUnit.value?.toUpperCase() == 'AB' ? 'Foto Baby Tank wajib dilampirkan!' : 'Foto Odometer wajib dilampirkan!');
      Get.snackbar('Data Belum Lengkap', msg,
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (isManualInput.value) {
      if (aktualSolarC.text.isEmpty || double.tryParse(aktualSolarC.text.replaceAll(',', '.')) == 0) {
        Get.snackbar(
          'Data Belum Lengkap', 'Harap isi Aktual Pengeluaran Solar.',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white, margin: const EdgeInsets.all(16));
        return false;
      }
      if (tanggalTransaksi.value == null || tanggalTransaksiC.text.isEmpty) {
        Get.snackbar(
          'Data Belum Lengkap', 'Harap pilih Tanggal Transaksi.',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white, margin: const EdgeInsets.all(16));
        return false;
      }
    }

    if (selectedKategoriKendaraan.value == null) {
      Get.snackbar('Data Belum Lengkap', 'Pilih Kategori terlebih dahulu!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if ((selectedKategoriKendaraan.value ?? '').contains('INTERNAL NON') &&
        selectedKodeKebunPabrik.value == null) {
      Get.snackbar(
          'Data Belum Lengkap', 'Pilih Kode Kebun/Pabrik terlebih dahulu!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (driverNameC.text.trim().length < 3) {
      Get.snackbar('Validasi Supir', 'Nama Supir/Operator minimal 3 karakter!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    double inputSolar = double.tryParse(
            TextConvertHelper().cleanNumber(pengisianSolarC.text)) ??
        0;
    if (inputSolar <= 0 && !isTamu && !isTipeGenset) {
      Get.snackbar(
          'Validasi Solar', 'Jumlah pengisian solar harus lebih dari 0',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return false;
    }

    // Validasi untuk Tipe Kendaraan (KD/AB) - Kecuali Tamu
    if (isTipeKendaraan && !isTamu) {
      double awal =
          double.tryParse(TextConvertHelper().cleanNumber(hmKmAwalC.text)) ?? 0;
      double akhir =
          double.tryParse(TextConvertHelper().cleanNumber(hmKmAkhirC.text)) ??
              0;

      if (awal > akhir) {
        String satuanLabel = (tipeUnit.value == 'AB') ? 'HM' : 'KM';
        Get.snackbar(
          'Validasi Meteran',
          '$satuanLabel Awal ($awal) tidak boleh lebih besar dari $satuanLabel Akhir ($akhir).',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
        );
        return false;
      }
    }

    // Validasi untuk Genset (Menggunakan Tanggal) - Kecuali Tamu
    if (!isTipeKendaraan && !isTamu) {
      // Asumsi GS atau lainnya pakai Tanggal
      if (dateAwalC.text.isNotEmpty && dateAkhirC.text.isNotEmpty) {
        DateTime? start = _parseFlexibleDate(dateAwalC.text);
        DateTime? end = _parseFlexibleDate(dateAkhirC.text);

        if (start != null && end != null) {
          if (start.isAfter(end)) {
            Get.snackbar(
              'Validasi Tanggal',
              'Tanggal Awal tidak boleh lebih besar dari Tanggal Akhir.',
              backgroundColor: AppColors.alertSoftRed,
              colorText: Colors.white,
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            );
            return false;
          }
        }
      }
    }

    if (isTamu && ioController.text.trim().isEmpty) {
      Get.snackbar(
          'Data Belum Lengkap', 'Cost Center wajib diisi untuk kategori Tamu!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (selectedJenisBon.value == 'BPB' && noDocInputC.text.trim().isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Harap input No. Doc untuk BPB!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    // Validasi: jika Unit Pengganti, wajib pilih Unit yang Digantikan
    if (isUnitPengganti.value && selectedReplacedUnit.value == null) {
      Get.snackbar(
        'Data Belum Lengkap',
        'Unit Pengganti dipilih. Harap pilih Unit Utama yang digantikan terlebih dahulu!',
        backgroundColor: AppColors.alertSoftRed,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      );
      return false;
    }

    return true;
  }

  void _processSubmitToApi() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: "Konfirmasi Submit",
        message: "Apakah data inputan sudah sesuai semua?",
        primaryColor: AppColors.primaryOrange,
        secondaryColor: AppColors.secondaryOrange,
        secondaryButtonText: "Kembali",
        onSecondaryPressed: () => Get.back(),
        primaryButtonText: "Submit",
        onPrimaryPressed: () {
          if (isSubmitting.value) return;
          Get.back();
          _submitDataToApi();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _submitDataToApi() async {
    isSubmitting.value = true;
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryOrange),
              const SizedBox(height: 24),
              Text(
                "Sedang Mengirim Data...",
                style: AppFonts.fUrbanistBold16
                    .copyWith(color: AppColors.primaryText),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Mohon jangan tutup aplikasi",
                style: AppFonts.fUrbanistRegular12
                    .copyWith(color: AppColors.secondaryText),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      bool isOnline = await ConnectivityHelper.isConnected();
      String inputTypeStr = isOnline ? "A" : "M";

      String cleanKm = TextConvertHelper().cleanNumber(hmKmAkhirC.text);
      String rawSolar = isTamu ? aktualSolarC.text : pengisianSolarC.text;
      double solarDouble = TextConvertHelper().parseToDouble(rawSolar);

      String namaSupirFinal = driverNameC.text;
      // String docType = (selectedJenisBon.value == 'BPB') ? "BPB" : "Bon Sementara";
      double ratioDefault = TextConvertHelper().parseToDouble(ratioC.text);
      double ratioUser = TextConvertHelper().parseToDouble(ratioInput.text);

      Map<String, dynamic> payloadRequestAPI = {
        "unit_pengganti": () {
          if (!isUnitPengganti.value) return "-";
          final unit = selectedUnit.value;
          if (unit == null) return "-";
          final nama = (unit.namaUnit ?? "").trim();
          if (nama.isNotEmpty && nama != "-" && nama != "--") return nama;
          final desc = (unit.description ?? "").trim();
          return desc.isNotEmpty ? desc : "-";
        }(),
        "supir_check": namaSupirFinal.toUpperCase(),
        "keterangan": keteranganC.text.isEmpty ? "-" : keteranganC.text,
        "km_pengisian": double.tryParse(cleanKm) ?? 0,
        "doc_type": "FOT",
        "hm_km_akhir": double.tryParse(hmKmAkhirC.text) ?? 0,
        "no_io": isTamu ? "-" : ioController.text,
        "unit_io": (selectedUnit.value?.namaUnit?.isNotEmpty == true
            ? selectedUnit.value!.namaUnit
            : (selectedUnit.value?.description?.isNotEmpty == true
                ? selectedUnit.value!.description
                : (selectedUnit.value?.noPolisi ?? '-'))),
        "liter": solarDouble,
        "hm_km_awal": double.tryParse(hmKmAwalC.text) ?? 0,
        "cost_center": isTamu ? ioController.text.toUpperCase() : "-",
        "status_supir": selectedStatusSupir.value ?? "Internal",
        "ratio": ratioDefault,
        "ratio_input": ratioUser,
        "tipe_unit_io": tipeUnitC.text,
        "varian": double.tryParse(varianC.text) ?? 0,
        "input_type": inputTypeStr,
        "jumlah_pengisian_solar": solarDouble,
        "tanggal_akhir": (dateAkhir.value == null || dateAkhir.value == "")
            ? ""
            : dateAkhir.value,
        "kategori_kendaraan": () {
          final kategori = (selectedKategoriKendaraan.value ?? "").toUpperCase();
          if (kategori.contains("INTERNAL NON")) return "INC";
          if (kategori.contains("INTERNAL")) return "INT";
          if (kategori.contains("TAMU")) return "TMU";
          if (kategori.contains("VENDOR")) return "VEN";
          return selectedKategoriKendaraan.value ?? "";
        }(),
        "tanggal_awal": (dateAwal.value == null || dateAwal.value == "")
            ? ""
            : dateAwal.value,
        "nopol_check": platController.text.toUpperCase(),
        "jenis_pengeluaran": selectedJenisBon.value ?? "-",
        "satuan": satuanC.text,
        "kode_unit": userKodeUnit.value,
        "kode_unit_original": selectedKodeUnitKebunPabrik.value ?? "",
        "no_doc": selectedJenisBon.value == 'BPB' ? noDocInputC.text : "",
        "has_tf": (tipeUnitC.text == "AB" && isLangsungPom.value) ? true : false,
        "is_baby_tank": isLangsungPom.value,
        "date_inbound": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "tanggal_transaksi": isManualInput.value && tanggalTransaksi.value != null 
            ? tanggalTransaksi.value 
            : DateFormat('yyyy-MM-dd').format(DateTime.now()),
      };

      // try {
      //   String prettyPayload = const JsonEncoder.withIndent('  ').convert(payloadRequestAPI);
      //   print("====== PAYLOAD SUBMIT PENGELUARAN ======\n$prettyPayload\n========================================");
      // } catch (e) {
      //   print("Payload: $payloadRequestAPI");
      // }

      List<File?> photos = [isManualInput.value ? null : fotoOdometer.value, null, null];
      String noDoc = _createdNoDoc ?? "-";
      
      if (_createdNoDoc == null) {
        final response = await _apiService.createInboundFot(payloadMap: payloadRequestAPI, photos: photos);
        noDoc = selectedJenisBon.value == 'BPB' ? noDocInputC.text : (response['no_doc'] ?? "-");
        _createdNoDoc = noDoc;
      }

      await _saveToOutstanding(noDoc, payloadRequestAPI, fotoOdometer.value);
      await _draftService.deleteDraft();

      if (isManualInput.value) {
        // Lanjutkan API 2,3,4 langsung
        final auth = _loginService.getCurrentAuth();
        if (auth == null) throw "Data user tidak valid.";

        String userLevel = auth.user.otorisasi.first;
        String kodeUnit = auth.currentKodeUnit ?? "";

        List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
          transactionType: 'FOT',
          kodeUnit: kodeUnit,
          statusActive: true,
        );

        KonfigurasiApprovalModel myConfig = configList.firstWhere(
          (config) => config.levelApproval == userLevel,
          orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval untuk tipe FOT.",
        );

        double finalSolar = double.tryParse(aktualSolarC.text.replaceAll(',', '.')) ?? 0;
        double finalVarianLiter = double.tryParse(varianSolarC.text.replaceAll(',', '.')) ?? 0;
        double finalKm = double.tryParse(cleanKm) ?? 0;

        await _apiService.createTransactionApproval(
            noDoc: noDoc,
            kodeUnit: kodeUnit,
            transactionType: 'FOT'
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (selectedJenisBon.value == 'BPB') {
          await _apiService.updateStatusTransactionApprovalBpb(
            noDoc: noDoc,
            levelApproval: myConfig.levelApproval ?? "1",
            statusApprove: 'APPROVED',
            catatan: "Verifikasi Langsung Tanpa TTD (BPB)",
            isSign: false,
            isPartnerSign: false,
          );
        } else {
          await _apiService.updateStatusTransactionApproval(
            noDoc: noDoc,
            levelApproval: myConfig.levelApproval ?? "1",
            statusApprove: 'APPROVED',
            catatan: "Verifikasi Langsung Tanpa TTD (FOT)",
            isSign: false,
            isPartnerSign: false,
          );
        }

        await Future.delayed(const Duration(milliseconds: 200));

        if (selectedJenisBon.value == 'BPB') {
          await _apiService.updateAktualLiterPengeluaranBPB(
              noDoc: noDoc,
              aktual: finalSolar,
              varianLiter: finalVarianLiter
          );
        } else {
          await _apiService.updateAktualLiterPengeluaran(
              noDoc: noDoc,
              aktual: finalSolar,
              varianLiter: finalVarianLiter
          );
        }

        if (selectedStatusSupir.value == 'Internal') {
          final HomeController homeController = Get.find<HomeController>();
          String currentUnit = homeController.selectedUnitCode.value;
          String currentStorageName = homeController.selectedStorage.value;
          String storageCode = currentStorageName.contains('-')
              ? currentStorageName.split('-').last.trim()
              : currentStorageName.trim();

          await _homeService.updateUnitAfterTransaction(
              ioController.text,
              finalKm,
              (dateAkhir.value == null || dateAkhir.value == "") ? "" : dateAkhir.value!,
              finalSolar,
              ratioC.text,
              unitCodeOverride: currentUnit,
              storageCodeOverride: storageCode
          );
        }
        
        final outstandingService = OutstandingService(auth.user.username);
        final pengeluaranDetail = PengeluaranModel(
          docType: 'FOT',
          noDoc: noDoc,
          noIo: ioController.text,
          unitIO: selectedUnit.value?.namaUnit,
          nopolCheck: platController.text.toUpperCase(),
          statusSupir: selectedStatusSupir.value ?? "Internal",
          supirCheck: namaSupirFinal.toUpperCase(),
          kmPengisian: finalKm,
          liter: solarDouble,
          varian: finalVarianLiter,
          jumlahPengisianSolar: finalSolar,
          userName: auth.user.username,
          dateOutbound: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        );
        final trx = TransactionPengeluaranModel(
          noBast: noDoc,
          status: 'selesai',
          dateCreated: DateTime.now().toIso8601String(),
          dataPengeluaran: pengeluaranDetail,
        );
        await outstandingService.saveTransactionPengeluaran(trx);

        isSubmitting.value = false;
        Get.back();
        Get.dialog(
          DialogFlexible(
            logo: LottiesHelper().getLottieSuccess(),
            title: "Berhasil",
            message: "Data pengeluaran berhasil disubmit!",
            primaryColor: AppColors.primaryOrange,
            secondaryColor: AppColors.secondaryOrange,
            primaryButtonText: "Kembali ke Beranda",
            onPrimaryPressed: () {
              Get.offAllNamed(Routes.HOME);
            },
          ),
          barrierDismissible: false,
        );
      } else {
        Get.back();
        Get.offNamed(
          Routes.PENGISIAN_SOLAR_PENGELUARAN,
          arguments: {
            'noDoc': noDoc,
            'unitIO': (selectedUnit.value?.namaUnit?.isNotEmpty == true
                ? selectedUnit.value!.namaUnit
                : (selectedUnit.value?.description?.isNotEmpty == true
                    ? selectedUnit.value!.description
                    : (selectedUnit.value?.noPolisi ?? '-'))),
            'tanggal': DateFormat('dd/MM/yyyy').format(DateTime.now()),
            'status': 'pengisian_solar_pengeluaran',
            'payload': payloadRequestAPI,
            'isManualInput': isManualInput.value,
            'jenis_pengeluaran': selectedJenisBon.value,
          },
        );
      }
    } on DioException catch (e) {
      isSubmitting.value = false;
      Get.back();
      _handleApiError(e);
    } catch (e) {
      isSubmitting.value = false;
      Get.back();
      Get.snackbar("Error", "Terjadi kesalahan aplikasi: $e",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }

  Future<void> _saveToOutstanding(
      String noDoc, Map<String, dynamic> payload, File? foto) async {
    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

    final outstandingService = OutstandingService(auth.user.username);
    final pengeluaranDetail = PengeluaranModel(
        noDoc: noDoc,
        noIo: payload['no_io'],
        unitIO: payload['unit_io'],
        nopolCheck: payload['nopol_check'],
        statusSupir: payload['status_supir'],
        supirCheck: payload['supir_check'],
        kmPengisian: payload['km_pengisian'],
        jumlahPengisianSolar: payload['jumlah_pengisian_solar'],
        userName: auth.user.username,
        dateOutbound: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
        pathFoto1: foto?.path,
        pathFoto2: null,
        pathFoto3: null,
        keterangan: payload['keterangan'],
        docType: payload['doc_type'],
        hmKmAkhir: payload['hm_km_akhir'],
        liter: payload['liter'],
        hmKmAwal: payload['hm_km_awal'],
        kategoriKendaraan: payload['kategori_kendaraan'],
        jenisPengeluaran: payload['jenis_pengeluaran'],
        costCenter: payload['cost_center'],
        ratio: payload['ratio'],
        tipeUnitIo: payload['tipe_unit_io'],
        varian: payload['varian'],
        tanggalAkhir: payload['tanggal_akhir'],
        tanggalAwal: payload['tanggal_awal'],
        satuan: payload['satuan'],
        kodeUnit: payload['kode_unit']);

    final trx = TransactionPengeluaranModel(
      noBast: noDoc,
      status: 'pengisian_solar_pengeluaran',
      dateCreated: DateTime.now().toIso8601String(),
      dataPengeluaran: pengeluaranDetail,
    );

    await outstandingService.saveTransactionPengeluaran(trx);
  }

  void _handleApiError(DioException e) {
    String title = "Gagal Submit";
    String message = "Terjadi kesalahan koneksi";
    if (e.response != null) {
      int statusCode = e.response!.statusCode ?? 500;
      var data = e.response!.data;
      String detailMsg = "";
      if (data is Map && data['detail'] != null) {
        if (data['detail'] is String) {
          detailMsg = data['detail'];
        } else if (data['detail'] is List) {
          try {
            detailMsg = (data['detail'] as List).map((e) {
              if (e is Map && e.containsKey('msg')) {
                return e['msg'].toString();
              }
              return e.toString();
            }).join(', ');
          } catch (_) {
            detailMsg = data['detail'].toString();
          }
        } else {
          detailMsg = data['detail'].toString();
        }
      }
      if (statusCode == 404) {
        message = detailMsg.isNotEmpty
            ? detailMsg
            : "Internal Order (IO) tidak ditemukan di SAP/Database.";
      } else if (statusCode == 400) {
        message = detailMsg.isNotEmpty
            ? detailMsg
            : "Data request tidak valid. Cek inputan Anda.";
      } else if (statusCode == 500) {
        message = "Terjadi kesalahan pada Server (Internal Server Error).";
      } else {
        message = detailMsg.isNotEmpty ? detailMsg : "Error Code: $statusCode";
      }
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: AppColors.alertSoftRed,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(days: 365), // Dibuat lama agar tidak auto-close
      isDismissible: true, // Bisa di-swipe untuk tutup
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
      mainButton: TextButton(
        onPressed: () {
          if (Get.isSnackbarOpen) {
            Get.closeCurrentSnackbar();
          }
        },
        child: const Text(
          "Tutup",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  // Future<void> _checkAndRestoreDraft() async {
  //   if (Get.isDialogOpen == true) return;
  //   try {
  //     var draft = await _draftService.getDraft();
  //     if (draft != null && draft.isNotEmpty) {
  //       Get.dialog(
  //         DialogFlexible(
  //           logo: LottiesHelper().getLottieQuestion(),
  //           title: "Draft Ditemukan",
  //           message:
  //               "Terdapat data pengeluaran yang belum tersimpan. Apakah Anda ingin melanjutkannya?",
  //           primaryColor: AppColors.primaryOrange,
  //           secondaryColor: AppColors.secondaryOrange,
  //           secondaryButtonText: "Buang",
  //           onSecondaryPressed: () {
  //             Get.back();
  //             _clearDraft();
  //           },
  //           primaryButtonText: "Lanjutkan",
  //           onPrimaryPressed: () {
  //             Get.back();
  //             _restoreDataToUI(draft);
  //           },
  //         ),
  //         barrierDismissible: false,
  //       );
  //     }
  //   } catch (e) {
  //     print("Error reading draft: $e");
  //   }
  // }

  void _restoreDataToUI(Map<dynamic, dynamic> draft) {
    ioController.text = draft['no_io'] ?? '';
    platController.text = draft['nopol'] ?? '';
    pengisianSolarC.text = draft['solar'] ?? '';
    selectedStatusSupir.value = draft['status_supir'];
    if (draft['supir_check'] != null) {
      driverNameC.text = draft['supir_check'];
    }
    String? savedUnitName = draft['unit_io'];
    if (savedUnitName != null && _allUnitList.isNotEmpty) {
      try {
        final unit = _allUnitList.firstWhere((e) => e.namaUnit == savedUnitName,
            orElse: () => MasterIoModel(isActive: true));
        if (unit.namaUnit != null) onUnitSelected(unit);
      } catch (e) {
        print("Gagal restore unit: $e");
      }
    }
  }

  void _clearDraft() {
    _draftService.deleteDraft();
  }
}
