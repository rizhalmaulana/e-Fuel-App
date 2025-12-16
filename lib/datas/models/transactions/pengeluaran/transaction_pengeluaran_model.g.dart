// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_pengeluaran_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionPengeluaranModelAdapter
    extends TypeAdapter<TransactionPengeluaranModel> {
  @override
  final int typeId = 31;

  @override
  TransactionPengeluaranModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionPengeluaranModel(
      noBast: fields[0] as String,
      status: fields[1] as String,
      dateCreated: fields[2] as String,
      dataSebelum: fields[3] as PenerimaanSebelumModel?,
      dataSesudah: fields[4] as PenerimaanSetelahModel?,
      currentLevelApproval: fields[5] as String?,
      currentStepApproval: fields[6] as int?,
      dataPengeluaran: fields[7] as PengeluaranModel?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionPengeluaranModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.noBast)
      ..writeByte(1)
      ..write(obj.status)
      ..writeByte(2)
      ..write(obj.dateCreated)
      ..writeByte(3)
      ..write(obj.dataSebelum)
      ..writeByte(4)
      ..write(obj.dataSesudah)
      ..writeByte(5)
      ..write(obj.currentLevelApproval)
      ..writeByte(6)
      ..write(obj.currentStepApproval)
      ..writeByte(7)
      ..write(obj.dataPengeluaran);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionPengeluaranModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
