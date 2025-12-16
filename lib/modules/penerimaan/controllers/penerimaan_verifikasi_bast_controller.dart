import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'package:e_fuel/configs/app_lotties.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:signature/signature.dart';

import '../../../configs/app_colors.dart';
import '../../../datas/models/approval/konfigurasi_approval_model.dart';
import '../../../datas/models/filling/filling_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../helpers/connectivity_helper.dart';
import '../../../helpers/text_convert_helper.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/dialog/dialog_flexible.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/master_data_service.dart';
import '../../transactions/outstanding_service.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanVerifikasiBastController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final PenerimaanApiService _apiService = PenerimaanApiService();
  final MasterDataService _masterDataService = MasterDataService();

  late DraftPenerimaanService _draftService;

  // Data Utama
  final fillingDataList = <FillingModel>[].obs;
  final ConnectivityHelper _connectivityHelper = Get.find<ConnectivityHelper>();

  // Menampung Data Transaksi Lengkap (Sebelum Pengisian)
  final Rx<TransactionModel?> currentTransaction = Rx<TransactionModel?>(null);

  // Data UI Header
  final totalVolumeDisplay = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final selectedStorage = "".obs;
  final activeNoBast = "".obs;

  final pageController = PageController();
  final currentPage = 0.obs;

  // --- FORM CONTROLLERS (STEP 2) ---
  final stdTinggiController = TextEditingController(text: "1605");
  final stdLiterController = TextEditingController(text: "0"); // Hasil API Standar

  final actTinggiController = TextEditingController(); // Input User
  final volumeDiterimaLtrController = TextEditingController(text: "0"); // Hasil API Aktual

  final stdPanjangController = TextEditingController(text: "0");
  final stdLebarController = TextEditingController(text: "0");
  // final stdTinggiController = TextEditingController(text: "0");

  final actPanjangController = TextEditingController(text: "0");
  final actLebarController = TextEditingController(text: "0");
  // final actTinggiController = TextEditingController(text: "0");

  // final volumeDiterimaLtrController = TextEditingController();
  final volumePengirimController = TextEditingController();
  final volumeKebunController = TextEditingController();
  final varianController = TextEditingController();

  final catatanGudangController = TextEditingController();
  final signatureGudangController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );
  final signatureSupirController = SignatureController(
    penStrokeWidth: 3, penColor: AppColors.darkText, exportBackgroundColor: AppColors.white,
  );

  Timer? _debounceTimer;

  @override
  void onInit() {
    super.onInit();

    // Init Draft Service
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      _draftService = DraftPenerimaanService(auth.user.username);
    }

    _loadTransactionContext();
    _fetchLiterFromApi(1605, stdLiterController);
    actTinggiController.addListener(_onActualHeightChanged);
  }

  void _onActualHeightChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      String text = actTinggiController.text.replaceAll('.', '').replaceAll(',', '.');
      if (text.isEmpty) {
        volumeDiterimaLtrController.text = "0";
        volumeKebunController.text = "0"; // Update field bawah juga
        hitungVarian();
        return;
      }

      double? height = double.tryParse(text);
      if (height != null) {
        _fetchLiterFromApi(height, volumeDiterimaLtrController, isActual: true);
      }
    });
  }

  Future<void> _fetchLiterFromApi(double heightMm, TextEditingController targetCtrl, {bool isActual = false}) async {
    int capacity = 10000;

    final result = await _masterDataService.getLiterFromCalibration(
        kapasitas: capacity,
        tinggiMm: heightMm
    );

    if (result != null) {
      String formatted = TextConvertHelper().formatNumber(result);
      targetCtrl.text = formatted;

      // Jika ini input aktual, update juga field "Volume Kebun" di bawah
      if (isActual) {
        volumeKebunController.text = formatted;
        hitungVarian();
      }
    }
  }

  Future<void> _loadTransactionContext() async {
    final args = Get.arguments;
    if (args != null) {
      if (args['noBast'] != null) {
        activeNoBast.value = args['noBast'];
        await _loadFullTransactionData(activeNoBast.value);
      }

      if (args['filling_models'] != null) {
        List<FillingModel> data = args['filling_models'] as List<FillingModel>;
        fillingDataList.assignAll(data);

        _calculateHeaderData(data);
      } else {
        await _reconstructFillingDataFromDraft();
      }
    }
  }

  Future<void> _reconstructFillingDataFromDraft() async {
    if (currentTransaction.value == null) return;

    final trx = currentTransaction.value!;
    final detailSebelum = trx.dataSebelum;

    if (detailSebelum == null) return;

    try {
      // 1. Ambil Data Sebelum (Manual & IoT) dari JSON Hive
      Map<String, double> volBeforeMap = {};
      Map<String, double> heightBeforeMap = {};
      Map<String, double> volBeforeIoTMap = {};
      Map<String, double> heightBeforeIoTMap = {};

      if (detailSebelum.manualTankDetailsJson != null) {
        List<dynamic> manualList = jsonDecode(detailSebelum.manualTankDetailsJson!);
        for (var item in manualList) {
          String code = item['tank_code'].toString().replaceAll(' ', '_');
          volBeforeMap[code] = (item['volume_manual'] as num).toDouble();
          heightBeforeMap[code] = (item['height_manual'] as num).toDouble();
        }
      }

      if (detailSebelum.iotTankDetailsJson != null) {
        List<dynamic> iotList = jsonDecode(detailSebelum.iotTankDetailsJson!);
        for (var item in iotList) {
          String code = item['tank_code'].toString().replaceAll(' ', '_');
          volBeforeIoTMap[code] = ((item['volume_iot'] ?? item['volume']) as num).toDouble();
          heightBeforeIoTMap[code] = ((item['height_iot'] ?? item['height']) as num).toDouble();
        }
      }

      // 2. Ambil Data Sesudah dari Draft Service
      final draftSesudah = await _draftService.getDraftSesudah(activeNoBast.value);

      if (draftSesudah == null || draftSesudah.isEmpty) {
        print("⚠️ Draft Sesudah tidak ditemukan untuk ${activeNoBast.value}");
        return;
      }

      // 3. Rebuild FillingModel List
      List<FillingModel> restoredList = [];

      draftSesudah.forEach((tankCodeRaw, values) {
        // Tank Code di draft mungkin key-nya
        String tankCode = tankCodeRaw.toString();

        double volAfter = 0.0;
        double hAfter = 0.0;

        if (values is Map) {
          volAfter = double.tryParse(TextConvertHelper().cleanNumber(values['volume'] ?? '0')) ?? 0.0;
          hAfter = double.tryParse(TextConvertHelper().cleanNumber(values['height'] ?? '0')) ?? 0.0;
        }

        // Ambil Data Sebelum pasangan-nya
        double volBefore = volBeforeMap[tankCode] ?? 0.0;
        double hBefore = heightBeforeMap[tankCode] ?? 0.0;

        // IoT Data (jika ada, jika tidak 0)
        // Kita asumsikan IoT Sesudah tidak tersimpan di draft (karena live),
        // jadi kita bisa set IoT Sesudah = IoT Sebelum atau 0 (sesuai kebutuhan logic)
        // Disini kita set varian IoT 0 agar aman.

        double volIoTBefore = volBeforeIoTMap[tankCode] ?? 0.0;
        double hIoTBefore = heightBeforeIoTMap[tankCode] ?? 0.0;

        restoredList.add(FillingModel(
            transactionId: activeNoBast.value,
            storageCode: detailSebelum.storageCode ?? "",
            tankCode: tankCode,
            timestamp: DateTime.now().toIso8601String(),

            volumeBefore: volBefore,
            heightBefore: hBefore,
            volumeAfter: volAfter,
            heightAfter: hAfter,
            volumeVariant: volAfter - volBefore,
            heightVariant: hAfter - hBefore,

            volumeBeforeIoT: volIoTBefore,
            heightBeforeIoT: hIoTBefore,
            volumeAfterIoT: volIoTBefore, // Anggap sama jika data live hilang
            heightAfterIoT: hIoTBefore,
            volumeVariantIoT: 0,
            heightVariantIoT: 0
        ));
      });

      fillingDataList.assignAll(restoredList);
      _calculateHeaderData(restoredList);

      print("✅ Berhasil restore ${restoredList.length} data tangki dari draft.");

    } catch (e) {
      print("❌ Error reconstructing filling data: $e");
      Get.snackbar("Error Data", "Gagal memulihkan data pengukuran: $e");
    }
  }

  Future<void> _loadFullTransactionData(String noBast) async {
    final auth = _loginService.getCurrentAuth();
    if (auth != null) {
      final outstandingService = OutstandingService(auth.user.username);
      final trx = await outstandingService.getTransactionByNoBast(noBast);

      if (trx != null) {
        currentTransaction.value = trx;
        final detail = trx.dataSebelum;
        if (detail != null) {
          if (detail.storageCode != null) {
            selectedStorage.value = detail.storageCode!;
          }
          if (detail.volumeVendor != null) {
            volumePengirimController.text = TextConvertHelper().formatNumber(detail.volumeVendor!);
          }
        }
      }
    }
  }

  void _calculateHeaderData(List<FillingModel> data) {
    double tempTotal = 0.0;
    List<Map<String, String>> tempList = [];

    for (var item in data) {
      tempTotal += item.volumeAfter; // Gunakan volume sesudah
      tempList.add({
        'code': item.tankCode.replaceAll('_', ' '),
        'volume': "${TextConvertHelper().formatNumber(item.volumeAfter)} Ltr",
        'height': "${TextConvertHelper().formatNumber(item.heightAfter)} cm", // Sesuaikan satuan jika mm
      });
    }

    totalVolumeDisplay.value = tempTotal;
    tankListDisplay.assignAll(tempList);
  }

  void hitungVarian() {
    // Bersihkan format ribuan (misal: 10.000 -> 10000)
    double pengirim = double.tryParse(volumePengirimController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    double kebun = double.tryParse(volumeKebunController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

    double varian = kebun - pengirim;
    varianController.text = TextConvertHelper().formatNumber(varian);
  }

  void nextPage() {
    // Cek validasi halaman saat ini sebelum lanjut
    if (!_validateCurrentPage()) return;

    if (currentPage.value < 3) {
      pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut
      );
    } else {
      submitBast();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    } else {
      Get.back();
    }
  }

  void onPageChanged(int index) { currentPage.value = index; }

  bool _validateCurrentPage() {
    int page = currentPage.value;

    if (page == 0) return true;

    if (page == 1) {
      return _validateStepPengukuran();
    }

    if (page == 2) return true;
    return true;
  }

  bool _validateStepPengukuran() {
    bool checkEmpty(TextEditingController ctrl, String fieldName) {
      if (ctrl.text.trim().isEmpty) {
        Get.snackbar("Data Kurang", "$fieldName wajib diisi.",
            backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white, snackPosition: SnackPosition.TOP);
        return false;
      }
      return true;
    }

    // Validasi Field Baru
    if (!checkEmpty(actTinggiController, "Tinggi Aktual (mm)")) return false;
    if (!checkEmpty(volumePengirimController, "Volume Pengirim")) return false;

    // Validasi Logic
    double volDiterima = double.tryParse(volumeDiterimaLtrController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    if (volDiterima <= 0) {
      Get.snackbar("Data Invalid", "Volume Solar Diterima masih 0. Pastikan tinggi diinput dengan benar.",
          backgroundColor: AppColors.alertSoftRed, colorText: AppColors.white, snackPosition: SnackPosition.TOP);
      return false;
    }

    return true;
  }

  Future<void> submitBast() async {
    if (signatureGudangController.isEmpty || signatureSupirController.isEmpty) {
      Get.snackbar(
          "Data Belum Lengkap",
          "Mohon lengkapi tanda tangan Gudang dan Supir sebelum submit.",
          backgroundColor: AppColors.alertSoftRed,
          colorText: AppColors.white,
          snackPosition: SnackPosition.TOP
      );
      return;
    }

    bool isConnected = await _connectivityHelper.checkConnection();
    if (!isConnected) {
      _showConnectionErrorDialog();
      return;
    }

    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(AppLotties.confirmation, width: 150, height: 150),
        title: "Konfirmasi Submit",
        message: "Apakah Anda yakin data sudah benar? Proses submit tidak dapat diubah kembali.",

        primaryColor: AppColors.primary,

        // Tombol Batal
        secondaryButtonText: "Cek Lagi",
        onSecondaryPressed: () {
          Get.back();
        },

        // Tombol Submit (Langsung proses karena koneksi sudah dicek di awal)
        primaryButtonText: "Ya, Submit",
        onPrimaryPressed: () {
          Get.back();
          _processSubmit();
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _processSubmit() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // =======================================================================
      // STEP 0: PREPARE DATA & SAVE SIGNATURE LOCAL FIRST
      // =======================================================================
      if (signatureGudangController.isEmpty) {
        throw "Tanda tangan Gudang (Penerima) wajib diisi!";
      }

      if (signatureSupirController.isEmpty) {
        throw "Tanda tangan Supir/Partner wajib diisi!";
      }

      final auth = _loginService.getCurrentAuth();
      final currentTx = currentTransaction.value;

      if (auth == null || currentTx == null) throw "Data user atau transaksi tidak valid.";

      File? fileGudang = await _saveSignature(
          signatureGudangController, "ttd_gudang_${activeNoBast.value}.png");
      File? fileSupir = await _saveSignature(
          signatureSupirController, "ttd_supir_${activeNoBast.value}.png");

      if (fileGudang == null || fileSupir == null) throw "Gagal menyimpan Tanda Tangan.";

      String userLevel = auth.user.otorisasi.first;
      String kodeUnit = currentTransaction.value?.dataSebelum?.kodeUnit ?? "";
      String docType = currentTransaction.value?.dataSebelum?.docTypeCode ?? "FIN";

      if (kodeUnit.isEmpty) {
        throw "Kode Unit wajib diisi!";
      }

      /// =======================================================================
      // STEP 1: HIT API - CEK KONFIGURASI APPROVAL
      // =======================================================================
      List<KonfigurasiApprovalModel> configList = await _apiService.getKonfigurasiApproval(
        transactionType: docType, kodeUnit: kodeUnit, statusActive: true,
      );

      KonfigurasiApprovalModel myConfig = configList.firstWhere(
            (config) => config.levelApproval == userLevel,
        orElse: () => throw "Akun ($userLevel) tidak memiliki akses approval.",
      );

      print("✅ Step 1: Validasi Approval Berhasil (ID: ${myConfig.id})");
      print("✅ Step 1: Validasi Approval Berhasil: Step ${myConfig.stepApproval}");

      // =======================================================================
      // STEP 2: HIT API - CREATE INBOUND TANK
      // =======================================================================

      List<Map<String, dynamic>> tanksPayload = fillingDataList.map((item) {
        return {
          "kode_tank": item.tankCode,
          "volume_terkini_liter": item.volumeBefore,
          "tinggi_terkini_cm": item.heightBefore,
          "volume_akhir_liter": item.volumeAfter,
          "tinggi_akhir_cm": item.heightAfter,
          "tinggi_var_cm": item.heightVariant,
          "volume_var_liter": item.volumeVariant,
        };
      }).toList();

      List<Map<String, dynamic>> iotPayload = [];
      for (var item in fillingDataList) {
        iotPayload.add({
          "kode_tank": item.tankCode,
          "iot_volume_terkini_liter": item.volumeBeforeIoT,
          "iot_tinggi_terkini_cm": item.heightBeforeIoT,
          "iot_volume_akhir_liter": item.volumeAfterIoT,
          "iot_tinggi_akhir_cm": item.heightAfterIoT,
          "iot_volume_var_liter": item.volumeVariantIoT,
          "iot_tinggi_var_cm": item.heightVariantIoT,
        });
      }

      double parseTxt(TextEditingController ctrl) =>
          double.tryParse(ctrl.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

      List<Map<String, dynamic>> standarPayload = fillingDataList.map((item) {
        return {
          "kode_tank": item.tankCode,
          // Field Panjang & Lebar dikirim 0
          "std_panjang_tangki_kebun": 0,
          "std_lebar_tangki_kebun": 0,
          "std_tinggi_tangki_kebun": parseTxt(stdTinggiController), // 1605

          "std_panjang_diterima": 0,
          "std_lebar_diterima": 0,
          "std_tinggi_diterima": parseTxt(actTinggiController), // Input User

          "volume_solar_diterima": parseTxt(volumeDiterimaLtrController), // Hasil API
          "volume_tangki_pengirim": parseTxt(volumePengirimController),
          "var_solar_tangki": parseTxt(varianController),
        };
      }).toList();

      Map<String, dynamic> inboundPayload = {
        "no_doc": activeNoBast.value,
        "tanks": tanksPayload,
        "iot_tanks": iotPayload,
        "ukuran_standar_tanks": standarPayload, // Payload Standar Baru
      };

      await _apiService.createInboundTank(inboundPayload);
      print("✅ Step 2: Create Inbound Tank Berhasil");

      // =======================================================================
      // STEP 3: HIT API - CREATE TRANSACTION APPROVAL (MULTIPART)
      // =======================================================================

      try {
        print("⏳ Step 3: Create Transaction Approval (Init)...");
        await _apiService.createTransactionApproval(
          noDoc: activeNoBast.value,
          kodeUnit: kodeUnit,
          transactionType: docType,
        );
        print("✅ Step 3: Transaction Approval Created");
      } catch (e) {
        print("⚠️ Step 3 Warning: $e");
      }

      // =======================================================================
      // STEP 4: HIT API - UPDATE STATUS TRANSACTION
      // =======================================================================

      print("⏳ Step 4: Uploading Signature & Updating Status...");

      await _apiService.updateStatusTransactionApproval(
        noDoc: activeNoBast.value,
        levelApproval: myConfig.levelApproval ?? "1",
        statusApprove: "APPROVED",
        catatan: catatanGudangController.text.isEmpty
            ? "Verifikasi BAST Selesai"
            : catatanGudangController.text,
        isSign: true,
        isPartnerSign: true,
      );
      print("✅ Step 4: Status Updated");

      // =======================================================================
      // STEP 5: HIT API - UPLOAD SIGNATURE IMAGE (NEW)
      // =======================================================================

      print("⏳ Step 5: Uploading Signature Files...");
      await _apiService.uploadSignatureTransactionApproval(
        noDoc: activeNoBast.value,
        levelApproval: myConfig.levelApproval ?? "1",
        imageSign1: fileGudang,
        imageSign2: fileSupir,
      );
      print("✅ Step 5: Signature Uploaded");

      // =======================================================================
      // FINAL: Save Local Data & Close
      // =======================================================================

      for (var item in fillingDataList) {
        await _fuelDataService.saveManualTankInput(
            tankCode: item.tankCode,
            volume: item.volumeAfter,
            height: item.heightAfter
        );
      }

      final outstandingService = OutstandingService(auth.user.username);

      await outstandingService.updateStatus(
        activeNoBast.value,
        'approval_kasie',
        levelApproval: myConfig.levelApproval,
        stepApproval: myConfig.stepApproval,
      );

      var transaction = await outstandingService.getTransactionByNoBast(activeNoBast.value);
      if (transaction != null) {
        transaction.status = 'approval_kasie';
        await transaction.save();
      }

      Get.back();
      _showResultDialog(
        isSuccess: true,
        message: "Dokumen berhasil disetujui dan diteruskan ke Kasie untuk approval selanjutnya.",
      );

    } catch (e) {
      Get.back();

      print("❌ Error Submit (Raw): $e");
      String userMessage = TextConvertHelper().handleApiError(e);

      _showResultDialog(
          isSuccess: false,
          message: userMessage
      );
    }
  }

  Future<File?> _saveSignature(SignatureController controller, String fileName) async {
    if (controller.isEmpty) return null;

    final Uint8List? data = await controller.toPngBytes();
    if (data == null) return null;

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fullPath = p.join(dir.path, fileName);

    final File file = File(fullPath);
    await file.writeAsBytes(data);

    print("Tanda tangan disimpan di: $fullPath");
    return file;
  }

  void _showResultDialog({required bool isSuccess, required String message}) {
    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(
          isSuccess ? AppLotties.success : AppLotties.failed,
          width: 150,
          height: 150,
          repeat: isSuccess ? false : true,
        ),
        title: isSuccess ? "Berhasil" : "Gagal Memproses",
        message: message,
        primaryButtonText: isSuccess ? "Selesai" : "Tutup",
        onPrimaryPressed: () {
          Get.back();

          if (isSuccess) {
            Get.offNamed(Routes.PENERIMAAN_TRACKING, arguments: activeNoBast.value);
          }
        },
      ),
      barrierDismissible: false,
    );
  }

  void _showConnectionErrorDialog() {
    if (Get.isDialogOpen ?? false) return;

    Get.dialog(
      DialogFlexible(
        logo: Lottie.asset(
          AppLotties.failed,
          width: 150,
          height: 150,
          repeat: true,
        ),
        title: "Koneksi Bermasalah",
        message: "Gagal terhubung ke server. Pastikan koneksi internet Anda stabil dan coba lagi.",

        primaryButtonText: "Tutup",
        onPrimaryPressed: () => Get.back(),
      ),
      barrierDismissible: false,
    );
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();

    // Dispose Controller Step 2 (Yang Aktif)
    stdTinggiController.dispose();
    stdLiterController.dispose();
    actTinggiController.dispose();
    volumeDiterimaLtrController.dispose();

    stdPanjangController.dispose();
    stdLebarController.dispose();

    actPanjangController.dispose();
    actLebarController.dispose();

    // Dispose Controller Lainnya
    volumePengirimController.dispose();
    volumeKebunController.dispose();
    varianController.dispose();

    catatanGudangController.dispose();
    signatureGudangController.dispose();
    signatureSupirController.dispose();

    pageController.dispose();
    super.onClose();
  }
}