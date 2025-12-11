// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'penerimaan_setelah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PenerimaanSetelahModelAdapter
    extends TypeAdapter<PenerimaanSetelahModel> {
  @override
  final int typeId = 16;

  @override
  PenerimaanSetelahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PenerimaanSetelahModel(
      noDoc: fields[0] as String,
      tangkiList: (fields[1] as List?)?.cast<TangkiModel>(),
      iotTangkiList: (fields[2] as List?)?.cast<IotTangkiModel>(),
      ukuranStandarList: (fields[3] as List?)?.cast<UkuranStandarTangkiModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, PenerimaanSetelahModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.noDoc)
      ..writeByte(1)
      ..write(obj.tangkiList)
      ..writeByte(2)
      ..write(obj.iotTangkiList)
      ..writeByte(3)
      ..write(obj.ukuranStandarList);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PenerimaanSetelahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
