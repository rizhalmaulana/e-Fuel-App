class VolumeStorage {
  final bool success;
  final String errorCode;
  final String dateLog;
  final double volume;
  final String idCard;
  final String vehicleId;
  final String message;

  VolumeStorage({
    required this.success,
    required this.errorCode,
    required this.dateLog,
    required this.volume,
    required this.idCard,
    required this.vehicleId,
    required this.message
  });

  factory VolumeStorage.fromJson(Map<String, dynamic> json) {
    return VolumeStorage(
      success: json['success'],
      errorCode: json['error_code']?.toString() ?? '',
      dateLog: json['date_log'] ?? '',
      volume: (json['volume'] != null) ? (json['volume'] as num).toDouble() : 0.0,
      idCard: json['id_card'] ?? '',
      vehicleId: json['vehicle_id'] ?? json['vehicle_id'] ?? '', // Handle possible typo in key
      message: json['message'] ?? ''
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'error_code': errorCode,
      'date_log': dateLog,
      'volume': volume,
      'id_card': idCard,
      'vehicle_id': vehicleId,
      'message': message
    };
  }
}