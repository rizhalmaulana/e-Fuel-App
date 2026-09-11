import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../../../../datas/constant/url_api_static.dart';
import '../../../../datas/network/api_client_network.dart';
import '../../../../datas/models/transfer/transfer_solar_model.dart';
import '../../auth/services/login_service.dart';

class TransferOfflineService {
  final ApiClientNetwork _apiClient = ApiClientNetwork();
  final LoginService _loginService = Get.find<LoginService>();
  
  Box<TransferSolarModel>? _transferBox;
  Box? _settingsBox;

  Options _getAuthOptionsJson() {
    final auth = _loginService.getCurrentAuth();
    return Options(
      headers: {
        "Authorization": "Bearer ${auth?.access ?? ''}",
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    );
  }

  Future<void> initBox() async {
    final auth = _loginService.getCurrentAuth();
    final username = auth?.user.username ?? 'unknown';
    
    final boxName = 'TransferSolarBox_$username';
    if (!Hive.isBoxOpen(boxName)) {
      _transferBox = await Hive.openBox<TransferSolarModel>(boxName);
    } else {
      _transferBox = Hive.box<TransferSolarModel>(boxName);
    }

    final settingsBoxName = 'SettingsBox_$username';
    if (!Hive.isBoxOpen(settingsBoxName)) {
      _settingsBox = await Hive.openBox(settingsBoxName);
    } else {
      _settingsBox = Hive.box(settingsBoxName);
    }
  }

  Future<void> saveLastSyncTime(String time) async {
    await _settingsBox?.put('last_sync_transfer_solar', time);
  }

  String getLastSyncTime() {
    return _settingsBox?.get('last_sync_transfer_solar', defaultValue: '-') ?? '-';
  }

  Future<bool> syncDataFromBE(String kodeUnit) async {
    try {
      await initBox();
      
      final response = await _apiClient.dio.get(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_GET_LIST_ALAT_BERAT,
        queryParameters: {
          'kode_unit': kodeUnit,
          'status_inbound': 'O',
          'has_tf': false,
        },
        options: _getAuthOptionsJson(),
      );

      if (response.statusCode == 200) {
        List<dynamic> listData = response.data is List ? response.data : (response.data['data'] ?? []);
        
        List<TransferSolarModel> incomingData = listData.map((e) => TransferSolarModel.fromJson(e)).toList();
        List<String> incomingDocs = incomingData.map((e) => e.noDoc).toList();
        
        // Hapus data lokal yang sudah tidak ada di backend (dihapus/status berubah)
        // TETAPI HANYA JIKA data tersebut belum pernah di-submit/edit secara offline oleh user.
        var itemsToDelete = _transferBox!.values
            .where((e) => !incomingDocs.contains(e.noDoc) && !e.isOfflineSubmitted)
            .toList();
            
        for (var item in itemsToDelete) {
          await item.delete();
        }
        
        for (var item in incomingData) {
          var match = _transferBox!.values.where((e) => e.noDoc == item.noDoc).toList();
          var existing = match.isNotEmpty ? match.first : null;
          
          if (existing == null) {
             _transferBox!.add(item);
          } else if (!existing.isOfflineSubmitted) {
             existing.delete();
             _transferBox!.add(item);
          }
        }
        
        final dt = DateTime.now();
        final formattedDate = "${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        await saveLastSyncTime(formattedDate);
        
        return true;
      }
      return false;
    } catch (e) {
      print("Error syncDataFromBE: $e");
      return false;
    }
  }

  List<TransferSolarModel> getPendingTransfers() {
    if (_transferBox == null) return [];
    return _transferBox!.values.where((e) => !e.isOfflineSubmitted).toList();
  }

  List<TransferSolarModel> getSavedTransfers() {
    if (_transferBox == null) return [];
    return _transferBox!.values.where((e) => e.isOfflineSubmitted).toList();
  }

  Future<void> updateToOfflineSubmitted({
    required int id,
    required num aktualLiter,
    required num varianLiter,
    required String foto1Path,
    required String foto2Path,
    required String foto3Path,
    required String supirCheck,
    required num hmKmAwal,
    required num hmKmAkhir,
    required num ratio,
    required num estimasi,
  }) async {
    await initBox();
    var match = _transferBox!.values.where((e) => e.id == id).toList();
    var existing = match.isNotEmpty ? match.first : null;
    if (existing != null) {
      existing.inputAktualLiter = aktualLiter;
      existing.inputVarianLiter = varianLiter;
      existing.foto1Path = foto1Path;
      existing.foto2Path = foto2Path;
      existing.foto3Path = foto3Path;
      existing.supirCheck = supirCheck;
      existing.hmKmAwal = hmKmAwal;
      existing.hmKmAkhir = hmKmAkhir;
      existing.ratio = ratio;
      existing.jumlahPengisianSolar = estimasi;
      existing.isOfflineSubmitted = true;
      await existing.save();
    }
  }

  Future<bool> uploadTransfer(TransferSolarModel data) async {
    try {
      final auth = _loginService.getCurrentAuth();
      
      final payloadData = {
        "supir_check": data.supirCheck,
        "hm_km_akhir": data.hmKmAkhir ?? 0,
        "no_io": data.noIo,
        "liter": data.jumlahPengisianSolar ?? 0, // Estimasi liter
        "hm_km_awal": data.hmKmAwal ?? 0,
        "cost_center": "",
        "date_inbound": DateFormat('yyyy-MM-dd').format(DateTime.now()),
        "input_type": "A",
        "varian_liter": data.inputVarianLiter ?? 0,
        "ratio_input": data.ratio ?? 0,
        "no_doc": data.noDoc,
        "aktual_liter": data.inputAktualLiter ?? 0,
        "jenis_pengeluaran": "Transfer",
        "satuan": data.satuan ?? "",
        "kode_unit": data.kodeUnit,
      };

      FormData formData = FormData.fromMap({
        "payload": jsonEncode(payloadData),
      });

      if (data.foto1Path != null && data.foto1Path!.isNotEmpty) {
        formData.files.add(MapEntry(
          "foto1",
          await MultipartFile.fromFile(data.foto1Path!),
        ));
      }
      if (data.foto2Path != null && data.foto2Path!.isNotEmpty) {
        formData.files.add(MapEntry(
          "foto2",
          await MultipartFile.fromFile(data.foto2Path!),
        ));
      }
      if (data.foto3Path != null && data.foto3Path!.isNotEmpty) {
        formData.files.add(MapEntry(
          "foto3",
          await MultipartFile.fromFile(data.foto3Path!),
        ));
      }

      final response = await _apiClient.dio.post(
        UrlApiStatic.API_END_POINT + UrlApiStatic.API_CREATE_TRANSFER_SOLAR,
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
        await data.delete();
        return true;
      }
      throw Exception('Server mengembalikan status: ${response.statusCode}');
    } on DioException catch (e) {
      String errMsg = 'Gagal mengupload data. Silakan coba lagi.';
      
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            errMsg = 'Permintaan tidak valid, mohon periksa kembali input Anda.';
            break;
          case 401:
            errMsg = 'Sesi Anda telah habis, silakan login kembali.';
            break;
          case 403:
            errMsg = 'Anda tidak memiliki akses untuk melakukan tindakan ini.';
            break;
          case 404:
            errMsg = 'Layanan tidak ditemukan (404).';
            break;
          case 422:
            errMsg = 'Data yang dikirimkan tidak lengkap atau tidak sesuai (422).';
            break;
          case 500:
          case 502:
          case 503:
            errMsg = 'Terjadi kesalahan pada server, mohon coba beberapa saat lagi.';
            break;
          default:
            errMsg = 'Terjadi kesalahan sistem (Kode: ${e.response!.statusCode}).';
        }
      } else if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        errMsg = 'Koneksi terputus (Timeout). Periksa sinyal internet Anda.';
      } else {
        errMsg = 'Tidak dapat terhubung ke server. Pastikan internet Anda stabil.';
      }

      print("DioException uploadTransfer: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(errMsg);
    } catch (e) {
      print("Error uploadTransfer: $e");
      throw Exception('Terjadi kesalahan yang tidak terduga pada aplikasi.');
    }
  }
}
