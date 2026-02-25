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
      tinggiTerkiniCM: fields[2] as double?,
      volumeAkhirLiter: fields[3] as double?,
      tinggiAkhirCM: fields[4] as double?,
      volumeVarLiter: fields[5] as double?,
      tinggiVarCM: fields[6] as double?,
      namaTank: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TangkiModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.kodeTank)
      ..writeByte(1)
      ..write(obj.volumeTerkiniLiter)
      ..writeByte(2)
      ..write(obj.tinggiTerkiniCM)
      ..writeByte(3)
      ..write(obj.volumeAkhirLiter)
      ..writeByte(4)
      ..write(obj.tinggiAkhirCM)
      ..writeByte(5)
      ..write(obj.volumeVarLiter)
      ..writeByte(6)
      ..write(obj.tinggiVarCM)
      ..writeByte(7)
      ..write(obj.namaTank);
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
