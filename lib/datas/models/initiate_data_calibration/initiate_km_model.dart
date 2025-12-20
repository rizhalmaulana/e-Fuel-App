import 'package:firebase_database/firebase_database.dart';

class InitiateKmModel {
  final String noUnitIO;
  final String namaUnitIO;
  final double kmAwal;
  final String dateAwal;
  final String createDate;
  final String updateDate;

  InitiateKmModel({
    required this.noUnitIO,
    required this.namaUnitIO,
    required this.kmAwal,
    required this.dateAwal,
    required this.createDate,
    required this.updateDate,
  });

  Map<String, dynamic> toJson() => {
    'NoUnitIO': noUnitIO,
    'NamaUnitIO': namaUnitIO,
    'KMAwal': kmAwal,
    'DateAwal': dateAwal,
    'createDate': createDate,
    'updateDate': updateDate,
  };

  factory InitiateKmModel.fromSnapshot(DataSnapshot snapshot) {
    final data = snapshot.value as Map;
    return InitiateKmModel(
      noUnitIO: data['NoUnitIO'] ?? '',
      namaUnitIO: data['NamaUnitIO'] ?? '',
      kmAwal: (data['KMAwal'] ?? 0).toDouble(),
      dateAwal: data['DateAwal'] ?? '',
      createDate: data['createDate'] ?? DateTime.now().toIso8601String(),
      updateDate: data['updateDate'] ?? DateTime.now().toIso8601String(),
    );
  }
}