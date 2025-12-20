import 'package:firebase_database/firebase_database.dart';

class InitiateRatioModel {
  final String noUnitIO;
  final String namaUnitIO;
  final double ratio;
  final String tipe;
  final int operation;
  final int operationHoliday;
  final String createDate;
  final String updateDate;

  InitiateRatioModel({
    required this.noUnitIO,
    required this.namaUnitIO,
    required this.ratio,
    required this.tipe,
    required this.operation,
    required this.operationHoliday,
    required this.createDate,
    required this.updateDate,
  });

  Map<String, dynamic> toJson() => {
    'NoUnitIO': noUnitIO,
    'NamaUnitIO': namaUnitIO,
    'Ratio': ratio,
    'Tipe': tipe,
    'Operation': operation,
    'OperationHoliday': operationHoliday,
    'CreateDate': createDate,
    'UpdateDate': updateDate,
  };

  factory InitiateRatioModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map;
    return InitiateRatioModel(
      noUnitIO: data['NoUnitIO'] ?? '',
      namaUnitIO: data['NamaUnitIO'] ?? '',
      ratio: (data['Ratio'] ?? 0).toDouble(),
      tipe: data['Tipe'] ?? '',
      operation: data['Operation'] ?? 0,
      operationHoliday: data['OperationHoliday'] ?? 0,
      createDate: data['CreateDate'] ?? DateTime.now().toIso8601String(),
      updateDate: data['UpdateDate'] ?? DateTime.now().toIso8601String(),
    );
  }
}