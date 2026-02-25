import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_fuel/modules/transactions/penerimaan/services/penerimaan_api_service.dart';
import 'package:e_fuel/modules/transactions/pengeluaran/services/pengeluaran_api_service.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
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
    String? noBast, // 🟢 TAMBAHAN BARU
  }) async {
    try {
      final auth = _loginService.getCurrentAuth();
      final response = await _dio.get(
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
      print("⚠️ Gagal fetch approval list: $e");
      return [];
    }
  }

  Future<String?> downloadPdfDocument(String noDoc) async {
    try {
      final auth = _loginService.getCurrentAuth();
      String url = UrlApiStatic.API_EXPORT_PDF_DOC.replaceAll('{no_doc}', noDoc);

      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      String savePath = '${dir?.path}/BAST_$noDoc.pdf';

      final response = await _dio.download(
        url,
        savePath,
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
          },
        ),
      );

      if (response.statusCode == 200) {
        print("✅ Berhasil download PDF: $savePath");
        return savePath; // 🟢 Kembalikan path file jika sukses
      }
      return null; // 🟢 Kembalikan null jika gagal
    } catch (e) {
      print("❌ Error download PDF BAST: $e");
      return null; // 🟢 Kembalikan null jika error
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