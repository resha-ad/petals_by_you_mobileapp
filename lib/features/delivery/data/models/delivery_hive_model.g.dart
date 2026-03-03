// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delivery_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeliveryHiveModelAdapter extends TypeAdapter<DeliveryHiveModel> {
  @override
  final int typeId = 6;

  @override
  DeliveryHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeliveryHiveModel(
      id: fields[0] as String,
      orderId: fields[1] as String,
      recipientName: fields[2] as String,
      recipientPhone: fields[3] as String,
      addressStreet: fields[4] as String,
      addressCity: fields[5] as String,
      addressState: fields[6] as String?,
      addressZip: fields[7] as String?,
      addressCountry: fields[8] as String,
      status: fields[9] as String,
      scheduledDate: fields[10] as DateTime?,
      estimatedDelivery: fields[11] as DateTime?,
      deliveredAt: fields[12] as DateTime?,
      trackingMessages: (fields[13] as List).cast<String>(),
      trackingTimestamps: (fields[14] as List).cast<DateTime>(),
      trackingUpdatedBy: (fields[15] as List).cast<String?>(),
      deliveryNotes: fields[16] as String?,
      cancelReason: fields[17] as String?,
      cancelledAt: fields[18] as DateTime?,
      createdAt: fields[19] as DateTime,
      updatedAt: fields[20] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeliveryHiveModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.recipientName)
      ..writeByte(3)
      ..write(obj.recipientPhone)
      ..writeByte(4)
      ..write(obj.addressStreet)
      ..writeByte(5)
      ..write(obj.addressCity)
      ..writeByte(6)
      ..write(obj.addressState)
      ..writeByte(7)
      ..write(obj.addressZip)
      ..writeByte(8)
      ..write(obj.addressCountry)
      ..writeByte(9)
      ..write(obj.status)
      ..writeByte(10)
      ..write(obj.scheduledDate)
      ..writeByte(11)
      ..write(obj.estimatedDelivery)
      ..writeByte(12)
      ..write(obj.deliveredAt)
      ..writeByte(13)
      ..write(obj.trackingMessages)
      ..writeByte(14)
      ..write(obj.trackingTimestamps)
      ..writeByte(15)
      ..write(obj.trackingUpdatedBy)
      ..writeByte(16)
      ..write(obj.deliveryNotes)
      ..writeByte(17)
      ..write(obj.cancelReason)
      ..writeByte(18)
      ..write(obj.cancelledAt)
      ..writeByte(19)
      ..write(obj.createdAt)
      ..writeByte(20)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeliveryHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
