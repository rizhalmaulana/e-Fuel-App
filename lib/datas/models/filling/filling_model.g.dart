// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'filling_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FillingModelAdapter extends TypeAdapter<FillingModel> {
  @override
  final int typeId = 15;

  @override
  FillingModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FillingModel(
      transactionId: fields[0] as String,
      storageCode: fields[1] as String,
      tankCode: fields[2] as String,
      volumeBefore: fields[3] as double,
      heightBefore: fields[4] as double,
      volumeAfter: fields[5] as double,
      heightAfter: fields[6] as double,
      volumeVariant: fields[7] as double,
      heightVariant: fields[8] as double,
      volumeBeforeIoT: fields[9] as double?,
      heightBeforeIoT: fields[10] as double?,
      volumeAfterIoT: fields[11] as double?,
      heightAfterIoT: fields[12] as double?,
      volumeVariantIoT: fields[13] as double?,
      heightVariantIoT: fields[14] as double?,
      timestamp: fields[15] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FillingModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.transactionId)
      ..writeByte(1)
      ..write(obj.storageCode)
      ..writeByte(2)
      ..write(obj.tankCode)
      ..writeByte(3)
      ..write(obj.volumeBefore)
      ..writeByte(4)
      ..write(obj.heightBefore)
      ..writeByte(5)
      ..write(obj.volumeAfter)
      ..writeByte(6)
      ..write(obj.heightAfter)
      ..writeByte(7)
      ..write(obj.volumeVariant)
      ..writeByte(8)
      ..write(obj.heightVariant)
      ..writeByte(9)
      ..write(obj.volumeBeforeIoT)
      ..writeByte(10)
      ..write(obj.heightBeforeIoT)
      ..writeByte(11)
      ..write(obj.volumeAfterIoT)
      ..writeByte(12)
      ..write(obj.heightAfterIoT)
      ..writeByte(13)
      ..write(obj.volumeVariantIoT)
      ..writeByte(14)
      ..write(obj.heightVariantIoT)
      ..writeByte(15)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FillingModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
