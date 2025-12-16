// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengeluaran_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PengeluaranModelAdapter extends TypeAdapter<PengeluaranModel> {
  @override
  final int typeId = 30;

  @override
  PengeluaranModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PengeluaranModel(
      noDoc: fields[0] as String?,
      noIo: fields[1] as String?,
      nopolCheck: fields[2] as String?,
      statusSupir: fields[3] as String?,
      supirCheck: fields[4] as String?,
      kmPengisian: fields[5] as double?,
      jumlahPengisianSolar: fields[6] as double?,
      unitIO: fields[7] as String?,
      userName: fields[8] as String?,
      dateOutbound: fields[9] as String?,
      pathFoto1: fields[10] as String?,
      pathFoto2: fields[11] as String?,
      pathFoto3: fields[12] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PengeluaranModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.noDoc)
      ..writeByte(1)
      ..write(obj.noIo)
      ..writeByte(2)
      ..write(obj.nopolCheck)
      ..writeByte(3)
      ..write(obj.statusSupir)
      ..writeByte(4)
      ..write(obj.supirCheck)
      ..writeByte(5)
      ..write(obj.kmPengisian)
      ..writeByte(6)
      ..write(obj.jumlahPengisianSolar)
      ..writeByte(7)
      ..write(obj.unitIO)
      ..writeByte(8)
      ..write(obj.userName)
      ..writeByte(9)
      ..write(obj.dateOutbound)
      ..writeByte(10)
      ..write(obj.pathFoto1)
      ..writeByte(11)
      ..write(obj.pathFoto2)
      ..writeByte(12)
      ..write(obj.pathFoto3);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PengeluaranModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
