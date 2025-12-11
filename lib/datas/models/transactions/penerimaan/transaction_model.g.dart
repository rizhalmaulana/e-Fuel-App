// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 20;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      noBast: fields[0] as String,
      status: fields[1] as String,
      dateCreated: fields[2] as String,
      dataSebelum: fields[3] as PenerimaanSebelumModel?,
      dataSesudah: fields[4] as PenerimaanSetelahModel?,
      currentLevelApproval: fields[5] as String?,
      currentStepApproval: fields[6] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(7)
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
      ..write(obj.currentStepApproval);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
