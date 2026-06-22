import 'dart:io';

import 'package:e_fuel/configs/app_colors.dart';
import 'package:e_fuel/helpers/lotties_helper.dart';
import 'package:e_fuel/helpers/text_convert_helper.dart';
import 'package:e_fuel/modules/penerimaan/repositories/penerimaan_sebelum_repository.dart';
import 'package:e_fuel/widgets/dialog/dialog_flexible.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart' hide MultipartFile, FormData;
import '../../../widgets/component/custom_snackbar.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../../../datas/models/penerimaan/penerimaan_sebelum_pengisian/penerimaan_sebelum_model.dart';
import '../../../datas/models/widgets/capture_image_detail.dart';
import '../../../routes/app_pages.dart';
import '../../../widgets/component/custom_camera_view.dart';
import '../../auth/services/login_service.dart';
import '../../fuel/services/fuel_data_service.dart';

class PenerimaanSebelumController extends GetxController {
  final LoginService _loginService = Get.find<LoginService>();
  late PenerimaanSebelumRepository _repository;
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();

  final totalVolume = 0.0.obs;
  final tankListDisplay = <Map<String, String>>[].obs;
  final selectedStorage = 'Pilih Lokasi Storage'.obs;
  final storageLocations = <String>[].obs;

  final isTakingPhoto = false.obs;
  final currentPage = 0.obs;
  final PageController pageController = PageController();
  final RxList<CapturedImageDetail?> photoSlots = RxList<CapturedImageDetail?>([null, null, null]);

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

  final tinggiTeraSpbController = TextEditingController();
  final tinggiTeraSoundingController = TextEditingController();
  final selisihTinggiTeraController = TextEditingController();
  final selisihVolumeTeraController = TextEditingController();
  final nilaiKepekaanController = TextEditingController();
  final segelTangkiAtasController = TextEditingController();
  final segelTangkiBawahController = TextEditingController();
  final kondisiSegelSelected = 'Baik'.obs;

  Rx<Position?> lastKnownPosition = Rx<Position?>(null);
  String _activeUsername = "";
  final activePhotoLabel = "".obs;
  final isLocationReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeDate();
    _initializeRepository();
    _loadStorageLocations();
    _loadStorageFromContext();
    _preFetchLocation();
    _checkRouteParameters();

    tinggiTeraSpbController.addListener(_calculateTerraDiff);
    tinggiTeraSoundingController.addListener(_calculateTerraDiff);

    selisihTinggiTeraController.addListener(_calculateVolumeTerraDiff);
    nilaiKepekaanController.addListener(_calculateVolumeTerraDiff);

