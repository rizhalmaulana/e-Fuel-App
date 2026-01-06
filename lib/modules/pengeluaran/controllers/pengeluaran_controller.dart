import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/transactions/pengeluaran/transaction_pengeluaran_model.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';
import '../../../datas/models/master_io/master_io_model.dart';
import '../../../datas/models/pengeluaran/pengeluaran_model.dart';
import '../../../helpers/lotties_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/pengeluaran/services/pengeluaran_api_service.dart';
import '../services/bon_sementara_local_service.dart';
import '../services/draft_pengeluaran_service.dart';

class PengeluaranController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final PengeluaranApiService _apiService = PengeluaranApiService();
  late DraftPengeluaranService _draftService;
  final BonSementaraLocalService _bonLokalService = BonSementaraLocalService();

  // --- Form Controllers ---
  final kmPengisianC = TextEditingController();
  final pengisianSolarC = TextEditingController();
  final ioController = TextEditingController();
  final platController = TextEditingController();
  final driverNameC = TextEditingController();
  final keteranganC = TextEditingController();

  // --- Data Logic ---
  final List<String> jenisBonList = ['Bon Sementara', 'BPB'];
  final List<String> jenisKategoriList = ['Internal', 'Tamu'];
  final List<String> statusSupirList = ['Internal', 'Eksternal'];

  var isLoadingUnit = false.obs;
  var filteredUnitList = <MasterIoModel>[].obs;
  List<MasterIoModel> _allUnitList = [];
  var selectedUnit = Rxn<MasterIoModel>();

  var selectedJenisBon = Rxn<String>();
  var selectedKategoriKendaraan = Rxn<String>();
  var selectedStatusSupir = Rxn<String>();

  final tipeUnit = Rxn<String>();
  final satuan = Rxn<String>();
  final hmKmAwal = Rxn<String>();
  final hmKmAkhir = Rxn<String>();
  final dateAwal = Rxn<String>();
  final dateAkhir = Rxn<String>();
  final varian = Rxn<String>();
  final ratio = Rxn<String>();
  final literAuto = Rxn<String>();

  // State ReadOnly
  var isPlatReadOnly = true.obs;
  var isHmKmAwalReadOnly = true.obs;
  var isHmKmAkhirReadOnly = true.obs;
  var isDateAwalReadOnly = true.obs;
  var isDateAkhirReadOnly = true.obs;
  var isVarianReadOnly = true.obs;
  var isRatioReadOnly = true.obs;
  var isLiterReadOnly = true.obs;
  var isIoReadOnly = true.obs;

  final tipeUnitC = TextEditingController();
  final satuanC = TextEditingController();
  final hmKmAwalC = TextEditingController();
  final hmKmAkhirC = TextEditingController();
  final dateAwalC = TextEditingController();
  final dateAkhirC = TextEditingController();
  final varianC = TextEditingController();
  final ratioC = TextEditingController();

  var isLoadingDriver = false.obs;
  late String _kodeUnit;

  bool get isTipeKendaraan {
      final tipe = tipeUnit.value?.toUpperCase() ?? '';
      return tipe == 'KD' || tipe == 'AB' || tipe == 'AD';
  }

  bool get isTipeGenset => (tipeUnit.value?.toUpperCase() ?? '') == 'GS';
  bool get isBpbMode => selectedJenisBon.value == 'BPB';
  bool get isTamu => selectedKategoriKendaraan.value == 'Tamu';

  @override
  void onInit() {
    super.onInit();
    selectedJenisBon.value = jenisBonList.first;
    selectedKategoriKendaraan.value = jenisKategoriList.first;
    selectedStatusSupir.value = statusSupirList.first;

    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _kodeUnit = auth.currentKodeUnit ?? "Null";
      _draftService = DraftPengeluaranService(auth.user.username);
    }

    _setupInternalMode();
    fetchUnitList();

    hmKmAkhirC.addListener(_calculateAutomatedValues);
    ratioC.addListener(_calculateAutomatedValues);
    dateAwalC.addListener(_calculateAutomatedValues);
    dateAkhirC.addListener(_calculateAutomatedValues);
  }

  @override
  void onClose() {
    hmKmAkhirC.removeListener(_calculateAutomatedValues);
    ratioC.removeListener(_calculateAutomatedValues);
    dateAwalC.removeListener(_calculateAutomatedValues);
    dateAkhirC.removeListener(_calculateAutomatedValues);

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
    ratioC.dispose();
    super.onClose();
  }

  void switchKategoriKendaraan(String? val) {
    if (val == null) return;
    selectedKategoriKendaraan.value = val;

    _resetToManualInput();
    ioController.clear();
    platController.clear();
    isPlatReadOnly.value = false;

    if (val == 'Tamu') {
      _setupTamuMode();
    } else {
      _setupInternalMode();
      searchUnit('');
    }
    update();
  }

  void _setupInternalMode() {
    selectedUnit.value = null;

    ratioC.text = "0";
    isRatioReadOnly.value = false;
    pengisianSolarC.text = "0";
    isLiterReadOnly.value = false;
    isIoReadOnly.value = true;
  }

  void _setupTamuMode() {
    final tamuUnit = MasterIoModel(
        namaUnit: "TAMU",
        description: "External Guest",
        internalOrder: "-",
        noPolisi: "-"
    );
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

    isHmKmAwalReadOnly.value = true;
    isHmKmAkhirReadOnly.value = true;
    isVarianReadOnly.value = true;
    isRatioReadOnly.value = true;

    pengisianSolarC.text = "0";
    isLiterReadOnly.value = true;
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

  void _calculateAutomatedValues() {
    // 1. Cek jika Tamu, skip kalkulasi
    if (isTamu) return;

    // 2. Cek jika Genset, skip ke logic khusus genset
    if (isTipeGenset) {
      _calculateGensetDiff();
      return;
    }

    // 3. Ambil Tipe Unit (KD/AB)
    String tipe = tipeUnit.value?.trim().toUpperCase() ?? "";

    // 4. Ambil Nilai Meteran (Gunakan Helper untuk cleaning format ribuan/koma)
    double awal = double.tryParse(TextConvertHelper().cleanNumber(hmKmAwalC.text)) ?? 0;
    double akhir = double.tryParse(TextConvertHelper().cleanNumber(hmKmAkhirC.text)) ?? 0;

    // 5. Hitung Selisih (Varian)
    double diff = (akhir - awal) > 0 ? (akhir - awal) : 0;

    // Update Field Varian di UI
    if (akhir > 0) {
      varianC.text = TextConvertHelper().formatNumber(diff);
    }

    // 6. Hitung Estimasi Liter (Logic Baru)
    double ratioVal = double.tryParse(TextConvertHelper().cleanNumber(ratioC.text)) ?? 0;

    if (diff > 0 && ratioVal > 0) {
      double estimasiLiter = 0;

      if (tipe == 'KD' || tipe == 'AD') {
        // Rumus KD: (KM Akhir - KM Awal) / Ratio
        estimasiLiter = diff / ratioVal;
      } else if (tipe == 'AB') {
        // Rumus AB: (HM Akhir - HM Awal) * Ratio
        estimasiLiter = diff * ratioVal;
      }

      // Update Field Estimasi Liter di UI
      // Format angka agar rapi (misal: 100,5 -> 100,50 atau sesuai format helper)
      pengisianSolarC.text = TextConvertHelper().formatNumber(estimasiLiter);
    }
  }

  String _convertToDisplayDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "";
    try {
      if (dateStr.contains('/')) return dateStr;
      DateTime parsed = DateFormat('yyyy-MM-dd').parse(dateStr);
      return DateFormat('dd/MM/yyyy').format(parsed);
    } catch (e) {
      return dateStr;
    }
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
      var data = await _apiService.getMasterIoList();

      _allUnitList = data;
      filteredUnitList.assignAll(data);

      _checkAndRestoreDraft();
    } on DioException catch (e) {
      // Handling Error Koneksi Spesifik Dio
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {

        // Tampilkan Pesan Offline
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
        Get.snackbar(
            'Gagal Memuat Data',
            'Terjadi kesalahan server (${e.response?.statusCode ?? "Unknown"}).',
            backgroundColor: AppColors.alertSoftRed,
            colorText: Colors.white
        );
      }
    } catch (e) {
      // Handling Error Umum Lainnya
      Get.snackbar(
          'Error',
          'Terjadi kesalahan aplikasi: $e',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white
      );
    } finally {
      isLoadingUnit.value = false;
    }
  }

  void searchUnit(String keyword) {
    if (keyword.isEmpty) {
      filteredUnitList.assignAll(_allUnitList);
    } else {
      var result = _allUnitList.where((unit) {
        var shortName = (unit.namaUnit ?? '').toLowerCase();
        var longName = (unit.description ?? '').toLowerCase();
        var io = (unit.internalOrder ?? '').toLowerCase();
        var plat = (unit.noPolisi ?? '').toLowerCase();
        var input = keyword.toLowerCase();
        return shortName.contains(input) ||
            longName.contains(input) ||
            io.contains(input) ||
            plat.contains(input);
      }).toList();
      filteredUnitList.assignAll(result);
    }
  }

  void onUnitSelected(MasterIoModel unit) async {
    if (isTamu) return;

    tipeUnit.value = null;

    selectedUnit.value = unit;
    ioController.text = unit.internalOrder ?? '-';

    _resetToManualInput();

    ratioC.text = "0";
    isRatioReadOnly.value = false;
    pengisianSolarC.text = "0";
    isLiterReadOnly.value = false;
    isIoReadOnly.value = true;

    String plat = (unit.noPolisi ?? "").trim();
    if (plat.isNotEmpty && plat != "-") {
      platController.text = plat;
      isPlatReadOnly.value = true;
    } else {
      platController.text = '';
      isPlatReadOnly.value = false;
    }

    await _fetchDetailFromLocal(unit.internalOrder);

    if (tipeUnit.value == null) {
      _determineTipeByNamaUnit(unit);
    }
    searchUnit('');
  }

  void _determineTipeByNamaUnit(MasterIoModel unit) {
    String nama = (unit.namaUnit ?? "").toUpperCase();
    String deskripsi = (unit.description ?? "").toUpperCase();
    String gabungan = "$nama $deskripsi";

    String hasilTipe = "KD";
    String hasilSatuan = "KM";

    if (gabungan.contains("DT") || gabungan.contains("BUS") || gabungan.contains("LV")) {
      hasilTipe = "KD"; hasilSatuan = "KM";
    } else if (gabungan.contains("EXCA") || gabungan.contains("DOZER") || gabungan.contains("PC")) {
      hasilTipe = "AB"; hasilSatuan = "HM";
    } else if (gabungan.contains("GENSET") || gabungan.contains("GS")) {
      hasilTipe = "GS"; hasilSatuan = "Hour";
    }

    tipeUnit.value = hasilTipe;
    satuan.value = hasilSatuan;
    tipeUnitC.text = hasilTipe;
    satuanC.text = hasilSatuan;
  }

  Future<void> _fetchDetailFromLocal(String? io) async {
    if (io == null) return;
    try {
      final List<BonSementaraModel> localList = await _bonLokalService.getMasterList();
      final detail = localList.firstWhere((e) => e.internalOrder == io, orElse: () => BonSementaraModel());

      if (detail.internalOrder != null) {
        tipeUnit.value = detail.tipe;
        satuan.value = detail.satuan;

        tipeUnitC.text = detail.tipe ?? "";
        satuanC.text = detail.satuan ?? "";

        if (detail.hmKmAwal != null && detail.hmKmAwal != 0) {
          hmKmAwalC.text = detail.hmKmAwal.toString();
          isHmKmAwalReadOnly.value = true;
        } else {
          isHmKmAwalReadOnly.value = false;
        }

        if (detail.hmKmAkhir != null && detail.hmKmAkhir != 0) {
          hmKmAkhirC.text = detail.hmKmAkhir.toString();
          isHmKmAkhirReadOnly.value = true;
        } else {
          isHmKmAkhirReadOnly.value = false;
        }

        if (detail.ratio != null && detail.ratio != "0") {
          ratioC.text = detail.ratio!;
          isRatioReadOnly.value = false;
        }

        _calculateAutomatedValues();
      }
    } catch (e) {
      print("Error local detail: $e");
    }
  }

  void _resetToManualInput() {
    hmKmAwalC.clear(); isHmKmAwalReadOnly.value = false;
    hmKmAkhirC.clear(); isHmKmAkhirReadOnly.value = false;
    dateAwalC.clear(); isDateAwalReadOnly.value = false;
    dateAkhirC.clear(); isDateAkhirReadOnly.value = false;
    varianC.clear(); isVarianReadOnly.value = false;
    ratioC.clear(); isRatioReadOnly.value = false;
    pengisianSolarC.clear(); isLiterReadOnly.value = false;

    if (selectedUnit.value == null) {
      tipeUnit.value = null;
    }
  }

  void onStatusSupirChanged(String? val) { selectedStatusSupir.value = val; }
  void validateAndProceed() { if (_validateForm()) _processSubmitToApi(); }

  bool _validateForm() {
    // 1. Cek Kelengkapan Dasar
    if (selectedJenisBon.value == null ||
        selectedUnit.value == null ||
        selectedStatusSupir.value == null ||
        driverNameC.text.isEmpty ||
        pengisianSolarC.text.isEmpty ||
        platController.text.isEmpty) {
      Get.snackbar(
          'Data Belum Lengkap',
          'Harap lengkapi semua form inputan!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16)
      );
      return false;
    }

    // 2. Validasi Khusus Nama Supir (Minimal 3 Karakter)
    if (driverNameC.text.trim().length < 3) {
      Get.snackbar(
          'Validasi Supir',
          'Nama Supir/Operator minimal 3 karakter!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16)
      );
      return false;
    }

    // 3. Validasi Logic Angka (Opsional tambahan biar aman)
    double inputSolar = double.tryParse(TextConvertHelper().cleanNumber(pengisianSolarC.text)) ?? 0;
    if (inputSolar <= 0) {
      Get.snackbar('Validasi Solar', 'Jumlah pengisian solar harus lebih dari 0', backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
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
          Get.back();
          _submitDataToApi();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _submitDataToApi() async {
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
      String cleanKm = TextConvertHelper().cleanNumber(hmKmAkhirC.text);
      String cleanSolar = TextConvertHelper().cleanNumber(pengisianSolarC.text);
      String namaSupirFinal = driverNameC.text;
      String docType = (selectedJenisBon.value == 'BPB') ? "BPB" : "FOT";
      // String docType = "FOT";

      Map<String, dynamic> payload = {
        "no_io": ioController.text,
        "unit_io": selectedUnit.value?.namaUnit ?? "-",
        "nopol_check": platController.text.toUpperCase(),
        "status_supir": selectedStatusSupir.value ?? "Internal",
        "supir_check": namaSupirFinal.toUpperCase(),
        "km_pengisian": double.tryParse(cleanKm) ?? 0,
        "jumlah_pengisian_solar": double.tryParse(cleanSolar) ?? 0,
        "doc_type": docType,
        "hm_km_awal": double.tryParse(hmKmAwalC.text) ?? 0,
        "hm_km_akhir": double.tryParse(hmKmAkhirC.text) ?? 0,
        "tanggal_awal": (dateAwal.value == null || dateAwal.value == "") ? null : dateAwal.value,
        "tanggal_akhir": (dateAkhir.value == null || dateAkhir.value == "") ? null : dateAkhir.value,
        "tipe_unit_io": tipeUnitC.text,
        "liter": double.tryParse(cleanSolar) ?? 0,
        "ratio": double.tryParse(ratioC.text) ?? 0,
        "varian": double.tryParse(varianC.text) ?? 0,
        "satuan": satuanC.text,
        "cost_center": "-",
        "keterangan": keteranganC.text.isEmpty ? "-" : keteranganC.text,
      };

      List<File?> photos = [null, null, null];
      final response = await _apiService.createInboundFot(payloadMap: payload, photos: photos);

      String noDoc = response['no_doc'] ?? "-";
      String message = response['message'] ?? "Berhasil disubmit";

      await _saveToOutstanding(noDoc, payload);
      await _draftService.deleteDraft();

      Get.back();

      Get.offNamed(
        Routes.PENGISIAN_SOLAR_PENGELUARAN,
        arguments: {
          'noDoc': noDoc,
          'noIO': payload['no_io'],
          'unitIO': selectedUnit.value?.namaUnit,
          'noPolisi': payload['nopol_check'],
          'tanggal': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          'nama_supir': namaSupirFinal,
          'km_pengisian': cleanKm,
          'jumlah_pengisian_solar': cleanSolar,
          'status': 'pengisian_solar_pengeluaran',
          'tipe_unit': tipeUnitC.text,
          'satuan': satuanC.text,
          'hm_km_awal': hmKmAwalC.text,
          'hm_km_akhir': hmKmAkhirC.text,
          'tanggal_awal': dateAwal.value,
          'tanggal_akhir': dateAkhir.value,
          'varian': varianC.text,
          'ratio': ratioC.text,
          'keterangan': keteranganC.text,
          'doc_type': docType,
        },
      );
    } on DioException catch (e) {
      Get.back();
      _handleApiError(e);
    } catch (e) {
      Get.back();
      Get.snackbar("Error", "Terjadi kesalahan aplikasi: $e",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
    }
  }

  Future<void> _saveToOutstanding(
      String noDoc, Map<String, dynamic> payload) async {
    final auth = _loginService.getCurrentAuth();
    if (auth == null) return;

    final outstandingService = OutstandingService(auth.user.username);
    final pengeluaranDetail = PengeluaranModel(
      noDoc: noDoc,
      noIo: payload['no_io'],
      nopolCheck: payload['nopol_check'],
      statusSupir: payload['status_supir'],
      supirCheck: payload['supir_check'],
      kmPengisian: payload['km_pengisian'],
      jumlahPengisianSolar: payload['jumlah_pengisian_solar'],
      unitIO: payload['unit_io'],
      userName: auth.user.username,
      dateOutbound: DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      pathFoto1: null, pathFoto2: null, pathFoto3: null,
      keterangan: payload['keterangan'],
      docType: payload['doc_type'],
      hmKmAkhi: payload['hm_km_akhir'],
      liter: payload['liter'],
      hmKmAwak: payload['hm_km_awal'],
      costCenter: payload['cost_center'],
      ratio: payload['ratio'],
      tipeUnitIo: payload['tipe_unit_io'],
      varian: payload['varian'],
      tanggalAkhir: payload['tanggal_akhir'],
      tanggalAwal: payload['tanggal_awal'],
      satuan: payload['satuan'],
    );

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
        detailMsg = data['detail'];
      }
      if (statusCode == 404) {
        message = detailMsg.isNotEmpty ? detailMsg : "Internal Order (IO) tidak ditemukan di SAP/Database.";
      } else if (statusCode == 400) {
        message = detailMsg.isNotEmpty ? detailMsg : "Data request tidak valid. Cek inputan Anda.";
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
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  // --- DRAFT MANAGEMENT ---
  Future<void> _checkAndRestoreDraft() async {
    if (Get.isDialogOpen == true) return;
    try {
      var draft = await _draftService.getDraft();
      if (draft != null && draft.isNotEmpty) {
        Get.dialog(
          DialogFlexible(
            logo: LottiesHelper().getLottieQuestion(),
            title: "Draft Ditemukan",
            message: "Terdapat data pengeluaran yang belum tersimpan. Apakah Anda ingin melanjutkannya?",
            primaryColor: AppColors.primaryOrange,
            secondaryColor: AppColors.secondaryOrange,
            secondaryButtonText: "Buang",
            onSecondaryPressed: () { Get.back(); _clearDraft(); },
            primaryButtonText: "Lanjutkan",
            onPrimaryPressed: () { Get.back(); _restoreDataToUI(draft); },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) { print("Error reading draft: $e"); }
  }

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
        final unit = _allUnitList.firstWhere((e) => e.namaUnit == savedUnitName, orElse: () => MasterIoModel());
        if (unit.namaUnit != null) onUnitSelected(unit);
      } catch (e) { print("Gagal restore unit: $e"); }
    }
  }

  void _clearDraft() { _draftService.deleteDraft(); }
}
