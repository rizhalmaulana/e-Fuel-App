class VolumeStorage {
  final String kodeStorage;
  final String kodeUnit;
  final String dateLog;
  final int totalTanks;
  final double totalStockVolume;
  final double totalLatestVolumeFlowout;

  VolumeStorage({
    required this.kodeStorage,
    required this.kodeUnit,
    required this.dateLog,
    required this.totalTanks,
    required this.totalStockVolume,
    required this.totalLatestVolumeFlowout,
  });

  factory VolumeStorage.fromJson(Map<String, dynamic> json) {
    return VolumeStorage(
      kodeStorage: json['kode_storage'] ?? '',
      kodeUnit: json['kode_unit'] ?? '',
      dateLog: json['date_log'] ?? '',
      totalTanks: json['total_tanks'] ?? 0,
      totalStockVolume: (json['total_stock_volume'] as num?)?.toDouble() ?? 0.0,
      totalLatestVolumeFlowout: (json['total_latest_volume_flowout'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kode_storage': kodeStorage,
      'kode_unit': kodeUnit,
      'date_log': dateLog,
      'total_tanks': totalTanks,
      'total_stock_volume': totalStockVolume,
      'total_latest_volume_flowout': totalLatestVolumeFlowout,
    };
  }
}