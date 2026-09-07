// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_solar_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransferSolarModelAdapter extends TypeAdapter<TransferSolarModel> {
  @override
  final int typeId = 36;

  @override
  TransferSolarModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransferSolarModel(
      id: fields[0] as int,
      noDoc: fields[1] as String,
      kodeUnit: fields[2] as String,
      namaUnit: fields[3] as String,
      noIo: fields[4] as String,
      aktualLiter: fields[5] as num,
      dateInbound: fields[6] as String,
      statusInbound: fields[7] as String,
      tipeUnitIo: fields[8] as String,
      nopolCheck: fields[9] as String,
      supirCheck: fields[10] as String,
      titleUnit: fields[23] as String?,
      varian: fields[11] as num?,
      inputAktualLiter: fields[12] as num?,
      inputVarianLiter: fields[13] as num?,
      foto1Path: fields[14] as String?,
      foto2Path: fields[15] as String?,
      foto3Path: fields[16] as String?,
      isOfflineSubmitted: fields[17] as bool,
      satuan: fields[18] as String?,
      hmKmAwal: fields[19] as num?,
      hmKmAkhir: fields[20] as num?,
      ratio: fields[21] as num?,
      jumlahPengisianSolar: fields[22] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, TransferSolarModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.noDoc)
      ..writeByte(2)
      ..write(obj.kodeUnit)
      ..writeByte(3)
      ..write(obj.namaUnit)
      ..writeByte(23)
      ..write(obj.titleUnit)
      ..writeByte(4)
      ..write(obj.noIo)
      ..writeByte(5)
      ..write(obj.aktualLiter)
      ..writeByte(6)
      ..write(obj.dateInbound)
      ..writeByte(7)
      ..write(obj.statusInbound)
      ..writeByte(8)
      ..write(obj.tipeUnitIo)
      ..writeByte(9)
      ..write(obj.nopolCheck)
      ..writeByte(10)
      ..write(obj.supirCheck)
      ..writeByte(11)
      ..write(obj.varian)
      ..writeByte(12)
      ..write(obj.inputAktualLiter)
      ..writeByte(13)
      ..write(obj.inputVarianLiter)
      ..writeByte(14)
      ..write(obj.foto1Path)
      ..writeByte(15)
      ..write(obj.foto2Path)
      ..writeByte(16)
      ..write(obj.foto3Path)
      ..writeByte(17)
      ..write(obj.isOfflineSubmitted)
      ..writeByte(18)
      ..write(obj.satuan)
      ..writeByte(19)
      ..write(obj.hmKmAwal)
      ..writeByte(20)
      ..write(obj.hmKmAkhir)
      ..writeByte(21)
      ..write(obj.ratio)
      ..writeByte(22)
      ..write(obj.jumlahPengisianSolar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransferSolarModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferSolarModel _$TransferSolarModelFromJson(Map<String, dynamic> json) =>
    TransferSolarModel(
      id: (json['id'] as num).toInt(),
      noDoc: json['no_doc'] as String,
      kodeUnit: json['kode_unit'] as String,
      namaUnit: json['nama_unit'] as String,
      noIo: json['no_io'] as String,
      aktualLiter: json['aktual_liter'] as num,
      dateInbound: json['date_inbound'] as String,
      statusInbound: json['status_inbound'] as String,
      tipeUnitIo: json['tipe_unit_io'] as String,
      nopolCheck: json['nopol_check'] as String,
      supirCheck: json['supir_check'] as String,
      titleUnit: json['title_unit'] as String?,
      varian: json['varian'] as num?,
      inputAktualLiter: json['input_aktual_liter'] as num?,
      inputVarianLiter: json['input_varian_liter'] as num?,
      foto1Path: json['foto1_path'] as String?,
      foto2Path: json['foto2_path'] as String?,
      foto3Path: json['foto3_path'] as String?,
      isOfflineSubmitted: json['is_offline_submitted'] as bool? ?? false,
      satuan: json['satuan'] as String?,
      hmKmAwal: json['hm_km_awal'] as num?,
      hmKmAkhir: json['hm_km_akhir'] as num?,
      ratio: json['ratio'] as num?,
      jumlahPengisianSolar: json['jumlah_pengisian_solar'] as num?,
    );

Map<String, dynamic> _$TransferSolarModelToJson(TransferSolarModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'no_doc': instance.noDoc,
      'kode_unit': instance.kodeUnit,
      'nama_unit': instance.namaUnit,
      'title_unit': instance.titleUnit,
      'no_io': instance.noIo,
      'aktual_liter': instance.aktualLiter,
      'date_inbound': instance.dateInbound,
      'status_inbound': instance.statusInbound,
      'tipe_unit_io': instance.tipeUnitIo,
      'nopol_check': instance.nopolCheck,
      'supir_check': instance.supirCheck,
      'varian': instance.varian,
      'input_aktual_liter': instance.inputAktualLiter,
      'input_varian_liter': instance.inputVarianLiter,
      'foto1_path': instance.foto1Path,
      'foto2_path': instance.foto2Path,
      'foto3_path': instance.foto3Path,
      'is_offline_submitted': instance.isOfflineSubmitted,
      'satuan': instance.satuan,
      'hm_km_awal': instance.hmKmAwal,
      'hm_km_akhir': instance.hmKmAkhir,
      'ratio': instance.ratio,
      'jumlah_pengisian_solar': instance.jumlahPengisianSolar,
    };
