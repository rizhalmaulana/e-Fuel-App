import 'package:hive/hive.dart';

part 'storage_unit_model.g.dart';

@HiveType(typeId: 22)
class StorageUnitModel {
  @HiveField(0)
  final String kodeUnit;
  @HiveField(1)
  final String namaUnit;

  StorageUnitModel({
    required this.kodeUnit,
    required this.namaUnit,
  });

  factory StorageUnitModel.fromJson(Map<String, dynamic> json) {
    return StorageUnitModel(
      kodeUnit: json['kode_unit'] ?? '',
      namaUnit: json['nama_unit'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    "kode_unit": kodeUnit,
    "nama_unit": namaUnit,
  };
}