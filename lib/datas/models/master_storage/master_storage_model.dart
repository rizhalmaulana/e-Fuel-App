import 'package:hive/hive.dart';
import 'package:e_fuel/datas/models/storage_unit/storage_unit_model.dart';

part 'master_storage_model.g.dart';

@HiveType(typeId: 21)
class MasterStorageModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final String kodeStorage;
  @HiveField(2)
  final String namaStorage;
  @HiveField(3)
  final String storageStatus; // Variabel bernama storageStatus
  @HiveField(4)
  final StorageUnitModel? unit;

  MasterStorageModel({
    required this.id,
    required this.kodeStorage,
    required this.namaStorage,
    required this.storageStatus,
    this.unit,
  });

  factory MasterStorageModel.fromJson(Map<String, dynamic> json) {
    return MasterStorageModel(
      id: json['id'] ?? 0,
      kodeStorage: json['kode_storage'] ?? '',
      namaStorage: json['nama_storage'] ?? '',
      storageStatus: json['status'] ?? json['storage_status'] ?? 'N',
      unit: json['unit'] != null ? StorageUnitModel.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "kode_storage": kodeStorage,
    "nama_storage": namaStorage,
    "status": storageStatus,
    "unit": unit?.toJson(),
  };
}