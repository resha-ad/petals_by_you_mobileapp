// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderHiveModelAdapter extends TypeAdapter<OrderHiveModel> {
  @override
  final int typeId = 5;

  @override
  OrderHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderHiveModel(
      id: fields[0] as String,
      totalAmount: fields[1] as double,
      status: fields[2] as String,
      paymentStatus: fields[3] as String,
      paymentMethod: fields[4] as String,
      notes: fields[5] as String?,
      cancelReason: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime,
      itemTypes: (fields[9] as List).cast<String>(),
      itemRefIds: (fields[10] as List).cast<String>(),
      itemNames: (fields[11] as List).cast<String>(),
      itemUnitPrices: (fields[12] as List).cast<double>(),
      itemQuantities: (fields[13] as List).cast<int>(),
      itemSubtotals: (fields[14] as List).cast<double>(),
      itemImageUrls: (fields[15] as List).cast<String?>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderHiveModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.totalAmount)
      ..writeByte(2)
      ..write(obj.status)
      ..writeByte(3)
      ..write(obj.paymentStatus)
      ..writeByte(4)
      ..write(obj.paymentMethod)
      ..writeByte(5)
      ..write(obj.notes)
      ..writeByte(6)
      ..write(obj.cancelReason)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.itemTypes)
      ..writeByte(10)
      ..write(obj.itemRefIds)
      ..writeByte(11)
      ..write(obj.itemNames)
      ..writeByte(12)
      ..write(obj.itemUnitPrices)
      ..writeByte(13)
      ..write(obj.itemQuantities)
      ..writeByte(14)
      ..write(obj.itemSubtotals)
      ..writeByte(15)
      ..write(obj.itemImageUrls);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
