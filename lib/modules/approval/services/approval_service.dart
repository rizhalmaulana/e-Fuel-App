import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../datas/constant/url_api_static.dart';
import '../../../datas/models/approval/transaction_approval_model.dart';
import '../../../datas/network/api_client_network.dart';
import '../../auth/services/login_service.dart';

class ApprovalService {
  final LoginService _loginService = Get.find<LoginService>();
  final ApiClientNetwork _apiClient = ApiClientNetwork();
  final PenerimaanApiService _penerimaanApiService = PenerimaanApiService();

  Future<List<TransactionApprovalModel>> getApprovalList({
    String? levelApproval,
    required String kodeUnit,
    String? statusApprove,
    String? transactionType,
    String? noBast,
  }) async {
    try {
      final auth = _loginService.getCurrentAuth();
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_GET_TRANSACTION_APPROVAL_LIST,
        queryParameters: {
          'kode_unit': kodeUnit,
          if (statusApprove != null) 'status_approve': statusApprove,
          if (transactionType != null) 'transaction_type': transactionType,
          if (noBast != null) 'no_bast': noBast, // 🟢 TAMBAHAN BARU
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
      _logError("getApprovalList", e);
      return [];
    }
  }

  Future<String?> downloadPdfDocument(String noDoc, {bool isEbpb = false}) async {
    try {
      final auth = _loginService.getCurrentAuth();
      
      String endpoint = isEbpb 
          ? UrlApiStatic.API_EXPORT_EBPB_PDF_DOC 
          : UrlApiStatic.API_EXPORT_PDF_DOC;

      String url = UrlApiStatic.API_END_POINT + endpoint;

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      String safeDocName = noDoc.replaceAll('/', '_').replaceAll(' ', '');
      String prefix = isEbpb ? 'EBPB' : 'BAST';
      String savePath = '${dir?.path}/${prefix}_$safeDocName.pdf';

      final response = await _apiClient.dio.download(
        url,
        savePath,
        queryParameters: {
          'no_doc': noDoc,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Berhasil download PDF: $savePath");
        return savePath;
      }
      return null;
    } catch (e) {
      _logError("downloadPdfDocument", e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getInboundOpenDetail(String noDoc) async {
    try {
      final auth = _loginService.getCurrentAuth();
      String url = UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_INBOUND_OPEN_DETAIL;

      final response = await _apiClient.dio.get(
        url,
        queryParameters: {
          'no_doc': noDoc,
        },
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
      _logError("getInboundOpenDetail", e);
      return null;
    }
  }

  Future<Map<String, dynamic>?> getEbpbDetail(String noDoc) async {
    try {
      final auth = _loginService.getCurrentAuth();
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_TRANSACTION_DETAIL_EBPB,
        queryParameters: {
          'no_doc': noDoc,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } catch (e) {
      _logError("getEbpbDetail", e);
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
      await _penerimaanApiService.updateStatusTransactionApprovalService(
        noDoc: noDoc,
        levelApproval: levelApproval,
        statusApprove: status,
        catatan: note,
        isSign: signature != null,
        isPartnerSign: false,
      );

      if (status == 'APPROVED' && signature != null) {
        await _penerimaanApiService.uploadSignatureTransactionApprovalService(
            noDoc: noDoc,
            levelApproval: levelApproval,
            imageSign1: signature,
            imageSign2: signature
        );
      }

      return true;
    } catch (e) {
      _logError("submitPenerimaanApprovalDecision", e);
      return false;
    }
  }

  Future<List<dynamic>> getApprovalListEbpb({
    required String kodeUnit,
    required String levelApproval,
    required String statusApprove,
  }) async {
    try {
      final loginService = Get.find<LoginService>();
      final token = loginService.getCurrentAuth()?.access ?? '';

      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_APPROVAL_LIST_EBPB,
        queryParameters: {
          'kode_unit': kodeUnit,
          'level_approval': levelApproval,
          'status_approve': statusApprove,
        },
        options: Options(
          headers: {"Authorization": "Bearer $token"},
        ),
      );

      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else if (response.data['data'] != null) {
          return response.data['data'];
        }
      }
      return [];
    } catch (e) {
      _logError("getApprovalListEbpb", e);
      rethrow;
    }
  }

  void _logError(String context, dynamic e) {
    if (e is DioException) {
      // Cek jika error murni karena masalah jaringan atau timeout
      bool isNetworkError = e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.unknown; // Connection reset by peer sering masuk ke unknown

      if (isNetworkError) {
        print("⚠️ [ApprovalService] Gagal ke server (Timeout), beralih ke data lokal.");
        throw Exception("NETWORK_TIMEOUT");
      }
    } else {
      print("⚠️ [$context] Unexpected Error: $e");
    }
  }
}