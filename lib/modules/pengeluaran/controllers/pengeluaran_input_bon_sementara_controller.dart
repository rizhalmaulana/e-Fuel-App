import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../configs/app_colors.dart';
import '../../../datas/models/bon_sementara/bon_sementara_model.dart';
import '../../auth/services/login_service.dart';
import '../services/bon_sementara_local_service.dart';

class PengeluaranInputBonSementaraController extends GetxController {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final LoginService _loginService = Get.find<LoginService>();
  final BonSementaraLocalService _localService = BonSementaraLocalService();

  var masterList = <BonSementaraModel>[].obs;
  var filteredMasterList = <BonSementaraModel>[].obs;
  final searchTextC = TextEditingController();

  var isLoading = false.obs;
  var selectedUnitCode = 'E000'.obs;
  var totalVolume = 0.0.obs;
  var totalQty = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserUnitCode();
    initDataFlow();
  }

  Future<void> onRefresh() async {
    await initDataFlow();
    Get.snackbar(
      "Berhasil",
      "Data telah diperbarui",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primaryOrange.withOpacity(0.1),
      colorText: AppColors.primaryOrange,
    );
  }

  Future<void> initDataFlow() async {
    isLoading.value = true;
    try {
      await loadInitialData();
      await syncFromRealtimeDatabase();
    } finally {
      isLoading.value = false;
    }
  }

  void _loadUserUnitCode() {
    final authData = _loginService.getCurrentAuth();
    if (authData != null) {
      selectedUnitCode.value = authData.currentKodeUnit ?? 'Unknown';
    }
  }

  void searchBon(String query) {
    if (query.isEmpty) {
      filteredMasterList.assignAll(masterList);
    } else {
      var result = masterList.where((item) {
        final io = (item.internalOrder ?? "").toLowerCase();
        final unit = (item.namaUnit ?? "").toLowerCase();
        final search = query.toLowerCase();
        return io.contains(search) || unit.contains(search);
      }).toList();
      filteredMasterList.assignAll(result);
    }
  }

  void _calculateTotals() {
    totalQty.value = filteredMasterList.length;
    totalVolume.value = filteredMasterList.fold(0.0, (sum, item) => sum + (item.liter ?? 0.0));
  }

  Future<void> loadInitialData() async {
    var localData = await _localService.getMasterList();

    if (localData.isEmpty) {
      List<dynamic> rawJson = [
        {
          "No": 1,
          "Internal Order": "E031ABA903",
          "Nama Unit": "MDC",
          "Internal Order DWH": "E031ABA903",
          "Deskripsi Unit": "MINI DUMP CRAWLER KAP.4 03(AGI)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 2,
          "Internal Order": "E031ABE901",
          "Nama Unit": "Exca PC 50-01",
          "Internal Order DWH": "E031ABE901",
          "Deskripsi Unit": "MINI EXCA KUBOTA U-50 01(AGI)",
          "No Polisi": "",
          "Ket": 1,
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "5,5"
        },
        {
          "No": 3,
          "Internal Order": "E031ABE902",
          "Nama Unit": "Exca Long Arm 01",
          "Internal Order DWH": "E031ABE902",
          "Deskripsi Unit": "EXCAVATOR CAT 320GX 02 (AGI)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 6962,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "13,2"
        },
        {
          "No": 4,
          "Internal Order": "E031ABE904",
          "Nama Unit": "Exca 313",
          "Internal Order DWH": "E031ABE904",
          "Deskripsi Unit": "EXCAVATOR PC130CAT313 D2LGP 04(AGI)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "12,5"
        },
        {
          "No": 5,
          "Internal Order": "E031ABE905",
          "Nama Unit": "Exca Long Arm 02",
          "Internal Order DWH": "E031ABE905",
          "Deskripsi Unit": "EXCAVATOR CAT 320GC LONG ARM 05(AGI)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 2772,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "13,2"
        },
        {
          "No": 6,
          "Internal Order": "E031ABE906",
          "Nama Unit": "Exca PC 50-02",
          "Internal Order DWH": "E031ABE906",
          "Deskripsi Unit": "MINI EXCAVATOR U50-S 06(AGI)",
          "No Polisi": "",
          "Ket": 2,
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 2733,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "5,5"
        },
        {
          "No": 7,
          "Internal Order": "E031ABE907",
          "Nama Unit": "Exca PC 200-01",
          "Internal Order DWH": "E031ABE907",
          "Deskripsi Unit": "CATERPILLAR  EXCAVATOR",
          "No Polisi": "",
          "Ket": 1,
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 944,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 8,
          "Internal Order": "E031ABE908",
          "Nama Unit": "Exca PC 200-02",
          "Internal Order DWH": "E031ABE908",
          "Deskripsi Unit": "CATERPILLAR  EXCAVATOR",
          "No Polisi": "",
          "Ket": 2,
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 10317,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 9,
          "Internal Order": "E031ABG901",
          "Nama Unit": "Grader",
          "Internal Order DWH": "E031ABG901",
          "Deskripsi Unit": "ROAD GRADER CAT 120K 01(AGI)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "AB",
          "Satuan": "LTR/HM",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 8138,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "12,8"
        },
        {
          "No": 10,
          "Internal Order": "E031KRD901",
          "Nama Unit": "DT 01",
          "Internal Order DWH": "E031KRD901",
          "Deskripsi Unit": "DT MTSBSH FE SHD-X 01 KT8833RX(AGI)",
          "No Polisi": "KT 8833 RX",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 132220,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "3,7"
        },
        {
          "No": 11,
          "Internal Order": "E031KRD902",
          "Nama Unit": "DT 02",
          "Internal Order DWH": "E031KRD902",
          "Deskripsi Unit": "DT MTSBSH FE SHD-X  02 KT8860RX(AGI)",
          "No Polisi": "KT 8860 RX",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 129557,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "3,5"
        },
        {
          "No": 12,
          "Internal Order": "E031KRD903",
          "Nama Unit": "DT 03",
          "Internal Order DWH": "E031KRD903",
          "Deskripsi Unit": "DT MTSBSH FE SHD-X  03 KT8862RX(AGI)",
          "No Polisi": "KT 8862 RX",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 127343,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": 4
        },
        {
          "No": 13,
          "Internal Order": "E031KRD904",
          "Nama Unit": "DT 04",
          "Internal Order DWH": "E031KRD904",
          "Deskripsi Unit": "DT MTSBSH FE-SHDX 04 B9224SDE(AGI)",
          "No Polisi": "B 9224 SDE",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 100021,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "3,3"
        },
        {
          "No": 14,
          "Internal Order": "E031KRL902",
          "Nama Unit": "DC Askep",
          "Internal Order DWH": "E031KRL902",
          "Deskripsi Unit": "TRITON DC HDX-L 4X4 MT 02 B9264SBM(AGI)",
          "No Polisi": "B 9264 SBM",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 22013,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": 8
        },
        {
          "No": 15,
          "Internal Order": "E031KRL903",
          "Nama Unit": "DC PK",
          "Internal Order DWH": "E031KRL903",
          "Deskripsi Unit": "MITSUBISHI B 9728 SBM DOUBLE CABIN",
          "No Polisi": "B 9728 SBM",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 3439,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "7,8"
        },
        {
          "No": 16,
          "Internal Order": "E031KRLX01",
          "Nama Unit": "DC Konsultan WM",
          "Internal Order DWH": "E031KRLX01",
          "Deskripsi Unit": "IO External DC 01 (PT MAS)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 109895,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 17,
          "Internal Order": "E031KRL905",
          "Nama Unit": "DC Askep WM",
          "Internal Order DWH": "E031KRL905",
          "Deskripsi Unit": "MITSUBISHI B 9257 SBF DOUBLE CABIN",
          "No Polisi": "B 9257 SBF",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 116525,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "7,5"
        },
        {
          "No": 18,
          "Internal Order": "E031KRT901",
          "Nama Unit": "TUS",
          "Internal Order DWH": "E031KRT901",
          "Deskripsi Unit": "ISUZU B 9680 SFA TRUK TANGKI",
          "No Polisi": "B 9680 SFA",
          "Ket": "",
          "Note": "",
          "Tipe": "KD",
          "Satuan": "KM/LTR",
          "OPR": "",
          "OPL": "",
          "HM/KM Awal": 4181,
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "3,7"
        },
        {
          "No": 19,
          "Internal Order": "E031MSP003",
          "Nama Unit": "GST 85 KVA Afd 3",
          "Internal Order DWH": "E031MSP003",
          "Deskripsi Unit": "GENSET MITSUBISHI 6D16 85KVA 03 (AFD05)",
          "No Polisi": "",
          "Ket": "GS Besar (Emplasmen Utama)",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "9 Jam/hari",
          "OPL": "+2",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 20,
          "Internal Order": "E031MSP903",
          "Nama Unit": "GST 50 KVA Afd 1",
          "Internal Order DWH": "E031MSP903",
          "Deskripsi Unit": "GENSET 50KVA YTG65TLN 03 BJSP(EU)",
          "No Polisi": "",
          "Ket": "GS Besar (Emplasmen Utama)",
          "Note": "",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "9 Jam/hari",
          "OPL": "+2",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "6,8"
        },
        {
          "No": 21,
          "Internal Order": "E031MSP904",
          "Nama Unit": "GST 33 KVA Afd 2",
          "Internal Order DWH": "E031MSP904",
          "Deskripsi Unit": "GENSET YANMAR 50 KVA 04 (BJS)",
          "No Polisi": "",
          "Ket": "GS Afdeling",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "12 jam/hari",
          "OPL": -2,
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 22,
          "Internal Order": "E031MSP905",
          "Nama Unit": "GST 33 KVA Afd 1",
          "Internal Order DWH": "E031MSP905",
          "Deskripsi Unit": "GENSET 33 KVA 05(BJS)",
          "No Polisi": "",
          "Ket": "GS Kecil",
          "Note": "",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "12 jam/hari",
          "OPL": -2,
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "2,5"
        },
        {
          "No": 23,
          "Internal Order": "E031MSP906",
          "Nama Unit": "GST 15 KVA Afd 3",
          "Internal Order DWH": "E031MSP906",
          "Deskripsi Unit": "GENSET YANMAR 33 KVA 06(BJS)",
          "No Polisi": "",
          "Ket": "GS Afdeling (Kecil)",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "7 jam/hari",
          "OPL": -2,
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 24,
          "Internal Order": "E031MSW001",
          "Nama Unit": "WP 01 Afd 1",
          "Internal Order DWH": "E031MSW001",
          "Deskripsi Unit": "WATER PUMP YANMAR TS230 01 (AFD01)",
          "No Polisi": "",
          "Ket": "",
          "Note": "",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "7 jam/hari",
          "OPL": "+2",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": "1,5"
        },
        {
          "No": 25,
          "Internal Order": "E031MSW002",
          "Nama Unit": "WP 02 Afd 3",
          "Internal Order DWH": "E031MSW002",
          "Deskripsi Unit": "WATER PUMP YANMAR TS230 02 (AFD05)",
          "No Polisi": "",
          "Ket": "",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "7 jam/hari",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 26,
          "Internal Order": "E031MSW004",
          "Nama Unit": "WP Bibitan",
          "Internal Order DWH": "E031MSW004",
          "Deskripsi Unit": "WATER PUMP MITSUBISHI 4D33 04",
          "No Polisi": "",
          "Ket": "",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "7 jam/hari",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        },
        {
          "No": 27,
          "Internal Order": "E031MSW005",
          "Nama Unit": "WP Pioneer WM",
          "Internal Order DWH": "E031MSW005",
          "Deskripsi Unit": "PIONEER PUMP PP66S12 730M3 05",
          "No Polisi": "",
          "Ket": "",
          "Note": "bon terpisah (3 hari sekali langsung BPB)",
          "Tipe": "GS",
          "Satuan": "LTR/JAM",
          "OPR": "7 jam/hari",
          "OPL": "",
          "HM/KM Awal": "",
          "HM/KM Akhir": "",
          "Tanggal Awal": "",
          "Tanggal Akhir": "",
          "Ratio": ""
        }
      ];

      masterList.value = rawJson.map((e) => BonSementaraModel.fromJson(e)).toList();
      await _localService.saveMasterList(masterList);
    } else {
      masterList.value = localData;
    }

    filteredMasterList.assignAll(masterList);
    _calculateTotals();
  }

  Future<void> syncFromRealtimeDatabase() async {
    try {
      final results = await Future.wait([
        _dbRef.child('InitiateKM').get(),
        _dbRef.child('InitiateRatio').get(),
      ]);

      final DataSnapshot kmSnapshot = results[0];
      final DataSnapshot ratioSnapshot = results[1];

      bool isChanged = false;

      for (var item in masterList) {
        String io = item.internalOrder ?? "";
        if (io.isEmpty) continue;

        if (kmSnapshot.hasChild(io)) {
          final data = Map<dynamic, dynamic>.from(kmSnapshot.child(io).value as Map);
          item.hmKmAwal = data['KMAwal'];
          item.dateAwal = data['DateAwal']?.toString();
          isChanged = true;
        }

        if (ratioSnapshot.hasChild(io)) {
          final data = Map<dynamic, dynamic>.from(ratioSnapshot.child(io).value as Map);
          item.ratio = data['Ratio']?.toString();
          isChanged = true;
        }
      }

      if (isChanged) {
        masterList.refresh();
        filteredMasterList.assignAll(masterList);

        await _localService.saveMasterList(masterList);
        _calculateTotals();
        print("✅ Sinkronisasi Realtime Database Berhasil");
      }
    } catch (e) {
      print("❌ Gagal Sinkronisasi Realtime Database: $e");
    }
  }

  void updateDataBon(String io, double kmAkhir, double liter, String ratio, {String? dateAkhir, String? operationHoliday}) async {
    int index = masterList.indexWhere((element) => element.internalOrder == io);
    if (index != -1) {
      // 1. Update data pada model lokal
      masterList[index].hmKmAkhir = kmAkhir;
      masterList[index].dateAkhir = dateAkhir;
      masterList[index].liter = liter;
      masterList[index].ratio = ratio;
      masterList[index].opl = operationHoliday;

      // 2. Refresh UI secara instan (Header & Table)
      masterList.refresh();
      filteredMasterList.assignAll(masterList);
      _calculateTotals(); // Mengupdate total liter dan qty di header

      // 3. Simpan permanen ke Hive
      await _localService.updateItem(masterList[index]);

      // 4. Proses sinkronisasi ke Firebase dengan notifikasi Snackbar
      _syncWithFeedback(masterList[index], dateAkhir, operationHoliday);
    }
  }

  Future<void> _syncWithFeedback(BonSementaraModel item, String? dateAkhir, String? operationHoliday) async {
    Get.rawSnackbar(
      message: "Sedang mensinkronkan data ke cloud...",
      showProgressIndicator: true,
      isDismissible: false,
      duration: const Duration(seconds: 2),
      backgroundColor: AppColors.secondaryText.withOpacity(0.8),
      snackPosition: SnackPosition.BOTTOM,
    );

    try {
      await _updateFirebaseAfterSave(item, dateAkhir, operationHoliday);

      Get.snackbar(
        "Berhasil",
        "Data ${item.namaUnit} telah tersinkronisasi",
        backgroundColor: AppColors.primaryOrange.withOpacity(0.9),
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        "Koneksi Bermasalah",
        "Data tersimpan lokal, namun gagal kirim ke cloud.",
        backgroundColor: AppColors.alertSoftRed,
        colorText: AppColors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  Future<void> _updateFirebaseAfterSave(BonSementaraModel item,
      String? dateAkhir, String? operationHoliday) async {
    try {
      final io = item.internalOrder!;

      // Update Node InitiateKM
      Map<String, dynamic> kmUpdate = {};
      if (item.tipe == 'GS') {
        kmUpdate['DateAwal'] = dateAkhir; // DateAwal diisi DateAkhir
      } else {
        kmUpdate['KMAwal'] = item.hmKmAwal;
        kmUpdate['DateAwal'] = DateTime.now().toIso8601String().split('T')[0];
      }
      await _dbRef.child('InitiateKM').child(io).update(kmUpdate);

      // Update Node InitiateRatio
      Map<String, dynamic> ratioUpdate = {
        'Ratio': item.ratio,
      };

      // Jika ada input Operasional Libur, simpan ke OperationHoliday di Firebase
      if (operationHoliday != null && operationHoliday.isNotEmpty) {
        ratioUpdate['OperationHoliday'] = operationHoliday;
      }

      await _dbRef.child('InitiateRatio').child(io).update(ratioUpdate);

      print("✅ Firebase Sync Success for IO: $io");
    } catch (e) {
      print("❌ Firebase Sync Failed: $e");
    }
  }
}
