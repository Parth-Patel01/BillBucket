// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bill.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BillAdapter extends TypeAdapter<Bill> {
  @override
  final int typeId = 2;

  @override
  Bill read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Bill(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      frequency: fields[3] as BillFrequency,
      nextDueDate: fields[4] as DateTime,
      lastPaidDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Bill obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.frequency)
      ..writeByte(4)
      ..write(obj.nextDueDate)
      ..writeByte(5)
      ..write(obj.lastPaidDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BillFrequencyAdapter extends TypeAdapter<BillFrequency> {
  @override
  final int typeId = 1;

  @override
  BillFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BillFrequency.weekly;
      case 1:
        return BillFrequency.fortnightly;
      case 2:
        return BillFrequency.monthly;
      case 3:
        return BillFrequency.yearly;
      default:
        return BillFrequency.weekly;
    }
  }

  @override
  void write(BinaryWriter writer, BillFrequency obj) {
    switch (obj) {
      case BillFrequency.weekly:
        writer.writeByte(0);
        break;
      case BillFrequency.fortnightly:
        writer.writeByte(1);
        break;
      case BillFrequency.monthly:
        writer.writeByte(2);
        break;
      case BillFrequency.yearly:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BillFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
