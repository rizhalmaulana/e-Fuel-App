// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ukuran_standar_tangki_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UkuranStandarTangkiModelAdapter
    extends TypeAdapter<UkuranStandarTangkiModel> {
  @override
  final int typeId = 19;

  @override
  UkuranStandarTangkiModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UkuranStandarTangkiModel(
      kodeTank: fields[0] as String,
      stdLebarDiterima: fields[1] as double?,
      volumeSolarDiterima: fields[2] as double?,
      stdLebarTangkiKebun: fields[3] as double?,
      stdPanjangDiterima: fields[4] as double?,
      volumeTangkiPengirim: fields[5] as double?,
      stdTinggiDiterima: fields[6] as double?,
      stdPanjangTangkiKebun: fields[7] as double?,
      stdTinggiTangkiKebun: fields[8] as double?,
      varSolarTangki: fields[9] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, UkuranStandarTangkiModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.kodeTank)
      ..writeByte(1)
      ..write(obj.stdLebarDiterima)
      ..writeByte(2)
      ..write(obj.volumeSolarDiterima)
      ..writeByte(3)
      ..write(obj.stdLebarTangkiKebun)
      ..writeByte(4)
      ..write(obj.stdPanjangDiterima)
      ..writeByte(5)
      ..write(obj.volumeTangkiPengirim)
      ..writeByte(6)
      ..write(obj.stdTinggiDiterima)
      ..writeByte(7)
      ..write(obj.stdPanjangTangkiKebun)
      ..writeByte(8)
      ..write(obj.stdTinggiTangkiKebun)
      ..writeByte(9)
      ..write(obj.varSolarTangki);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UkuranStandarTangkiModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
