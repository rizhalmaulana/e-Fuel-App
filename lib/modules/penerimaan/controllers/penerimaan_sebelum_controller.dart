import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/unit_to_storage/unit_to_storage_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../routes/app_pages.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';
import '../../fuel/services/fuel_sensor_service.dart';
import '../services/draft_penerimaan_service.dart';

class PenerimaanSebelumController extends GetxController {
  final FuelSensorService _sensorService = Get.find<FuelSensorService>(); // Service Sensor
  final FuelDataService _fuelDataService = Get.find<FuelDataService>(); // Service Manual & Master
  final LoginService _loginService = Get.find<LoginService>();

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
      if (args.containsKey('storage')) {
        selectedStorage.value = args['storage'];
      }
    }
    _ensureDataIsLoaded();
  }

  Future<void> _ensureDataIsLoaded() async {
    final auth = await _loginService.getAuthOrLoad();
    if (auth != null) {
      _activeUsername = auth.user.username;

      await _fuelDataService.openFuelDataBox(_activeUsername);
      await _sensorService.initSensorBox(_activeUsername); // Init Sensor Bo

      final List<UnitToStorageModel> rawStorages = _fuelDataService.getLocalStorages();

      // Flat-kan list storage (Unit -> List<Storage>)
      List<String> formattedStorages = [];
      for (var unitData in rawStorages) {
        for (var storage in unitData.masterStorage) {
          if (storage.storageStatus == 'Y') {
            formattedStorages.add("${storage.namaStorage} - ${storage.kodeStorage}");
          }
        }
      }

      storageLocations.assignAll(formattedStorages);

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
      return TextConvertHelper().formatNumber(val);
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

  void proceedToTankMeasurement() {
    if (!_validateCurrentStep()) return;

    final Map<String, dynamic> administrativeData = {
      'purch_no': noPoController.text,
      'vendor_spb': noDoController.text,
      'volume_vendor': TextConvertHelper().cleanNumber(jumlahLtrController.text),
      'density_vendor': TextConvertHelper().cleanNumber(densityObsController.text),
      'temp_vendor': TextConvertHelper().cleanNumber(temperatureObsController.text),
      'nopol_vendor': noPolisiController.text.toUpperCase(),
      'supir_vendor': namaSopirController.text.toUpperCase(),
      'kapasitas_vendor': TextConvertHelper().cleanNumber(kapasitasTangkiController.text),

      // Data Step 3 (Pemeriksaan)
      'terra_vendor': TextConvertHelper().cleanNumber(tinggiTeraSpbController.text),
      'terra_check': TextConvertHelper().cleanNumber(tinggiTeraSoundingController.text),
      'terra_var': TextConvertHelper().cleanNumber(selisihTinggiTeraController.text),
      'tangki_peka': nilaiKapelkaanController.text,
      'segel_tangki_atas': segelTangkiAtasController.text,
      'segel_tangki_bawah': segelTangkiBawahController.text,
      'segel_kondisi': kondisiSegelSelected.value,

      // Lokasi & Foto
      'storage_code': selectedStorage.value,
      'long': photoSlots[0]?.longitude ?? 0,
      'lat': photoSlots[0]?.latitude ?? 0,
      'path_foto_doc': photoSlots[0]?.tempPath,
      'path_foto_depan': photoSlots[1]?.tempPath,
      'path_foto_samping': photoSlots[2]?.tempPath,

      'date_inbound': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'dtime_before': DateTime.now().toIso8601String(),
    };

    Get.toNamed(
        Routes.PENERIMAAN,
        arguments: {
          'administrative_data': administrativeData,
          'is_new_transaction': true
        }
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
          (tank) => tank.masterStorage?.kodeStorage == storageCode,
    ).toList();

    activeTanks.sort((a, b) {
      String codeA = a.masterSolarTank?.kodeTank ?? '';
      String codeB = b.masterSolarTank?.kodeTank ?? '';
      return codeA.compareTo(codeB);
    });

    double totalVol = 0.0;
    List<Map<String, String>> tempList = [];

    for (var tank in activeTanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? 'UNK';

      final manualState = _fuelDataService.getManualTankInput(tankCode);
      double vol = manualState['volume']!;
      double height = manualState['height']!;

      totalVol += vol;
      tempList.add({
        'code': tankCode,
        'volume': "${vol.toStringAsFixed(0)} Ltr",
        'height': "${height.toStringAsFixed(0)} cm",
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
        preferredCameraDevice: CameraDevice.rear,
        maxWidth: 1080.0,
        maxHeight: 1920.0,
        imageQuality: 80,
      );

      if (imageFile == null) {
        isTakingPhoto.value = false;
        return;
      }

      File originalFile = File(imageFile.path);
      File? compressedFile = await _compressImage(originalFile);

      if (compressedFile == null) return;

      final String tempPath = compressedFile.path;
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

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
      final splitted = file.path.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";

      // Hapus file lama jika ada
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
      print("Gagal compress: $e");
      return file;
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
      pageController.nextPage(
          duration: const Duration(milliseconds: 800), curve: Curves.easeIn);
    } else {
      // Step Terakhir: Lanjut ke Pengukuran Tangki (PenerimaanController)
      proceedToTankMeasurement();
    }
  }

  void onPageChanged(int index) { currentPage.value = index; }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}