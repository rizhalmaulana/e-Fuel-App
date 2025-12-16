// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'iot_tangki_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IotTangkiModelAdapter extends TypeAdapter<IotTangkiModel> {
  @override
  final int typeId = 18;

  @override
  IotTangkiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IotTangkiModel(
      kodeTank: fields[0] as String,
      iotVolumeTerkiniLiter: fields[1] as double?,
      iotTinggiTerkiniMM: fields[2] as double?,
      iotVolumeAkhirLiter: fields[3] as double?,
      iotTinggiAkhirMM: fields[4] as double?,
      iotVolumeVarLiter: fields[5] as double?,
      iotTinggiVarMM: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, IotTangkiModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.kodeTank)
      ..writeByte(1)
      ..write(obj.iotVolumeTerkiniLiter)
      ..writeByte(2)
      ..write(obj.iotTinggiTerkiniMM)
      ..writeByte(3)
      ..write(obj.iotVolumeAkhirLiter)
      ..writeByte(4)
      ..write(obj.iotTinggiAkhirMM)
      ..writeByte(5)
      ..write(obj.iotVolumeVarLiter)
      ..writeByte(6)
      ..write(obj.iotTinggiVarMM);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IotTangkiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
