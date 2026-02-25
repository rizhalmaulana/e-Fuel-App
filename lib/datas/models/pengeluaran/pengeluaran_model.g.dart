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
      keterangan: fields[13] as String?,
      docType: fields[14] as String?,
      hmKmAkhi: fields[15] as double?,
      liter: fields[16] as double?,
      hmKmAwak: fields[17] as double?,
      costCenter: fields[18] as String?,
      ratio: fields[19] as double?,
      tipeUnitIo: fields[20] as String?,
      varian: fields[21] as double?,
      tanggalAkhir: fields[22] as String?,
      tanggalAwal: fields[23] as String?,
      satuan: fields[24] as String?,
      kategoriKendaraan: fields[25] as String?,
      jenisPengeluaran: fields[26] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PengeluaranModel obj) {
    writer
      ..writeByte(27)
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
      ..write(obj.pathFoto3)
      ..writeByte(13)
      ..write(obj.keterangan)
      ..writeByte(14)
      ..write(obj.docType)
      ..writeByte(15)
      ..write(obj.hmKmAkhi)
      ..writeByte(16)
      ..write(obj.liter)
      ..writeByte(17)
      ..write(obj.hmKmAwak)
      ..writeByte(18)
      ..write(obj.costCenter)
      ..writeByte(19)
      ..write(obj.ratio)
      ..writeByte(20)
      ..write(obj.tipeUnitIo)
      ..writeByte(21)
      ..write(obj.varian)
      ..writeByte(22)
      ..write(obj.tanggalAkhir)
      ..writeByte(23)
      ..write(obj.tanggalAwal)
      ..writeByte(24)
      ..write(obj.satuan)
      ..writeByte(25)
      ..write(obj.kategoriKendaraan)
      ..writeByte(26)
      ..write(obj.jenisPengeluaran);
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
