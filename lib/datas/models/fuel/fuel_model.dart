import 'package:hive/hive.dart';

part 'fuel_model.g.dart';

// 1. Model Master Storage
// @HiveType(typeId: 10)
// class StorageModel {
//   @HiveField(0)
//   final String storageCode;
//   @HiveField(1)
//   final String storageDesc;
//   @HiveField(2)
//   final String storageActive;
//   @HiveField(3)
//   final String storageName; // Field 'storage' dari dummy
//
//   StorageModel({
//     required this.storageCode,
//     required this.storageDesc,
//     required this.storageActive,
//     required this.storageName,
//   });
//
//   factory StorageModel.fromJson(Map<String, dynamic> json) {
//     return StorageModel(
//       storageCode: json['storage_code'] ?? '',
//       storageDesc: json['storage_desc'] ?? '',
//       storageActive: json['storage_active'] ?? 'N',
//       storageName: json['storage'] ?? '',
//     );
//   }
// }

// 2. Model Master Tank
@HiveType(typeId: 11)
class TankModel {
  @HiveField(0)
  final String tankCode;
  @HiveField(1)
  final String tankDesc;
  @HiveField(2)
  final String tankActive;
  @HiveField(3)
  final int tankId;

  TankModel({
    required this.tankCode,
    required this.tankDesc,
    required this.tankActive,
    required this.tankId,
  });

  factory TankModel.fromJson(Map<String, dynamic> json) {
    return TankModel(
      tankCode: json['tank_code'] ?? '',
      tankDesc: json['tank_desc'] ?? '',
      tankActive: json['tank_active'] ?? 'N',
      tankId: json['tank_id'] ?? 0,
    );
  }
}

// 3. Model Storage Tank (Data IOT)
@HiveType(typeId: 12)
class StorageTankModel {
  @HiveField(0)
  final String storageCode;
  @HiveField(1)
  final String tankCode;
  @HiveField(2)
  final double volume;
  @HiveField(3)
  final int height;
  @HiveField(4)
  final String statusActive;

  StorageTankModel({
    required this.storageCode,
    required this.tankCode,
    required this.volume,
    required this.height,
    required this.statusActive,
  });

  factory StorageTankModel.fromJson(Map<String, dynamic> json) {
    return StorageTankModel(
      storageCode: json['storage_code'] ?? '',
      tankCode: json['tank_code'] ?? '',
      volume: (json['volume'] is int)
          ? (json['volume'] as int).toDouble()
          : (json['volume'] ?? 0.0),
      height: (json['height'] is double)
          ? (json['height'] as double).toInt()
          : (json['height'] ?? 0),
      statusActive: json['status_active'] ?? 'N',
    );
  }
}