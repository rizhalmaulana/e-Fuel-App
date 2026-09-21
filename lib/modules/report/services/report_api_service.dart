import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../datas/constant/url_api_static.dart';
import '../../../datas/models/report/report_transaction_model.dart';
import '../../../datas/network/api_client_network.dart';
import '../../auth/services/login_service.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

class ReportApiService {
  final ApiClientNetwork _apiClient = ApiClientNetwork();
  final LoginService _loginService = Get.find<LoginService>();

  Future<List<ReportTransactionModel>> getAllTransactions({
    required String startDate,
    required String endDate,
    required String transactionType,
  }) async {
    final auth = _loginService.getCurrentAuth();
    final token = auth?.access ?? '';
    final kodeUnit = auth?.currentKodeUnit ?? '';
    final cacheKey = 'report_cache_${transactionType}_$kodeUnit';

    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_ALL_TRANSACTION_LIST,
        queryParameters: {
          'start_date': startDate,
          'end_date': endDate,
          'kode_unit': kodeUnit,
          'transaction_type': transactionType,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200) {
        List dataRaw = [];

        if (response.data is List) {
          dataRaw = response.data;
        } else if (response.data is Map && response.data['data'] != null) {
          dataRaw = response.data['data'];
        }

        try {
          var box = await Hive.openBox('report_cache_box');
          await box.put(cacheKey, dataRaw);
        } catch (e) {
          print("⚠️ Gagal menyimpan cache: $e");
        }

        return dataRaw.map((e) => ReportTransactionModel.fromJson(e)).toList();
      } else {
        print("🔴 [API ERROR] Status Code bukan 200. Memuat dari cache...");
        return _loadFromCache(cacheKey);
      }
    } catch (e) {
      print("🔴 [API EXCEPTION] Error fetching report: $e. Memuat dari cache...");
      return _loadFromCache(cacheKey);
    }
  }

  Future<List<ReportTransactionModel>> _loadFromCache(String cacheKey) async {
    try {
      var box = await Hive.openBox('report_cache_box');
      List? cachedData = box.get(cacheKey);
      
      if (cachedData != null && cachedData.isNotEmpty) {
        Get.snackbar(
          "Mode Offline", 
          "Menampilkan data laporan tersimpan. Refresh untuk data terbaru.",
          backgroundColor: Colors.orange.withOpacity(0.8),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          margin: const EdgeInsets.all(16),
          icon: const Icon(Icons.wifi_off_rounded, color: Colors.white),
        );
            
        // Convert List dinamis dari Hive ke List of Map agar bisa di-parse oleh fromJson
        List<Map<String, dynamic>> mapData = cachedData.map((e) => Map<String, dynamic>.from(e)).toList();
        return mapData.map((e) => ReportTransactionModel.fromJson(e)).toList();
      }
    } catch (cacheError) {
      print("🔴 Gagal membaca cache: $cacheError");
    }
    return [];
  }

  Future<Map<String, dynamic>?> getDetailPenerimaanApproved(String noDoc) async {
    final auth = _loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    try {
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_DETAIL_DOC_FULL_APPROVED,
        queryParameters: {
          'no_doc': noDoc,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("🔴 [API EXCEPTION] Error fetching detail report: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> getDetailPengeluaran(String noDoc) async {
    final auth = _loginService.getCurrentAuth();
    final token = auth?.access ?? '';

    try {
      String urlPath = UrlApiStatic.API_GET_INBOUND_OPEN_DETAIL.replaceAll('{no_doc}', noDoc);

      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + urlPath,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
          },
        ),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'];
      }
      return null;
    } catch (e) {
      print("🔴 [API EXCEPTION] Error fetching detail pengeluaran: $e");
      return null;
    }
  }
}