    ever(selectedStorage, (val) {
      if (val != 'Pilih Lokasi Storage') calculateDisplayData(val);
    });
  }

  void _initializeDate() {
    final now = DateTime.now();
    dateInputController.text = DateFormat('dd/MM/yyyy', 'id_ID').format(now);
    String day = DateFormat('EEEE', 'id_ID').format(now);
    dayInputController.text = day.isNotEmpty ? day[0].toUpperCase() + day.substring(1) : day;
  }

  Future<void> _initializeRepository() async {
    final auth = await _loginService.getAuthOrLoad();
    if (auth != null) {
      _activeUsername = auth.user.username;
      _repository = PenerimaanSebelumRepository(_activeUsername);
      await _repository.initializeDataBox(_activeUsername);
      _loadInitialData();
    } else {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  void _loadStorageLocations() {
    storageLocations.clear();

    final cachedTanks = _fuelDataService.getApiManualTanks();

    debugPrint("Cached Tanks: $cachedTanks");

    final Set<String> uniqueStorages = {};

    for (var tank in cachedTanks) {
      final storageName = tank.masterStorage?.namaStorage;
      if (storageName != null && storageName.isNotEmpty) {
        uniqueStorages.add(storageName);
      }
    }

    if (uniqueStorages.isNotEmpty) {
      storageLocations.assignAll(uniqueStorages.toList());
    } else {
      storageLocations.assignAll(['Pilih Lokasi Storage']);
    }
  }

  void _loadStorageFromContext() {
    String targetStorageCode = '';

    if (Get.arguments != null) {
      targetStorageCode = Get.arguments['storage_code'] ?? '';
    }

    if (targetStorageCode.isEmpty || targetStorageCode == 'Pilih Lokasi Storage') {
      targetStorageCode = _fuelDataService.getLastSelectedStorageCode();
    }

    if (targetStorageCode.isNotEmpty) {
      selectedStorage.value = targetStorageCode;
    } else {
      selectedStorage.value = storageLocations.first;
    }
  }

  Future<void> _preFetchLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();

    if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
      try {
        lastKnownPosition.value = await Geolocator.getLastKnownPosition();
        if (lastKnownPosition.value == null) {
          lastKnownPosition.value = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.low, timeLimit: const Duration(seconds: 5));
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

  Future<void> _loadInitialData() async {
    final storages = _repository.getAvailableStorages();
    storageLocations.assignAll(storages);

    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      if (args.containsKey('storage')) {
        selectedStorage.value = args['storage'];
      }
    }

    if (storageLocations.isNotEmpty) {
      if (selectedStorage.value == 'Pilih Lokasi Storage') {
        selectedStorage.value = storageLocations.first;
      }
      calculateDisplayData(selectedStorage.value);
    }

    await _checkAndRestoreDraft();
  }

  void _calculateTerraDiff() {
    double spb = _parseSafeDouble(tinggiTeraSpbController.text);
    double check = _parseSafeDouble(tinggiTeraSoundingController.text);
    double diff = spb - check;

    selisihTinggiTeraController.text = TextConvertHelper().formatNumber(diff);
    _calculateVolumeTerraDiff();
  }

  void _calculateVolumeTerraDiff() {
    double diffHeight = _parseSafeDouble(selisihTinggiTeraController.text);
    double sensitivity = _parseSafeDouble(nilaiKepekaanController.text);

    if (sensitivity == 0) {
      if (selisihVolumeTeraController.text != "0") {
        selisihVolumeTeraController.text = "0";
      }
      return;
    }

    double volumeDiff = diffHeight / sensitivity;
    String result = TextConvertHelper().formatNumber(volumeDiff);

    if (selisihVolumeTeraController.text != result) {
      selisihVolumeTeraController.text = result;
    }
  }

  double _parseSafeDouble(String text) {
    if (text.isEmpty) return 0.0;

    if (text.contains('.') && !text.contains(',')) {
      if ('.'.allMatches(text).length == 1) {
        return double.tryParse(text) ?? 0.0;
      }
    }

    String clean = text.replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(clean) ?? 0.0;
  }

  void setActivePhotoLabel(String label) {
    activePhotoLabel.value = label;
  }

  Future<void> _checkAndRestoreDraft() async {
    if (_activeUsername.isEmpty) return;
    final draft = await _repository.getDraft();

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
          onSecondaryPressed: () async {
            await _repository.deleteDraft();
            Get.back();
          },
        ),
        barrierDismissible: false,
      );
    }
  }

  void calculateDisplayData(String storageName) {
    String storageCode = storageName.split(' - ').length > 1
        ? storageName.split(' - ').last
        : storageName;

    final activeTanks = _repository.getLocalSensorData(storageCode);

    activeTanks.sort((a, b) {
      String codeA = a.masterSolarTank?.kodeTank ?? '';
      String codeB = b.masterSolarTank?.kodeTank ?? '';
      return codeA.compareTo(codeB);
    });

    double totalVol = 0.0;
    List<Map<String, String>> tempList = [];

    for (var tank in activeTanks) {
      String tankCode = tank.masterSolarTank?.kodeTank ?? 'UNK';
      final manualState = _repository.getManualTankInput(tankCode);
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

  void _restoreFormData(PenerimaanSebelumModel draft) {
    String formatVal(double? val) => val == null ? "" : TextConvertHelper().formatNumber(val);

    noPoController.text = draft.purchNo ?? "";
    noDoController.text = draft.vendorSpb ?? "";
    jumlahLtrController.text = formatVal(draft.volumeVendor);
    densityObsController.text = draft.densityVendor?.toStringAsFixed(4) ?? "";
    temperatureObsController.text = draft.tempVendor?.toStringAsFixed(2) ?? "";
    noPolisiController.text = draft.nopolVendor ?? "";
    namaSopirController.text = draft.supirVendor ?? "";
    kapasitasTangkiController.text = formatVal(draft.kapasitasVendor);
    tinggiTeraSpbController.text = formatVal(draft.terraVendor);
    tinggiTeraSoundingController.text = formatVal(draft.terraCheck);
    selisihTinggiTeraController.text = formatVal(draft.terraVar);
    nilaiKepekaanController.text = draft.tangkiPeka ?? "";
    selisihVolumeTeraController.text = formatVal(draft.selisihVolumeTerra);
    segelTangkiAtasController.text = draft.segelTangkiAtas ?? "";
    segelTangkiBawahController.text = draft.segelTangkiBawah ?? "";
    if (draft.segelKondisi != null) kondisiSegelSelected.value = draft.segelKondisi!;

    if (draft.pathFotoDoc != null) _restorePhoto(0, draft.pathFotoDoc!);
    if (draft.pathFotoDepan != null) _restorePhoto(1, draft.pathFotoDepan!);
    if (draft.pathFotoSamping != null) _restorePhoto(2, draft.pathFotoSamping!);

    if (draft.storageCode != null && storageLocations.contains(draft.storageCode)) {
      selectedStorage.value = draft.storageCode!;
    }
    _calculateTerraDiff();
    _calculateVolumeTerraDiff();
  }

  void _restorePhoto(int index, String path) {
    if (File(path).existsSync()) {
      photoSlots[index] = CapturedImageDetail(
          tempPath: path,
          fileName: p.basename(path),
          latitude: 0, longitude: 0
      );
    }
  }

  void proceedToTankMeasurement() {
    if (!_validateCurrentStep()) return;

    final Map<String, dynamic> administrativeData = {
      'purch_no': noPoController.text,
      'vendor_spb': noDoController.text,
      'volume_vendor': TextConvertHelper().cleanNumber(jumlahLtrController.text),
      'density_vendor': TextConvertHelper().parseToDouble(densityObsController.text),
      'temp_vendor': TextConvertHelper().parseToDouble(temperatureObsController.text),
      'nopol_vendor': noPolisiController.text.toUpperCase(),
      'supir_vendor': namaSopirController.text.toUpperCase(),
      'kapasitas_vendor': TextConvertHelper().cleanNumber(kapasitasTangkiController.text),
      'terra_vendor': TextConvertHelper().cleanNumber(tinggiTeraSpbController.text),
      'terra_check': TextConvertHelper().cleanNumber(tinggiTeraSoundingController.text),
      'terra_var': TextConvertHelper().cleanNumber(selisihTinggiTeraController.text),
      'tangki_peka': nilaiKepekaanController.text,
      'selisih_vol_tera': TextConvertHelper().cleanNumber(selisihVolumeTeraController.text),
      'segel_tangki_atas': segelTangkiAtasController.text,
      'segel_tangki_bawah': segelTangkiBawahController.text,
      'segel_kondisi': kondisiSegelSelected.value,
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
      if (photoSlots.any((element) => element == null)) errorMessage = "Mohon lengkapi 3 foto (Dokumen, Depan, Samping)";
    } else if (currentPage.value == 2) {
      if (tinggiTeraSpbController.text.isEmpty) errorMessage = "Tinggi Tera SPB harus diisi";
      else if (tinggiTeraSoundingController.text.isEmpty) errorMessage = "Tinggi Zounding harus diisi";
      else if (nilaiKepekaanController.text.isEmpty) errorMessage = "Nilai Kapelkaan harus diisi";
      else if (segelTangkiAtasController.text.isEmpty) errorMessage = "Segel Atas harus diisi";
      else if (segelTangkiBawahController.text.isEmpty) errorMessage = "Segel Bawah harus diisi";
    }

    if (errorMessage.isNotEmpty) {
      CustomSnackbar.show(
        title: "Data Belum Lengkap",
        message: errorMessage,
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return false;
    }
    return true;
  }

  Future<void> takeSpecificPhoto(int index) async {
    try {
      isTakingPhoto.value = true;

      String labelText = "";
      if (index == 0) labelText = "Foto Dokumen SPB";
      else if (index == 1) labelText = "Foto Tampak Depan Mobil";
      else if (index == 2) labelText = "Foto Tampak Samping Mobil";

      final String? resultPath = await Get.to(() => CustomCameraView(
        label: labelText,
      ));

      if (resultPath == null) {
        isTakingPhoto.value = false;
        return;
      }

      File? compressedFile = await _compressImage(File(resultPath));
      if (compressedFile == null) return;

      final currentLat = lastKnownPosition.value?.latitude ?? 0;
      final currentLong = lastKnownPosition.value?.longitude ?? 0;

      photoSlots[index] = CapturedImageDetail(
        tempPath: compressedFile.path,
        latitude: currentLat,
        longitude: currentLong,
        fileName: p.basename(compressedFile.path),
      );
    } catch (e) {
      if (kDebugMode) print('Error saat takePhoto: $e');
      CustomSnackbar.show(
        title: "Gagal Mengambil Foto",
        message: "Terjadi error: $e",
        backgroundColor: AppColors.error,
        textColor: AppColors.white,
      );
    } finally {
      isTakingPhoto.value = false;
    }
  }

  Future<File?> _compressImage(File file) async {
    try {
      final lastIndex = file.path.lastIndexOf(RegExp(r'.jp'));
      final splitted = file.path.substring(0, (lastIndex));
      final outPath = "${splitted}_compressed.jpg";
      final outCheck = File(outPath);
      if (await outCheck.exists()) await outCheck.delete();

      var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, outPath,
        quality: 60, minWidth: 1024, minHeight: 1024,
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
      try { File(photoSlots[index]!.tempPath).deleteSync(); } catch (_) {}
      photoSlots[index] = null;
    }
  }

  void goToNextPage() async {
    String currentStorage = _getStorageCode(selectedStorage.value);

    debugPrint("Storage Choose: $currentStorage");

    if (currentStorage == 'Pilih Lokasi Storage' || currentStorage.isEmpty) {
      CustomSnackbar.show(
        title: 'Mohon Maaf',
        message: 'Silahkan pilih lokasi storage yang valid di halaman Home terlebih dahulu.',
        backgroundColor: AppColors.alertSoftRed,
        textColor: AppColors.white,
      );
      return;
    }

    if (!_validateCurrentStep()) return;
    if (currentPage.value < 2) {
      pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.easeIn);
    } else {
      proceedToTankMeasurement();
    }
  }

  void onPageChanged(int index) { currentPage.value = index; }

  String _getStorageCode(String storageString) {
    final parts = storageString.split(' - ');
    if (parts.length > 1) return parts.last.trim();
    return storageString.trim();
  }
  
  @override
  void onClose() {
    tinggiTeraSpbController.removeListener(_calculateTerraDiff);
    tinggiTeraSoundingController.removeListener(_calculateTerraDiff);

    selisihTinggiTeraController.removeListener(_calculateVolumeTerraDiff);
    nilaiKepekaanController.removeListener(_calculateVolumeTerraDiff);

    pageController.dispose();
    dateInputController.dispose(); dayInputController.dispose(); noPoController.dispose();
    noDoController.dispose(); jumlahLtrController.dispose(); densityObsController.dispose();
    temperatureObsController.dispose(); noPolisiController.dispose(); namaSopirController.dispose();
    kapasitasTangkiController.dispose(); tinggiTeraSpbController.dispose(); tinggiTeraSoundingController.dispose();
    selisihTinggiTeraController.dispose(); selisihVolumeTeraController.dispose(); nilaiKepekaanController.dispose(); segelTangkiAtasController.dispose();
    segelTangkiBawahController.dispose();
    super.onClose();
  }
}