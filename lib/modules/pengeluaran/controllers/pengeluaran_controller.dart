import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/models/karyawan/karyawan_dbk/karyawan_dbk_list_dto.dart';
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
  final driverNameManualController = TextEditingController();

// --- Data Logic ---
  var isLoadingUnit = false.obs;
  var filteredUnitList = <MasterIoModel>[].obs;
  var isPlatReadOnly = true.obs;
  List<MasterIoModel> _allUnitList = [];

  var selectedUnit = Rxn<MasterIoModel>();

  var selectedDriver = Rxn<KaryawanDbkListDto>();
  final manualNipC = TextEditingController();
  final manualNamaC = TextEditingController();
  final manualJabatanC = TextEditingController();
  final manualUnitC = TextEditingController();

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

  final tipeUnitC = TextEditingController();
  final satuanC = TextEditingController();
  final hmKmAwalC = TextEditingController();
  final hmKmAkhirC = TextEditingController();
  final dateAwalC = TextEditingController();
  final dateAkhirC = TextEditingController();
  final varianC = TextEditingController();
  final ratioC = TextEditingController();

  final List<String> statusSupirList = ['Internal', 'Eksternal'];

  var driverList = <KaryawanDbkListDto>[].obs;
  var isLoadingDriver = false.obs;
  Timer? _debounce;
  late String _kodeUnit;

  @override
  void onInit() {
    super.onInit();

// Init Draft Service
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _kodeUnit = auth.currentKodeUnit ?? "Null";
      _draftService = DraftPengeluaranService(auth.user.username);
    }
    fetchUnitList();
  }

  @override
  void onClose() {
    kmPengisianC.dispose();
    pengisianSolarC.dispose();
    ioController.dispose();
    platController.dispose();
    driverNameManualController.dispose();

    manualNipC.dispose();
    manualNamaC.dispose();
    manualJabatanC.dispose();
    manualUnitC.dispose();

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

// --- FETCHING DATA UNIT DAN SUPIR ---
  void fetchUnitList() async {
    try {
      isLoadingUnit.value = true;
      var data = await _apiService.getMasterIoList();
      _allUnitList = data;
      filteredUnitList.assignAll(data);

      _checkAndRestoreDraft();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data unit: $e');
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
    selectedUnit.value = unit;
    ioController.text = unit.internalOrder ?? '-';

    if (unit.noPolisi != null &&
        unit.noPolisi!.isNotEmpty &&
        unit.noPolisi != '-') {
      platController.text = unit.noPolisi!;
      isPlatReadOnly.value = true;
    } else {
      platController.text = '';
      isPlatReadOnly.value = false;
    }

    await _fetchDetailFromLocal(unit.internalOrder);
    searchUnit('');
  }

  Future<void> _fetchDetailFromLocal(String? io) async {
    if (io == null) return;

    try {
      final List<BonSementaraModel> localList =
          await _bonLokalService.getMasterList();
      final detail = localList.firstWhere(
        (element) => element.internalOrder == io,
        orElse: () => BonSementaraModel(),
      );

      if (detail.internalOrder != null) {
        tipeUnit.value = detail.tipe;
        satuan.value = detail.satuan;
        hmKmAwal.value = detail.hmKmAwal?.toString();
        hmKmAkhir.value = detail.hmKmAkhir?.toString();
        dateAwal.value = detail.dateAwal;
        dateAkhir.value = detail.dateAkhir;
        varian.value = detail.tipe == 'GS'
            ? detail.dateDiff.toString()
            : detail.hmKmDiff.toStringAsFixed(0);
        ratio.value = detail.ratio;
        literAuto.value = detail.liter?.toStringAsFixed(0);

        tipeUnitC.text = detail.tipe ?? "";
        satuanC.text = detail.satuan ?? "";
        hmKmAwalC.text = detail.hmKmAwal?.toString() ?? "";
        hmKmAkhirC.text = detail.hmKmAkhir?.toString() ?? "";
        dateAwalC.text = detail.dateAwal ?? "";
        dateAkhirC.text = detail.dateAkhir ?? "";

        varianC.text = detail.tipe == 'GS'
            ? detail.dateDiff.toString()
            : detail.hmKmDiff.toStringAsFixed(0);

        ratioC.text = detail.ratio ?? "";

        pengisianSolarC.text = detail.liter?.toStringAsFixed(0) ?? "";
        kmPengisianC.text = detail.hmKmAkhir?.toString() ?? "";
      }
    } catch (e) {
      print("Error fetch local detail: $e");
    }
  }

  void onStatusSupirChanged(String? val) {
    selectedStatusSupir.value = val;
    if (val == 'Internal') {
      driverNameManualController.clear();
    } else {
      selectedDriver.value = null;
    }
  }

  void searchDriverApi(String keyword, String unit) async {
    try {
      isLoadingDriver.value = true;

      var response = await _apiService.getEmployees(
          page: 1, pageSize: 25, search: keyword, kodeUnit: _kodeUnit);

      if (response.data != null) {
        driverList.assignAll(response.data!);
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      isLoadingDriver.value = false;
    }
  }

  void onSearchDriverChanged(String val) {
    if (val.isEmpty) {
      driverList.clear();
      return;
    }

    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchDriverApi(val, _kodeUnit);
    });
  }

  void pickDriverFromApi(KaryawanDbkListDto data) {
    selectedDriver.value = data;
// Reset manual input controllers
    manualNipC.clear();
    manualNamaC.clear();
    manualJabatanC.clear();
  }

  void setManualInternalDriver() {
    String nip = manualNipC.text.trim();
    String nama = manualNamaC.text.trim();
    String unit = manualUnitC.text.trim();
    String jabatan = manualJabatanC.text.trim();

    if (nip.isEmpty || nama.isEmpty || unit.isEmpty) {
      Get.snackbar("Validasi Gagal", "NIP, Nama, dan Kode Unit wajib diisi",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (nip.length < 13 || nip.length > 14) {
      Get.snackbar("Validasi NIP", "NIP harus terdiri dari 13 - 14 digit",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (unit.length != 4) {
      Get.snackbar("Validasi Unit", "Kode Unit harus terdiri dari 4 karakter",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    if (RegExp(r'[0-9]').hasMatch(nama)) {
      Get.snackbar("Validasi Nama", "Nama tidak boleh mengandung angka",
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return;
    }

    final manualData = KaryawanDbkListDto(
      nama: nama,
      nip: nip,
      jabatan: jabatan.isEmpty ? "Supir" : jabatan,
      unit: unit.toUpperCase(),
      status: "Aktif",
    );

    selectedDriver.value = manualData;
    Get.back(); // Tutup Dialog
    if (Get.isBottomSheetOpen ?? false) Get.back();
  }

// --- VALIDASI DAN PROSES ---
  void validateAndProceed() {
    if (_validateForm()) {
      _processSubmitToApi();
    }
  }

  bool _validateForm() {
    bool isDriverValid = false;
    if (selectedStatusSupir.value == 'Internal') {
      isDriverValid = selectedDriver.value != null;
    } else if (selectedStatusSupir.value == 'Eksternal') {
      isDriverValid = driverNameManualController.text.isNotEmpty;
    }

    if (selectedUnit.value == null ||
        selectedStatusSupir.value == null ||
        !isDriverValid ||
        kmPengisianC.text.isEmpty ||
        pengisianSolarC.text.isEmpty ||
        platController.text.isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Harap lengkapi semua form inputan!',
          backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white);
      return false;
    }
    return true;
  }

  void _processSubmitToApi() {
    Get.dialog(
      DialogFlexible(
        logo: LottiesHelper().getLottieConfirmation(),
        title: "Konfirmasi Submit",
        message:
            "Apakah data pengeluaran solar sudah sesuai? Data tidak dapat diubah setelah disubmit.",
        primaryColor: AppColors.primaryOrange,
        secondaryColor: AppColors.secondaryOrange,
        secondaryButtonText: "Periksa Lagi",
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
      String cleanKm = TextConvertHelper().cleanNumber(kmPengisianC.text);
      String cleanSolar = TextConvertHelper().cleanNumber(pengisianSolarC.text);
      String namaSupirFinal = selectedStatusSupir.value == 'Internal'
          ? (selectedDriver.value?.nama ?? "")
          : driverNameManualController.text;

      Map<String, dynamic> payload = {
        "no_io": ioController.text,
        "unit_io": selectedUnit.value?.namaUnit ?? "-",
        "nopol_check": platController.text.toUpperCase(),
        "status_supir": selectedStatusSupir.value,
        "supir_check": namaSupirFinal.toUpperCase(),
        "km_pengisian": double.tryParse(cleanKm) ?? 0,
        "jumlah_pengisian_solar": double.tryParse(cleanSolar) ?? 0,

        "keterangan": "",
        "doc_type": "FOT",
        "hm_km_akhir": double.tryParse(hmKmAkhirC.text) ?? 0,
        "liter": double.tryParse(cleanSolar) ?? 0,
        "hm_km_awal": double.tryParse(hmKmAwalC.text) ?? 0,
        "cost_center": "",
        "ratio": double.tryParse(ratioC.text) ?? 0,
        "tipe_unit_io": tipeUnitC.text,
        "varian": double.tryParse(varianC.text) ?? 0,
        "tanggal_akhir": dateAkhir.value ?? "",
        "tanggal_awal": dateAwal.value ?? "",
        "satuan": satuanC.text,
      };

      List<File?> photos = [null, null, null]; // Foto dikosongkan

      final response = await _apiService.createInboundFot(
        payloadMap: payload,
        photos: photos,
      );

      String noDoc = response['no_doc'] ?? "-";
      String message = response['message'] ?? "Berhasil disubmit";

      await _saveToOutstanding(noDoc, payload);
      await _draftService.deleteDraft();

      Get.back(); // Tutup Loading

      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieSuccess(),
          title: "Berhasil",
          message: "$message\nNo Dokumen: $noDoc",
          primaryColor: AppColors.primaryOrange,
          primaryButtonText: "Lanjut Pengisian",
          onPrimaryPressed: () {
            Get.back();

            // Navigasi ke halaman Pengisian Soalr
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
              },
            );
          },
        ),
        barrierDismissible: false,
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
      pathFoto1: null,
      pathFoto2: null,
      pathFoto3: null,
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
            message:
                "Terdapat data pengeluaran yang belum tersimpan. Apakah Anda ingin melanjutkannya?",
            primaryColor: AppColors.primaryOrange,
            secondaryColor: AppColors.secondaryOrange,
            secondaryButtonText: "Buang",
            onSecondaryPressed: () {
              Get.back();
              _clearDraft();
            },
            primaryButtonText: "Lanjutkan",
            onPrimaryPressed: () {
              Get.back();
              _restoreDataToUI(draft);
            },
          ),
          barrierDismissible: false,
        );
      }
    } catch (e) {
      print("Error reading draft: $e");
    }
  }

  void _restoreDataToUI(Map<dynamic, dynamic> draft) {
    ioController.text = draft['no_io'] ?? '';
    platController.text = draft['nopol'] ?? '';
    kmPengisianC.text = draft['km'] ?? '';
    pengisianSolarC.text = draft['solar'] ?? '';
    selectedStatusSupir.value = draft['status_supir'];

    if (draft['supir_check'] != null &&
        selectedStatusSupir.value == 'Internal') {
      try {
        final driverData = KaryawanDbkListDto.fromJson(draft['driver_data']);
        selectedDriver.value = driverData;
      } catch (e) {
        print("Error restoring driver data: $e");
      }
    } else if (draft['supir_check'] != null &&
        selectedStatusSupir.value == 'Eksternal') {
      driverNameManualController.text = draft['supir_check'];
    }

    String? savedUnitName = draft['unit_io'];
    if (savedUnitName != null && _allUnitList.isNotEmpty) {
      try {
        final unit = _allUnitList.firstWhere(
          (element) => element.namaUnit == savedUnitName,
          orElse: () => MasterIoModel(),
        );
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
