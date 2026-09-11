import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/network/api_client_network.dart';
import '../../../../datas/models/pengembalian/pengembalian_solar_model.dart';
import '../../auth/services/login_service.dart';
import 'package:intl/intl.dart';

class PengembalianService {
  final ApiClientNetwork _apiClient = ApiClientNetwork();
  final LoginService _loginService = Get.find<LoginService>();

  Future<List<PengembalianSolarModel>> getListPengembalian() async {
    try {
      final auth = _loginService.getCurrentAuth();
      final kodeUnit = auth?.currentKodeUnit ?? '';

      final response = await _apiClient.dio.get(
        UrlApiStatic.API_GET_LIST_PENGEMBALIAN_SOLAR,
        queryParameters: {
          "kode_unit": kodeUnit,
          "status_inbound": "T",
        },
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200) {
        List data = response.data;
        return data.map((json) => PengembalianSolarModel.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print("Error getListPengembalian: $e");
      return [];
    }
  }

  Future<bool> submitPengembalian({
    required PengembalianSolarModel data,
    required num varianLiterPengembalian, // Varian yang dikembalikan
    required String keterangan,
    String? foto1Path,
  }) async {
    try {
      final auth = _loginService.getCurrentAuth();
      final kodeUnit = auth?.currentKodeUnit ?? '';

      final payloadData = {
        "keterangan": keterangan,
        "no_io": data.noIo,
        "liter": data.liter,
        "date_inbound": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "tipe_unit_io": data.tipeUnitIo,
        "input_type": "A",
        "varian_liter": varianLiterPengembalian,
        "no_doc_tf": data.noDoc,
        "aktual_liter": data.aktualLiterTransfer,
        "kode_unit": kodeUnit,
      };

      FormData formData = FormData.fromMap({
        "payload": jsonEncode(payloadData),
      });

      if (foto1Path != null && foto1Path.isNotEmpty) {
        formData.files.add(MapEntry(
          "foto1",
          await MultipartFile.fromFile(foto1Path),
        ));
      }

      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_PENGEMBALIAN_SOLAR,
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer ${auth?.access ?? ''}",
            "Content-Type": "multipart/form-data",
            "Accept": "application/json",
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      
      throw Exception('Server mengembalikan status: ${response.statusCode}');
    } on DioException catch (e) {
      String errMsg = 'Gagal mengupload data. Silakan coba lagi.';
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400: errMsg = 'Permintaan tidak valid, bisa hubungi admin E-Fuel.'; break;
          case 401: errMsg = 'Sesi Anda telah habis, silakan login kembali.'; break;
          case 403: errMsg = 'Anda tidak memiliki akses untuk melakukan tindakan ini.'; break;
          case 404: errMsg = 'Layanan tidak ditemukan.'; break;
          case 422: errMsg = 'Data yang dikirimkan tidak lengkap atau tidak sesuai.'; break;
          case 500:
          case 502:
          case 503: errMsg = 'Terjadi kesalahan pada server, mohon coba beberapa saat lagi.'; break;
          default: errMsg = 'Terjadi kesalahan sistem (Kode: ${e.response!.statusCode}).';
        }
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        errMsg = 'Koneksi terputus (Timeout). Periksa sinyal internet Anda.';
      } else {
        errMsg = 'Tidak dapat terhubung ke server. Pastikan internet Anda stabil.';
      }
      throw Exception(errMsg);
    } catch (e) {
      throw Exception('Terjadi kesalahan yang tidak terduga pada aplikasi.');
    }
  }
}
