// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tangki_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TangkiModelAdapter extends TypeAdapter<TangkiModel> {
  @override
  final int typeId = 17;

  @override
  TangkiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TangkiModel(
      kodeTank: fields[0] as String,
      volumeTerkiniLiter: fields[1] as double?,
      tinggiTerkiniMM: fields[2] as double?,
      volumeAkhirLiter: fields[3] as double?,
      tinggiAkhirMM: fields[4] as double?,
      volumeVarLiter: fields[5] as double?,
      tinggiVarMM: fields[6] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, TangkiModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.kodeTank)
      ..writeByte(1)
      ..write(obj.volumeTerkiniLiter)
      ..writeByte(2)
      ..write(obj.tinggiTerkiniMM)
      ..writeByte(3)
      ..write(obj.volumeAkhirLiter)
      ..writeByte(4)
      ..write(obj.tinggiAkhirMM)
      ..writeByte(5)
      ..write(obj.volumeVarLiter)
      ..writeByte(6)
      ..write(obj.tinggiVarMM);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TangkiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
