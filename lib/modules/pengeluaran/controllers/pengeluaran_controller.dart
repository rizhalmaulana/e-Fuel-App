import 'dart:async';
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

  // --- Data Logic ---
  final List<String> jenisBonList = ['Bon Sementara', 'BPB'];
  final jenisKategoriList = ['INTERNAL LKE', 'INTERNAL NON LKE', 'VENDOR', 'TAMU'].obs;
  final List<String> statusSupirList = ['Internal', 'Eksternal'];

  var isLoadingUnit = false.obs;
  var filteredUnitList = <MasterIoModel>[].obs;
  List<MasterIoModel> _allUnitList = [];
  var selectedUnit = Rxn<MasterIoModel>();

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
  var isTakingPhoto = false.obs;

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
  bool get isTamu => selectedKategoriKendaraan.value == 'TAMU' || selectedKategoriKendaraan.value == 'VENDOR';

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
    fetchUnitsPerArea();

    // Listener yang sudah ada
    hmKmAwalC.addListener(_calculateAutomatedValues);
    hmKmAkhirC.addListener(_calculateAutomatedValues);
    ratioInput.addListener(_calculateAutomatedValues);
    dateAwalC.addListener(_calculateAutomatedValues);
    dateAkhirC.addListener(_calculateAutomatedValues);
  }

  @override
  void onClose() {
    hmKmAwalC.removeListener(_calculateAutomatedValues);
    hmKmAkhirC.removeListener(_calculateAutomatedValues);
    ratioInput.removeListener(_calculateAutomatedValues);
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
    ratioInput.dispose();
    kodeUnitController.dispose();
    super.onClose();
  }

  void switchKategoriKendaraan(String? val) {
    if (val == null) return;
    selectedKategoriKendaraan.value = val;

    _resetToManualInput();
    ioController.clear();
    platController.clear();
    isPlatReadOnly.value = false;

    if (val == 'TAMU' || val == 'VENDOR') {
      _setupTamuMode(val);
      selectedKodeKebunPabrik.value = null; // or "-"
      selectedKodeUnitKebunPabrik.value = null;
    } else {
      _setupInternalMode();
      searchUnit('');
      if (!val.contains('NON')) {
        selectedKodeKebunPabrik.value = userTitleUnit.value;
        selectedKodeUnitKebunPabrik.value = userKodeUnit.value;
      } else {
        selectedKodeKebunPabrik.value = null;
        selectedKodeUnitKebunPabrik.value = null;
      }
    }
    update();
  }

  void _setupInternalMode() {
    selectedUnit.value = null;

    ratioC.text = "0";     // Default 0
    ratioInput.text = "0"; // UI 0
    isRatioReadOnly.value = false;

    pengisianSolarC.text = "0";
    isLiterReadOnly.value = false;
    isIoReadOnly.value = true;
  }

  void _setupTamuMode(String kategori) {

    final tamuUnit = MasterIoModel(
        namaUnit: kategori,
        description: "External $kategori",
        internalOrder: "-",
        noPolisi: "-");
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
    ratioInput.text = "0"; // UI

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

  void _calculateAutomatedValues() {
    // Cek jika Tamu, skip kalkulasi
    if (isTamu) return;

    // Cek jika Genset, skip ke logic khusus genset
    if (isTipeGenset) {
      _calculateGensetDiff();
      return;
    }

    // Ambil Tipe Unit (KD/AB)
    String tipe = tipeUnit.value?.trim().toUpperCase() ?? "";

    // Ambil Nilai Meteran (Gunakan Helper)
    double awal = TextConvertHelper().parseToDouble(hmKmAwalC.text);
    double akhir = TextConvertHelper().parseToDouble(hmKmAkhirC.text);
    double ratioVal = TextConvertHelper().parseToDouble(ratioInput.text);

    // Hitung Selisih (Varian)
    double diff = (akhir - awal) > 0 ? (akhir - awal) : 0;

    // Cek dulu apakah nilai di text field beda dengan hasil hitungan biar cursor ga lompat
    String newVarianStr = diff % 1 == 0 ? diff.toInt().toString() : diff.toString();
    if (varianC.text != newVarianStr) {
      varianC.text = newVarianStr;
    }

    // Hitung Estimasi Liter
    double estimasiLiter = 0;

    // Logic Perhitungan
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

    // Menggunakan .round() untuk membulatkan ke integer terdekat (cth: 5.6 -> 6, 5.2 -> 5)
    String newLiterStr = estimasiLiter.round().toString();

    // Cek agar kursor tidak lompat/reset saat user mengetik
    if (pengisianSolarC.text != newLiterStr) {
      // Hanya update jika user TIDAK sedang mengetik desimal gantung (misal "5.")
      if (!pengisianSolarC.text.endsWith('.')) {
        pengisianSolarC.text = newLiterStr;
      }
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

        String defaultTitle = "LKE";
        String defaultUnit = "E031";

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

        listTitleUnitPerArea.assignAll(titles);
        listKodeUnitPerArea.assignAll(units);

        userTitleUnit.value = defaultTitle;
        userKodeUnit.value = defaultUnit;

        // --- UPDATE DYNAMIC CATEGORIES ---
        jenisKategoriList.assignAll([
          'INTERNAL $defaultTitle',
          'INTERNAL NON $defaultTitle',
          'VENDOR',
          'TAMU'
        ]);

        // Sesuaikan kembali kategori yang dipilih agar label baru teraplikasikan
        if (selectedKategoriKendaraan.value!.startsWith('INTERNAL')) {
           if (selectedKategoriKendaraan.value!.contains('NON')) {
               selectedKategoriKendaraan.value = 'INTERNAL NON $defaultTitle';
               selectedKodeKebunPabrik.value = null;
           } else {
               selectedKategoriKendaraan.value = 'INTERNAL $defaultTitle';
               selectedKodeKebunPabrik.value = defaultTitle;
           }
        }
      } catch (e) {
        print("Error fetchUnitsPerArea: $e");
      } finally {
        isLoadingUnitsPerArea.value = false;
      }
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
    if (!await ConnectivityHelper.validateNetwork()) return;
    if (isTamu) return;

    tipeUnit.value = null;
    selectedUnit.value = unit;
    ioController.text = unit.internalOrder ?? '-';

    _resetToManualInput();

    ratioInput.text = "0";
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
    } else if (gabungan.contains("GENSET") || gabungan.contains("GS")) {
      hasilTipe = "GS";
      hasilSatuan = "Hour";
    }

    tipeUnit.value = hasilTipe;
    satuan.value = hasilSatuan;
    tipeUnitC.text = hasilTipe;
    satuanC.text = hasilSatuan;
  }

  Future<void> _fetchDetailFromLocal(String? io) async {
    if (io == null) return;

    final detail = _homeService.getUnitData(io);

    if (detail != null) {
      tipeUnit.value = detail.tipe;
      satuan.value = detail.satuan;
      tipeUnitC.text = detail.tipe ?? "";
      satuanC.text = detail.satuan ?? "";

      if (detail.hmKmAwal != null) {
        double val = double.tryParse(detail.hmKmAwal.toString()) ?? 0.0;

        // Cek apakah bulat (misal 12000.0) -> ubah jadi 12000
        hmKmAwalC.text = (val % 1 == 0) ? val.toInt().toString() : val.toString();
      }

      if (detail.ratio != null) {
        // Konversi String ke Double dulu
        double ratioVal = double.tryParse(detail.ratio.toString()) ?? 0.0;

        // Cek apakah komanya .0 (bulat)
        String ratioClean = (ratioVal % 1 == 0) ? ratioVal.toInt().toString() : ratioVal.toString();

        ratioC.text = ratioClean;
        ratioInput.text = ratioClean;
      } else {
        ratioC.text = "0";
        ratioInput.text = "0";
      }

      _calculateAutomatedValues();
    }
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
    ratioInput.text = "0";
    isRatioReadOnly.value = false;

    pengisianSolarC.clear();
    isLiterReadOnly.value = false;

    if (selectedUnit.value == null) {
      tipeUnit.value = null;
    }
  }

  void onStatusSupirChanged(String? val) {
    selectedStatusSupir.value = val;
  }

  void validateAndProceed() {
    if (_validateForm()) _processSubmitToApi();
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
      if (lastIndex == -1) return file; // Jika ekstensi tidak dikenali, kembalikan aslinya

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

      // Opsional: Hapus file original untuk menghemat storage
      await file.delete();
      return result != null ? File(result.path) : null;
    } catch (e) {
      return file; // Jika gagal compress, gunakan file asli
    }
  }

  // Fungsi untuk membatalkan/menghapus foto jika user ingin foto ulang
  void hapusFotoOdometer() {
    fotoOdometer.value = null;
  }

  bool _validateForm() {
    if (selectedJenisBon.value == null ||
        selectedUnit.value == null ||
        selectedStatusSupir.value == null ||
        driverNameC.text.isEmpty ||
        pengisianSolarC.text.isEmpty ||
        platController.text.isEmpty) {
      Get.snackbar('Data Belum Lengkap', 'Harap lengkapi semua form inputan!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (fotoOdometer.value == null) {
      Get.snackbar('Data Belum Lengkap', 'Foto Odometer wajib dilampirkan!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
      return false;
    }

    if (selectedKategoriKendaraan.value!.contains('INTERNAL NON') && selectedKodeKebunPabrik.value == null) {
      Get.snackbar('Data Belum Lengkap', 'Pilih Kode Kebun/Pabrik terlebih dahulu!',
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
    if (inputSolar <= 0) {
      Get.snackbar(
          'Validasi Solar', 'Jumlah pengisian solar harus lebih dari 0',
          backgroundColor: AppColors.alertSoftRed, colorText: Colors.white);
      return false;
    }

    // Validasi untuk Tipe Kendaraan (KD/AB) - Kecuali Tamu
    if (isTipeKendaraan && !isTamu) {
      double awal = double.tryParse(TextConvertHelper().cleanNumber(hmKmAwalC.text)) ?? 0;
      double akhir = double.tryParse(TextConvertHelper().cleanNumber(hmKmAkhirC.text)) ?? 0;

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
    if (!isTipeKendaraan && !isTamu) { // Asumsi GS atau lainnya pakai Tanggal
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
      Get.snackbar('Data Belum Lengkap', 'Cost Center wajib diisi untuk kategori Tamu!',
          backgroundColor: AppColors.alertSoftRed,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16));
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
      bool isOnline = await ConnectivityHelper.isConnected();
      String inputTypeStr = isOnline ? "A" : "M";

      String cleanKm = TextConvertHelper().cleanNumber(hmKmAkhirC.text);
      String rawSolar = pengisianSolarC.text;
      double solarDouble = TextConvertHelper().parseToDouble(rawSolar);

      String namaSupirFinal = driverNameC.text;
      // String docType = (selectedJenisBon.value == 'BPB') ? "BPB" : "Bon Sementara";
      double ratioDefault = TextConvertHelper().parseToDouble(ratioC.text);
      double ratioUser = TextConvertHelper().parseToDouble(ratioInput.text);

      Map<String, dynamic> payloadRequestAPI = {
        "supir_check": namaSupirFinal.toUpperCase(),
        "keterangan": keteranganC.text.isEmpty ? "-" : keteranganC.text,
        "km_pengisian": double.tryParse(cleanKm) ?? 0,
        "doc_type": "FOT",
        "hm_km_akhir": double.tryParse(hmKmAkhirC.text) ?? 0,
        "no_io": isTamu ? "-" : ioController.text,
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
            ? null
            : dateAkhir.value,
        "kategori_kendaraan": selectedKategoriKendaraan.value,
        "tanggal_awal": (dateAwal.value == null || dateAwal.value == "")
            ? null
            : dateAwal.value,
        "nopol_check": platController.text.toUpperCase(),
        "jenis_pengeluaran": selectedJenisBon.value,
        "satuan": satuanC.text,
        "kode_unit": selectedKodeUnitKebunPabrik.value
      };

      List<File?> photos = [fotoOdometer.value, null, null];
      final response = await _apiService.createInboundFot(payloadMap: payloadRequestAPI, photos: photos);
      String noDoc = response['no_doc'] ?? "-";

      await _saveToOutstanding(noDoc, payloadRequestAPI, fotoOdometer.value);
      await _draftService.deleteDraft();

      Get.back();

      Get.offNamed(
        Routes.PENGISIAN_SOLAR_PENGELUARAN,
        arguments: {
          'noDoc': noDoc,
          'unitIO': selectedUnit.value?.namaUnit,
          'tanggal': DateFormat('dd/MM/yyyy').format(DateTime.now()),
          'status': 'pengisian_solar_pengeluaran',
          'payload': payloadRequestAPI,
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

  Future<void> _saveToOutstanding(String noDoc, Map<String, dynamic> payload, File? foto) async {
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
      // unitIO: payload['tipe_unit_io'],
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
      kodeUnit: payload['kode_unit']
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
    pengisianSolarC.text = draft['solar'] ?? '';
    selectedStatusSupir.value = draft['status_supir'];
    if (draft['supir_check'] != null) {
      driverNameC.text = draft['supir_check'];
    }
    String? savedUnitName = draft['unit_io'];
    if (savedUnitName != null && _allUnitList.isNotEmpty) {
      try {
        final unit = _allUnitList.firstWhere((e) => e.namaUnit == savedUnitName,
            orElse: () => MasterIoModel());
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
