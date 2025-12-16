import 'package:hive/hive.dart';
import '../storage_unit/storage_unit_model.dart';

part 'storage_to_tank_model.g.dart';

@HiveType(typeId: 26)
class StorageToTankModel {
  @HiveField(0)
  final int id;
  @HiveField(1)
  final StorageUnitModel? unit;
  @HiveField(2)
  final CSTStorageModel? masterStorage;
  @HiveField(3)
  final CSTTankModel? masterSolarTank;
  @HiveField(4)
  final String status;

  StorageToTankModel({
    required this.id,
    this.unit,
    this.masterStorage,
    this.masterSolarTank,
    required this.status,
  });

  factory StorageToTankModel.fromJson(Map<String, dynamic> json) {
    return StorageToTankModel(
      id: json['id'] ?? 0,
      unit: json['unit'] != null
          ? StorageUnitModel.fromJson(json['unit'])
          : null,
      masterStorage: json['master_storage'] != null
          ? CSTStorageModel.fromJson(json['master_storage'])
          : null,
      masterSolarTank: json['master_solar_tank'] != null
          ? CSTTankModel.fromJson(json['master_solar_tank'])
          : null,
      status: json['status'] ?? 'N',
    );
  }
}

@HiveType(typeId: 27)
class CSTStorageModel {
  @HiveField(0)
  final String kodeStorage;
  @HiveField(1)
  final String namaStorage;

  CSTStorageModel({
    required this.kodeStorage,
    required this.namaStorage,
  });

  factory CSTStorageModel.fromJson(Map<String, dynamic> json) {
    return CSTStorageModel(
      kodeStorage: json['kode_storage'] ?? '',
      namaStorage: json['nama_storage'] ?? '',
    );
  }
}

@HiveType(typeId: 28)
class CSTTankModel {
  @HiveField(0)
  final String kodeTank;
  @HiveField(1)
  final String namaTank;
  @HiveField(2)
  final int capacity;

  CSTTankModel({
    required this.kodeTank,
    required this.namaTank,
    required this.capacity,
  });

  factory CSTTankModel.fromJson(Map<String, dynamic> json) {
    return CSTTankModel(
      kodeTank: json['kode_tank'] ?? '',
      namaTank: json['nama_tank'] ?? '',

      capacity: (json['capacity'] is int)
          ? json['capacity']
          : int.tryParse(json['capacity'].toString()) ?? 20000,
    );
  }

  Map<String, dynamic> toJson() => {
    "kode_tank": kodeTank,
    "nama_tank": namaTank,
    "capacity": capacity,
  };
}