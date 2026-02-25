// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penerimaan_sebelum_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PenerimaanSebelumModelAdapter
    extends TypeAdapter<PenerimaanSebelumModel> {
  @override
  final int typeId = 14;

  @override
  PenerimaanSebelumModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PenerimaanSebelumModel(
      userName: fields[0] as String,
      status: fields[1] as String?,
      supirCheck: fields[2] as String?,
      segelKondisi: fields[3] as String?,
      tangkiPeka: fields[4] as String?,
      segelTangkiBawah: fields[5] as String?,
      dateInbound: fields[6] as String?,
      docTypeCode: fields[7] as String?,
      volumeVendor: fields[8] as double?,
      dtimeBefore: fields[9] as String?,
      purchNo: fields[10] as String?,
      dtimeAfter: fields[11] as String?,
      vendorSpb: fields[12] as String?,
      supirVendor: fields[13] as String?,
      storageCode: fields[14] as String?,
      densityCheck: fields[15] as double?,
      kapasitasCheck: fields[16] as double?,
      tempVendor: fields[17] as double?,
      nopolCheck: fields[18] as String?,
      terraVendor: fields[19] as double?,
      terraVar: fields[20] as double?,
      terraCheck: fields[21] as double?,
      volumeTerkiniLiter: fields[22] as double?,
      nopolVendor: fields[23] as String?,
      tempCheck: fields[24] as double?,
      segelTangkiAtas: fields[25] as String?,
      kodeUnit: fields[26] as String?,
      kapasitasVendor: fields[27] as double?,
      tinggiTerkiniCm: fields[28] as double?,
      densityVendor: fields[29] as double?,
      pathFotoDoc: fields[30] as String?,
      pathFotoDepan: fields[31] as String?,
      pathFotoSamping: fields[32] as String?,
      isSynced: fields[33] as bool,
      noDocBast: fields[34] as String?,
      manualTankDetailsJson: fields[35] as String?,
      iotTankDetailsJson: fields[36] as String?,
      totalVolumeManual: fields[37] as double?,
      totalVolumeIot: fields[38] as double?,
      selisihVolumeTerra: fields[39] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, PenerimaanSebelumModel obj) {
    writer
      ..writeByte(40)
      ..writeByte(0)
      ..write(obj.userName)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.supirCheck)
      ..writeByte(3)
      ..write(obj.segelKondisi)
      ..writeByte(4)
      ..write(obj.tangkiPeka)
      ..writeByte(5)
      ..write(obj.segelTangkiBawah)
      ..writeByte(6)
      ..write(obj.dateInbound)
      ..writeByte(7)
      ..write(obj.docTypeCode)
      ..writeByte(8)
      ..write(obj.volumeVendor)
      ..writeByte(9)
      ..write(obj.dtimeBefore)
      ..writeByte(10)
      ..write(obj.purchNo)
      ..writeByte(11)
      ..write(obj.dtimeAfter)
      ..writeByte(12)
      ..write(obj.vendorSpb)
      ..writeByte(13)
      ..write(obj.supirVendor)
      ..writeByte(14)
      ..write(obj.storageCode)
      ..writeByte(15)
      ..write(obj.densityCheck)
      ..writeByte(16)
      ..write(obj.kapasitasCheck)
      ..writeByte(17)
      ..write(obj.tempVendor)
      ..writeByte(18)
      ..write(obj.nopolCheck)
      ..writeByte(19)
      ..write(obj.terraVendor)
      ..writeByte(20)
      ..write(obj.terraVar)
      ..writeByte(21)
      ..write(obj.terraCheck)
      ..writeByte(22)
      ..write(obj.volumeTerkiniLiter)
      ..writeByte(23)
      ..write(obj.nopolVendor)
      ..writeByte(24)
      ..write(obj.tempCheck)
      ..writeByte(25)
      ..write(obj.segelTangkiAtas)
      ..writeByte(26)
      ..write(obj.kodeUnit)
      ..writeByte(27)
      ..write(obj.kapasitasVendor)
      ..writeByte(28)
      ..write(obj.tinggiTerkiniCm)
      ..writeByte(29)
      ..write(obj.densityVendor)
      ..writeByte(30)
      ..write(obj.pathFotoDoc)
      ..writeByte(31)
      ..write(obj.pathFotoDepan)
      ..writeByte(32)
      ..write(obj.pathFotoSamping)
      ..writeByte(33)
      ..write(obj.isSynced)
      ..writeByte(34)
      ..write(obj.noDocBast)
      ..writeByte(35)
      ..write(obj.manualTankDetailsJson)
      ..writeByte(36)
      ..write(obj.iotTankDetailsJson)
      ..writeByte(37)
      ..write(obj.totalVolumeManual)
      ..writeByte(38)
      ..write(obj.totalVolumeIot)
      ..writeByte(39)
      ..write(obj.selisihVolumeTerra);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenerimaanSebelumModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
