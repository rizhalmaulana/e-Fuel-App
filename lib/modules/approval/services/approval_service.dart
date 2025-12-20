import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:e_fuel/modules/transactions/pengeluaran/services/pengeluaran_api_service.dart';
import 'package:get/get.dart';
import '../../../datas/constant/url_api_static.dart';
import '../../../datas/models/approval/transaction_approval_model.dart';
import '../../auth/services/login_service.dart';

class ApprovalService {
  final Dio _dio = Dio();
  final LoginService _loginService = Get.find<LoginService>();
  final PenerimaanApiService _penerimaanApiService = PenerimaanApiService();

  ApprovalService() {
    _dio.options.baseUrl = UrlApiStatic.API_END_POINT;
    _dio.options.connectTimeout = const Duration(seconds: 20);
  }

  Future<List<TransactionApprovalModel>> getApprovalList({
    String? levelApproval,
    required String kodeUnit,
    String? statusApprove,
    String? transactionType,
  }) async {
    // ... (kode lama tetap sama)
    try {
      final auth = _loginService.getCurrentAuth();
      final response = await _dio.get(
        UrlApiStatic.API_GET_TRANSACTION_APPROVAL_LIST,
        queryParameters: {
          'level_approval': levelApproval,
          'kode_unit': kodeUnit,
          'status_approve': statusApprove,
          'transaction_type': transactionType,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = response.data;
        return data.map((e) => TransactionApprovalModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print("⚠️ Gagal fetch approval list: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>?> getInboundOpenDetail(String noDoc) async {
    try {
      final auth = _loginService.getCurrentAuth();

      String url = UrlApiStatic.API_GET_INBOUND_OPEN_DETAIL.replaceAll('{no_doc}', noDoc);
      if (!UrlApiStatic.API_GET_INBOUND_OPEN_DETAIL.contains('{no_doc}')) {
        url = "${UrlApiStatic.API_GET_INBOUND_OPEN_DETAIL}/$noDoc";
      }

      final response = await _dio.get(
        url,
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("Error fetching detail inbound: $e");
      return null;
    }
  }

  Future<bool> submitPenerimaanApprovalDecision({
    required String noDoc,
    required String levelApproval,
    required String status,
    required String note,
    File? signature,
  }) async {
    try {
      await _penerimaanApiService.updateStatusTransactionApproval(
        noDoc: noDoc,
        levelApproval: levelApproval,
        statusApprove: status,
        catatan: note,
        isSign: signature != null,
        isPartnerSign: false,
      );

      if (status == 'APPROVED' && signature != null) {
        await _penerimaanApiService.uploadSignatureTransactionApproval(
            noDoc: noDoc,
            levelApproval: levelApproval,
            imageSign1: signature,
            imageSign2: signature
        );
      }

      return true;
    } catch (e) {
      print("Error submit approval: $e");
      return false;
    }
  }
}