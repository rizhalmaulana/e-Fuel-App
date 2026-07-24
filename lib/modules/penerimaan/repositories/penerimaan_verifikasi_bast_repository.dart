import 'dart:convert';
import 'dart:io';

import 'package:e_fuel/datas/models/approval/konfigurasi_approval_model.dart';
import 'package:e_fuel/datas/models/transactions/penerimaan/transaction_model.dart';
import 'package:e_fuel/modules/fuel/services/fuel_data_service.dart';
import 'package:e_fuel/modules/fuel/services/master_data_service.dart';
import 'package:e_fuel/modules/transactions/outstanding_service.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:signature/signature.dart';
import 'dart:typed_data';

import '../services/draft_penerimaan_service.dart';

class PenerimaanVerifikasiBastRepository {
  final FuelDataService _fuelDataService = Get.find<FuelDataService>();
  final PenerimaanApiService _apiService = PenerimaanApiService();
  final MasterDataService _masterDataService = MasterDataService();

  late OutstandingService _outstandingService;
  late DraftPenerimaanService _draftService;

  PenerimaanVerifikasiBastRepository(String username) {
    _outstandingService = OutstandingService(username);
    _draftService = DraftPenerimaanService(username);
  }

  // --- CALIBRATION ---

  Future<double?> getLiterFromCalibration(int capacity, double heightMm) async {
    return await _masterDataService.getLiterFromCalibrationService(
        kapasitas: capacity,
        tinggiMm: heightMm
    );
  }

  // --- TRANSACTION & DRAFT ---

  Future<TransactionModel?> getTransaction(String noBast) async {
    return await _outstandingService.getTransactionByNoBastService(noBast);
  }

  Future<Map<dynamic, dynamic>?> getDraftSesudah(String noBast) async {
    return await _draftService.getDraftSesudahService(noBast);
  }

  Future<void> updateLocalTransactionStatus(String noBast, String status, {String? levelApproval, int? stepApproval}) async {
    await _outstandingService.updateStatusService(
        noBast,
        status,
        levelApproval: levelApproval,
        stepApproval: stepApproval
    );

    var transaction = await _outstandingService.getTransactionByNoBastService(noBast);
    if (transaction != null) {
      transaction.status = status;
      await transaction.save();
    }
  }

  Future<void> saveManualTankInput({required String tankCode, required double volume, required double height}) async {
    await _fuelDataService.saveManualTankInputService(
        tankCode: tankCode,
        volume: volume,
        height: height
    );
  }

  // --- API OPERATIONS ---

  Future<List<KonfigurasiApprovalModel>> getKonfigurasiApproval({
    required String transactionType,
    required String kodeUnit,
    required bool statusActive,
  }) async {
    return await _apiService.getKonfigurasiApprovalService(
      transactionType: transactionType,
      kodeUnit: kodeUnit,
      statusActive: statusActive,
    );
  }

  Future<void> createInboundTank(Map<String, dynamic> payload) async {
    await _apiService.createInboundTankService(payload);
  }

  Future<void> createTransactionApproval({
    required String noDoc,
    required String kodeUnit,
    required String transactionType,
  }) async {
    await _apiService.createTransactionApprovalService(
      noDoc: noDoc,
      kodeUnit: kodeUnit,
      transactionType: transactionType,
    );
  }

  Future<void> updateStatusTransactionApproval({
    required String noDoc,
    required String levelApproval,
    required String statusApprove,
    required String catatan,
    required bool isSign,
    required bool isPartnerSign,
  }) async {
    await _apiService.updateStatusTransactionApprovalService(
      noDoc: noDoc,
      levelApproval: levelApproval,
      statusApprove: statusApprove,
      catatan: catatan,
      isSign: isSign,
      isPartnerSign: isPartnerSign,
    );
  }

  Future<void> uploadSignatureTransactionApproval({
    required String noDoc,
    required String levelApproval,
    required File imageSign1,
    required File imageSign2,
  }) async {
    await _apiService.uploadSignatureTransactionApprovalService(
      noDoc: noDoc,
      levelApproval: levelApproval,
      imageSign1: imageSign1,
      imageSign2: imageSign2,
    );
  }

  Future<void> uploadSignatureSecurity({
    required String noDoc,
    required File imageSign3,
    required String securityName
  }) async {
    await _apiService.uploadSignatureSecurityService(
      noDoc: noDoc,
      imageSign3: imageSign3,
      securityName: securityName
    );
  }

  // --- UTILS ---

  Future<File?> saveSignatureToFile(SignatureController controller, String fileName) async {
    if (controller.isEmpty) return null;

    final Uint8List? data = await controller.toPngBytes();
    if (data == null) return null;

    final Directory dir = await getApplicationDocumentsDirectory();
    final String fullPath = p.join(dir.path, fileName);

    final File file = File(fullPath);
    await file.writeAsBytes(data);
    return file;
  }

  // Helper parsing JSON Manual/IoT dari Hive
  Map<String, double> parseDetailJson(String? jsonString, String volKey, String heightKey) {
    Map<String, double> volMap = {};
    if (jsonString != null) {
      List<dynamic> list = jsonDecode(jsonString);
      for (var item in list) {
        // Handle field name variation
        String code = item['tank_code'].toString().replaceAll(' ', '_');
        double vol = ((item[volKey] ?? item['volume']) as num).toDouble();
        volMap[code] = vol;
      }
    }
    return volMap;
  }

  Map<String, double> parseDetailJsonHeight(String? jsonString, String heightKey) {
    Map<String, double> hMap = {};
    if (jsonString != null) {
      List<dynamic> list = jsonDecode(jsonString);
      for (var item in list) {
        String code = item['tank_code'].toString().replaceAll(' ', '_');
        double h = ((item[heightKey] ?? item['height']) as num).toDouble();
        hMap[code] = h;
      }
    }
    return hMap;
  }
}