import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/datas/constant/url_api_static.dart';
import 'package:e_fuel/datas/constant/value_key_static.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/helpers/string_helper.dart';
import 'package:e_fuel/modules/penerimaan/controllers/penerimaan_controller.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../configs/app_fonts.dart';
import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/transactions/penerimaan/transaction_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/fuel_sensor_service.dart';
import '../../transactions/penerimaan/services/outstanding_service.dart';
import '../../transactions/penerimaan/services/penerimaan_api_service.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanSebelumController extends GetxController {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>();
  final LoginService _loginService = Get.find<LoginService>();
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final PenerimaanApiService _apiService = PenerimaanApiService();

  // Data UI
  final totalVolume = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final storageLocations = <String>[].obs;

  // Data Manual Awal
  final totalVolumeManual = 0.0.obs;
  final tankListManualDisplay = <Map<String, String>>[].obs;
  final receivedManualData = <Map<String, dynamic>>[].obs;

  // State
  final isTakingPhoto = false.obs;
  final isSubmitting = false.obs;
  final currentPage = 0.obs;
  final PageController pageController = PageController();

  // --- Controllers Form ---
  // Step 1
  final dateInputController = TextEditingController();
  final dayInputController = TextEditingController();
  final noPoController = TextEditingController();
  final noDoController = TextEditingController();
  final jumlahLtrController = TextEditingController();
  final densityObsController = TextEditingController();
  final temperatureObsController = TextEditingController();
  final noPolisiController = TextEditingController();
  final namaSopirController = TextEditingController();
  final kapasitasTangkiController = TextEditingController();

  // Step 3
  final tinggiTeraSpbController = TextEditingController();
  final tinggiTeraSoundingController = TextEditingController();
  final selisihTinggiTeraController = TextEditingController();
  final nilaiKapelkaanController = TextEditingController();
  final segelTangkiAtasController = TextEditingController();
  final segelTangkiBawahController = TextEditingController();

  // Check Controllers (Hidden/Internal Logic)
  final densityCheckObsController = TextEditingController();
  final temperatureCheckObsController = TextEditingController();
  final noPolisiCheckController = TextEditingController();
  final namaSopirCheckController = TextEditingController();
  final kapasitasTangkiCheckController = TextEditingController();

  final kondisiSegelSelected = 'Baik'.obs;
  final RxList<CapturedImageDetail?> photoSlots = RxList<CapturedImageDetail?>([null, null, null]);

  final ImagePicker _picker = ImagePicker();
  Rx<Position?> lastKnownPosition = Rx<Position?>(null);
  String _activeUsername = "";
  final isLocationReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDate();
    _preFetchLocation();
    _checkRouteParameters();

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('storage')) selectedStorage.value = args['storage'];
      if (args.containsKey('manual_total')) {
        totalVolumeManual.value = (args['manual_total'] as num).toDouble();
      }
      if (args.containsKey('tank_data')) {
        List<Map<String, dynamic>> rawData = List<Map<String, dynamic>>.from(args['tank_data']);
        receivedManualData.assignAll(rawData);

        List<Map<String, String>> displayList = [];
        for (var item in rawData) {
          displayList.add({
            'code': item['tank_code'].toString(),
            'volume': "${item['volume_manual']} Ltr",
            'height': "${item['height_manual']} cm",
          });
        }
        tankListManualDisplay.assignAll(displayList);
      }
    }
    _ensureDataIsLoaded();
  }

  Future<void> _ensureDataIsLoaded() async {
    final auth = await _loginService.getAuthOrLoad();
    if (auth != null) {
      _activeUsername = auth.user.username;
      await _sensorService.loadInitialData(_activeUsername);
      await _fuelDataService.openFuelDataBox(_activeUsername);

      final storages = _fuelDataService.getStorages();
      storageLocations.assignAll(storages.map((e) => e.storageName).toList());

      if (storageLocations.isNotEmpty) {
        if (selectedStorage.value == 'Pilih Lokasi Storage') {
          selectedStorage.value = storageLocations.first;
        }
        calculateDisplayData(selectedStorage.value);
      }
      await _checkAndRestoreDraft();
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  Future<void> _checkAndRestoreDraft() async {
    if (_activeUsername.isEmpty) return;

    final draftService = DraftPenerimaanService(_activeUsername);
    final draft = await draftService.getDraftBefore();

    if (draft != null) {
      Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieConfirmation(),
          title: "Lanjutkan Transaksi?",
          message: "Ditemukan data pengisian yang belum selesai. Apakah Anda ingin melanjutkannya?",
          primaryButtonText: "Ya, Lanjutkan",
          onPrimaryPressed: () {
            _restoreFormData(draft);
            Get.back();
          },
          secondaryButtonText: "Mulai Baru",
          onSecondaryPressed: () {
            draftService.deleteDraftBefore();
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  void _initializeDate() {
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy', 'id_ID');
    final dayFormat = DateFormat('EEEE', 'id_ID');

    String formattedDate = dateFormat.format(now);
    String formattedDay = dayFormat.format(now);

    if (formattedDay.isNotEmpty) {
      formattedDay = formattedDay[0].toUpperCase() + formattedDay.substring(1);
    }

    dateInputController.text = formattedDate;
    dayInputController.text = formattedDay;
  }

  Future<void> _preFetchLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      try {
        lastKnownPosition.value = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition.value == null) {
          lastKnownPosition.value = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.low,
              timeLimit: const Duration(seconds: 5)
          );
        }
        isLocationReady.value = true;
      } catch (e) {
        debugPrint("Gagal pre-fetch lokasi: $e");
      }
    }
  }

  void _checkRouteParameters() {
    final Map<String, String?>? parameters = Get.parameters;

    if (parameters != null && parameters.containsKey('step')) {
      try {
        final String? stepValue = parameters['step'];

        if (stepValue != null) {
          int targetStep = int.parse(stepValue);

          if (targetStep >= 0 && targetStep <= 2) {

            WidgetsBinding.instance.addPostFrameCallback((_) {
              pageController.jumpToPage(targetStep);
              currentPage.value = targetStep;
            });
          }
        }
      } catch (e) {

        debugPrint("Invalid step parameter: ${parameters['step']}");
      }
    }
  }

  void _restoreFormData(PenerimaanSebelumModel draft) {

    String formatVal(double? val) {
      if (val == null) return "";
      return StringHelper().formatNumber(val);
    }

    // Step 1
    noPoController.text = draft.purchNo ?? "";
    noDoController.text = draft.vendorSpb ?? "";

    jumlahLtrController.text = formatVal(draft.volumeVendor);
    densityObsController.text = formatVal(draft.densityVendor);
    temperatureObsController.text = formatVal(draft.tempVendor);

    noPolisiController.text = draft.nopolVendor ?? "";
    namaSopirController.text = draft.supirVendor ?? "";

    kapasitasTangkiController.text = formatVal(draft.kapasitasVendor);

    tinggiTeraSpbController.text = formatVal(draft.terraVendor);
    tinggiTeraSoundingController.text = formatVal(draft.terraCheck);
    selisihTinggiTeraController.text = formatVal(draft.terraVar);

    nilaiKapelkaanController.text = draft.tangkiPeka ?? "";
    segelTangkiAtasController.text = draft.segelTangkiAtas ?? "";
    segelTangkiBawahController.text = draft.segelTangkiBawah ?? "";
    if (draft.segelKondisi != null) kondisiSegelSelected.value = draft.segelKondisi!;

    if (draft.pathFotoDoc != null) _restorePhoto(0, draft.pathFotoDoc!);
    if (draft.pathFotoDepan != null) _restorePhoto(1, draft.pathFotoDepan!);
    if (draft.pathFotoSamping != null) _restorePhoto(2, draft.pathFotoSamping!);

    if (draft.storageCode != null && storageLocations.contains(draft.storageCode)) {
      selectedStorage.value = draft.storageCode!;
    }
  }

  void _restorePhoto(int index, String path) {
    if (File(path).existsSync()) {
      photoSlots[index] = CapturedImageDetail(
          tempPath: path,
          fileName: p.basename(path),
          latitude: 0, longitude: 0 // Koordinat dummy jika tidak disimpan detailnya
      );
    }
  }

  Future<void> _saveCurrentProgressToDraft() async {
    if (_activeUsername.isEmpty) return;

    // Helper local agar kodingan lebih pendek
    double? parseClean(String val) => double.tryParse(StringHelper().cleanNumber(val));

    final currentModel = PenerimaanSebelumModel(
      userName: _activeUsername,
      status: 'draft',

      // Step 1 Form
      purchNo: noPoController.text,
      vendorSpb: noDoController.text,

      // PERBAIKAN DI SINI: Bersihkan titik sebelum parse
      volumeVendor: parseClean(jumlahLtrController.text),
      densityVendor: parseClean(densityObsController.text),
      tempVendor: parseClean(temperatureObsController.text),

      nopolVendor: noPolisiController.text,
      supirVendor: namaSopirController.text,
      kapasitasVendor: parseClean(kapasitasTangkiController.text),

      // Step 3 Form
      nopolCheck: noPolisiCheckController.text,
      supirCheck: namaSopirCheckController.text,
      kapasitasCheck: double.tryParse(kapasitasTangkiCheckController.text),
      densityCheck: double.tryParse(densityCheckObsController.text),
      tempCheck: double.tryParse(temperatureCheckObsController.text),

      terraVendor: parseClean(tinggiTeraSpbController.text),
      terraCheck: parseClean(tinggiTeraSoundingController.text),
      terraVar: parseClean(selisihTinggiTeraController.text),

      tangkiPeka: nilaiKapelkaanController.text,
      segelTangkiAtas: segelTangkiAtasController.text,
      segelTangkiBawah: segelTangkiBawahController.text,
      segelKondisi: kondisiSegelSelected.value,

      // Foto & Lainnya
      pathFotoDoc: photoSlots[0]?.tempPath,
      pathFotoDepan: photoSlots[1]?.tempPath,
      pathFotoSamping: photoSlots[2]?.tempPath,
      storageCode: selectedStorage.value,
      dateInbound: DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );

    final draftService = DraftPenerimaanService(_activeUsername);
    await draftService.saveDraftBefore(currentModel);
  }

  // void _showConfirmationDialog() {
  //   Get.dialog(DialogFlexible(
  //       logo: LottiesHelper().getLottieVerification(),
  //       title: "Konfirmasi", message: "Submit data?",
  //       primaryButtonText: "Ya", onPrimaryPressed: () { Get.back(); _submitPenerimaan(); },
  //       secondaryButtonText: "Batal", onSecondaryPressed: () => Get.back()
  //   ));
  // }

  void _showConfirmationDialog() {
    Get.dialog(
        DialogFlexible(
          logo: LottiesHelper().getLottieVerification(),
          title: "Final Konfirmasi",
          message: "Pastikan semua data dan foto pemeriksaan telah benar. Data yang telah disubmit tidak dapat diubah.",
          secondaryButtonText: "Cek Kembali",
          onSecondaryPressed: () => Get.back(),
          primaryButtonText: "Submit",
          onPrimaryPressed: () async {
            Get.back();
            await _submitPenerimaan();
          },
        )
    );
  }

  Future<void> _submitPenerimaan() async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    final auth = await _loginService.getAuthOrLoad();
    final currentUsername = auth?.user.username ?? "";
    final String token = auth?.access ?? "";

    if (auth == null || currentUsername.isEmpty) {
      Get.snackbar("Error", "Sesi login tidak valid.");
      isSubmitting.value = false;
      return;
    }

    if (token.isEmpty || currentUsername.isEmpty) {
      Get.snackbar("Error", "Sesi login tidak valid. Silahkan login ulang.");
      isSubmitting.value = false;
      return;
    }

    // Loading Dialog
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 24),
              Text("Proses Upload Dokumen...", textAlign: TextAlign.center,
                  style: AppFonts.fUrbanistSemiBold14.copyWith(color: AppColors.primary, fontSize: 16)),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );

    try {
      double? parseClean(String val) =>
          double.tryParse(StringHelper().cleanNumber(val));

      String rawStorage = selectedStorage.value;
      String finalStorageCode = rawStorage.contains(' - ') ? rawStorage
          .split(' - ')
          .last : rawStorage;

      final currentIotSnapshot = _sensorService.iotData.map((e) =>
      {
        'tank_code': e.tankCode,
        'volume_iot': e.volume,
        'height_iot': e.height,
      }).toList();

      final Map<String, dynamic> formMap = {
        'purch_no': noPoController.text,
        'vendor_spb': noDoController.text,
        'doc_type_code': ValueKeyStatic.CODE_TRANSACTION_PENERIMAAN,
        'volume_vendor': jumlahLtrController.text,
        'density_vendor': StringHelper().cleanNumber(densityObsController.text),
        'temp_vendor': StringHelper().cleanNumber(
            temperatureObsController.text),
        'nopol_vendor': noPolisiController.text.toUpperCase(),
        'supir_vendor': namaSopirController.text.toUpperCase(),
        'kapasitas_vendor': StringHelper().cleanNumber(
            kapasitasTangkiController.text),
        'long': photoSlots[0]?.longitude ?? 0,
        'lat': photoSlots[0]?.latitude ?? 0,
        'segel_kondisi': kondisiSegelSelected.value,
        'tangki_peka': nilaiKapelkaanController.text,
        'segel_tangki_bawah': segelTangkiBawahController.text,
        'segel_tangki_atas': segelTangkiAtasController.text,
        'terra_vendor': StringHelper().cleanNumber(
            tinggiTeraSpbController.text),
        'terra_check': StringHelper().cleanNumber(
            tinggiTeraSoundingController.text),
        'terra_var': StringHelper().cleanNumber(
            selisihTinggiTeraController.text),
        'iot_tank_details': jsonEncode(currentIotSnapshot),
        'manual_tank_details': jsonEncode(receivedManualData),
        'date_inbound': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'dtime_before': DateTime.now().toIso8601String(),
        'storage_code': finalStorageCode,
        'volume_terkini_liter': totalVolumeManual.value,
        'kode_unit': auth.user.userKaryawan.unit.kodeUnit ?? "",
      };

      formMap['iot_tank_details'] = jsonEncode(currentIotSnapshot);
      formMap['manual_tank_details'] = jsonEncode(receivedManualData);

      List<File?> filesToUpload = [];
      for (var slot in photoSlots) {
        if (slot != null) {
          filesToUpload.add(File(slot.tempPath));
        } else {
          filesToUpload.add(null);
        }
      }

      final responseData = await _apiService.submitInboundOpen(
          formMap: formMap,
          photos: filesToUpload
      );

      Get.back(); // Tutup Loading
      String noBastResult = responseData['no_doc'] ?? "-";

      final completedModel = PenerimaanSebelumModel(
        userName: currentUsername,
        status: 'proses',
        noDocBast: noBastResult,
        kodeUnit: auth.user.userKaryawan.unit.kodeUnit ?? "",
        isSynced: true,
        purchNo: noPoController.text,
        storageCode: selectedStorage.value,
        vendorSpb: noDoController.text,
        volumeVendor: parseClean(jumlahLtrController.text),
        densityVendor: parseClean(densityObsController.text),
        tempVendor: parseClean(temperatureObsController.text),
        nopolVendor: noPolisiController.text,
        supirVendor: namaSopirController.text,
        kapasitasVendor: parseClean(kapasitasTangkiController.text),
        terraVendor: parseClean(tinggiTeraSpbController.text),
        terraCheck: parseClean(tinggiTeraSoundingController.text),
        terraVar: parseClean(selisihTinggiTeraController.text),
        tangkiPeka: nilaiKapelkaanController.text,
        segelTangkiAtas: segelTangkiAtasController.text,
        segelTangkiBawah: segelTangkiBawahController.text,
        segelKondisi: kondisiSegelSelected.value,
        dateInbound: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        pathFotoDoc: photoSlots[0]?.tempPath,
        pathFotoDepan: photoSlots[1]?.tempPath,
        pathFotoSamping: photoSlots[2]?.tempPath,
        iotTankDetailsJson: jsonEncode(currentIotSnapshot),
        manualTankDetailsJson: jsonEncode(receivedManualData),
        dtimeBefore: DateTime.now().toIso8601String(),
      );

      final trx = TransactionModel(
        noBast: noBastResult,
        status: 'proses',
        dateCreated: DateTime.now().toIso8601String(),
        dataSebelum: completedModel, // Masuk ke sini
        dataSesudah: null,
      );

      final outstandingService = OutstandingService(currentUsername);
      await outstandingService.saveTransaction(trx);

      final draftService = DraftPenerimaanService(currentUsername);
      await draftService.deleteDraftBefore();

      await _handleSuccessStorage(noBastResult);

      if (Get.isRegistered<PenerimaanController>()) {
        Get.find<PenerimaanController>().resetForNewTransaction();
      }

      _showResultDialog(
          isSuccess: true,
          title: "Berhasil Submit",
          message: "No. Doc: $noBastResult",
          onDone: () => Get.offNamed(
              Routes.PENGISIAN_SOLAR,
              arguments: {
                'noBast': noBastResult,
                'noPO': noPoController.text,
                'noPolisi': noPolisiController.text,
                'tanggal': dateInputController.text,
                'status': 'pengisian_solar',
              }
          )
      );

    } on DioException catch (e) {
      Get.back();
      if (e.response != null) {
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;
        String errorDetail = "Terjadi kesalahan.";

        if (responseData is Map && responseData.containsKey('detail')) {
          var detail = responseData['detail'];
          if (detail is List) {
            errorDetail = detail.map((e) => e.toString()).join('\n');
          } else {
            errorDetail = detail.toString();
          }
        }

        if (statusCode == 400 || statusCode == 422) {
          _showResultDialog(
              isSuccess: false,
              title: "Submit Gagal",
              message: errorDetail,
              onDone: () {}
          );
        } else if (statusCode == 404) {
          _showResultDialog(
              isSuccess: false,
              title: "Data Tidak Ditemukan",
              message: errorDetail,
              onDone: () {}
          );
        } else {
          _showResultDialog(
              isSuccess: false,
              title: "Server Error ($statusCode)",
              message: errorDetail,
              onDone: () {}
          );
        }
      } else {
        _showResultDialog(
            isSuccess: false,
            title: "Koneksi Gagal",
            message: "Gagal terhubung ke server.\n${e.message}",
            onDone: () {}
        );
      }
    } catch (e) {
      Get.back();
      _handleError(e);
    } finally {
      isSubmitting.value = false;
    }
  }

  void _handleError(dynamic e) {
    if (e is DioException && e.response != null) {
      final statusCode = e.response?.statusCode;
      final responseData = e.response?.data;
      String errorDetail = "Terjadi kesalahan.";

      if (responseData is Map && responseData.containsKey('detail')) {
        var detail = responseData['detail'];
        if (detail is List) {
          errorDetail = detail.map((e) => e.toString()).join('\n');
        } else {
          errorDetail = detail.toString();
        }
      } else if (responseData is Map && responseData.containsKey('message')) {
        errorDetail = responseData['message'];
      }

      if (statusCode == 404) {
        _showResultDialog(isSuccess: false, title: "Data Tidak Ditemukan", message: errorDetail, onDone: (){});
      } else {
        _showResultDialog(isSuccess: false, title: "Gagal ($statusCode)", message: errorDetail, onDone: (){});
      }
    } else {
      // Error koneksi / Lainnya
      _showResultDialog(
          isSuccess: false,
          title: "Gagal",
          message: e.toString().replaceAll("Exception:", ""),
          onDone: (){}
      );
    }
  }

  Future<void> _handleSuccessStorage(String noBast) async {
    try {
      final Directory appDocDir = await getApplicationDocumentsDirectory();
      final String permanentStoragePath = p.join(appDocDir.path, 'penerimaan_sebelum', noBast);
      final Directory permanentDir = Directory(permanentStoragePath);

      if (!await permanentDir.exists()) {
        await permanentDir.create(recursive: true);
      }

      for (var i = 0; i < photoSlots.length; i++) {
        final detail = photoSlots[i];
        if (detail != null) {
          final int nourutImage = i + 1;
          final String permanentFileName = '${noBast}_$nourutImage.jpg';
          final String permanentPath = p.join(permanentStoragePath, permanentFileName);
          await File(detail.tempPath).copy(permanentPath);
        }
      }
    } catch (e) {
      debugPrint("Gagal copy file: $e");
    }
  }

  void _showResultDialog({
    required bool isSuccess,
    required String title,
    required String message,
    required VoidCallback onDone,
  }) {
    Widget logoWidget;

    if (isSuccess) {
      logoWidget = LottiesHelper().getLottieSuccess();
    } else {
      logoWidget = LottiesHelper().getLottieFailed();
    }

    Get.dialog(
      DialogFlexible(
        logo: logoWidget,
        title: title,
        message: message,
        primaryButtonText: isSuccess ? "Selesai" : "Tutup",
        onPrimaryPressed: () {
          Get.back();
          onDone();
        },
        secondaryButtonText: null,
        onSecondaryPressed: null,
      ),
      barrierDismissible: false,
    );
  }

  bool _validateCurrentStep() {
    String errorMessage = "";

    if (currentPage.value == 0) {
      if (noPoController.text.isEmpty) errorMessage = "No. PO harus diisi";
      else if (noDoController.text.isEmpty) errorMessage = "No. DO harus diisi";
      else if (jumlahLtrController.text.isEmpty) errorMessage = "Jumlah Liter harus diisi";
      else if (densityObsController.text.isEmpty) errorMessage = "Density harus diisi";
      else if (temperatureObsController.text.isEmpty) errorMessage = "Temperatur harus diisi";
      else if (noPolisiController.text.isEmpty) errorMessage = "No. Polisi harus diisi";
      else if (namaSopirController.text.isEmpty) errorMessage = "Nama Sopir harus diisi";
      else if (kapasitasTangkiController.text.isEmpty) errorMessage = "Kapasitas Tangki harus diisi";
    } else if (currentPage.value == 1) {
      if (photoSlots.any((element) => element == null)) {
        errorMessage = "Mohon lengkapi 3 foto (Dokumen, Depan, Samping)";
      }
    } else if (currentPage.value == 2) {
      if (tinggiTeraSpbController.text.isEmpty) errorMessage = "Tinggi Tera SPB harus diisi";
      else if (tinggiTeraSoundingController.text.isEmpty) errorMessage = "Tinggi Zounding harus diisi";
      else if (selisihTinggiTeraController.text.isEmpty) errorMessage = "Selisih Tinggi Tera harus diisi";
      else if (nilaiKapelkaanController.text.isEmpty) errorMessage = "Nilai Kapelkaan harus diisi";
      else if (segelTangkiAtasController.text.isEmpty) errorMessage = "Segel Atas harus diisi";
      else if (segelTangkiBawahController.text.isEmpty) errorMessage = "Segel Bawah harus diisi";
    }

    if (errorMessage.isNotEmpty) {
      Get.snackbar(
        "Data Belum Lengkap",
        errorMessage,
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(16),
      );
      return false;
    }
    return true;
  }

  void calculateDisplayData(String storageName) {
    String storageCode = storageName.split(' - ').length > 1
        ? storageName.split(' - ').last
        : storageName;

    final activeTanks = _sensorService.iotData.where(
          (tank) => tank.storageCode == storageCode && tank.statusActive == 'Y',
    ).toList();

    activeTanks.sort((a, b) => a.tankCode.compareTo(b.tankCode));

    double totalVol = 0.0;
    List<Map<String, String>> tempList = [];

    for (var tank in activeTanks) {
      totalVol += tank.volume;
      tempList.add({
        'code': tank.tankCode,
        'volume': tank.volume.toString(), // Sesuaikan tipe data string/double
        'height': tank.height.toString(),
      });
    }

    totalVolume.value = totalVol;
    tankListDisplay.assignAll(tempList);
  }

  Future<void> takeSpecificPhoto(int index) async {
    try {
      isTakingPhoto.value = true;

      final currentLat = lastKnownPosition.value?.latitude ?? 0;
      final currentLong = lastKnownPosition.value?.longitude ?? 0;
      final XFile? imageFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080.0,
        imageQuality: 70,
      );

      if (imageFile == null) {
        isTakingPhoto.value = false;
        return;
      }

      final String tempPath = imageFile.path;
      final String tempFileName = p.basename(tempPath);

      photoSlots[index] = CapturedImageDetail(
        tempPath: tempPath,
        latitude: currentLat,
        longitude: currentLong,
        fileName: tempFileName,
      );

    } catch (e) {
      if (kDebugMode) print('Error saat takePhoto: $e');
      Get.snackbar("Gagal Mengambil Foto", "Terjadi error: $e");
    } finally {
      isTakingPhoto.value = false;
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < 3 && photoSlots[index] != null) {
      try {
        File(photoSlots[index]!.tempPath).deleteSync();
      } catch (e) {
        debugPrint('Gagal menghapus file sementara: $e');
      }

      photoSlots[index] = null;
    }
  }

  void goToNextPage() async {
    if (!_validateCurrentStep()) return;
    if (currentPage.value < 2) {
      pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.easeIn);
    } else {
      _showConfirmationDialog();
    }
  }
  void onPageChanged(int index) { currentPage.value = index; }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}