// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartItemHiveModelAdapter extends TypeAdapter<CartItemHiveModel> {
  @override
  final int typeId = 4;

  @override
  CartItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartItemHiveModel(
      type: fields[0] as String,
      refId: fields[1] as String,
      quantity: fields[2] as int,
      unitPrice: fields[3] as double,
      subtotal: fields[4] as double,
      itemName: fields[5] as String?,
      itemImages: (fields[6] as List?)?.cast<String>(),
      itemCategory: fields[7] as String?,
      itemPrice: fields[8] as double?,
      itemDiscountPrice: fields[9] as double?,
      itemStock: fields[10] as int?,
      itemSlug: fields[11] as String?,
      itemDescription: fields[12] as String?,
      customRecipientName: fields[13] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.refId)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.unitPrice)
      ..writeByte(4)
      ..write(obj.subtotal)
      ..writeByte(5)
      ..write(obj.itemName)
      ..writeByte(6)
      ..write(obj.itemImages)
      ..writeByte(7)
      ..write(obj.itemCategory)
      ..writeByte(8)
      ..write(obj.itemPrice)
      ..writeByte(9)
      ..write(obj.itemDiscountPrice)
      ..writeByte(10)
      ..write(obj.itemStock)
      ..writeByte(11)
      ..write(obj.itemSlug)
      ..writeByte(12)
      ..write(obj.itemDescription)
      ..writeByte(13)
      ..write(obj.customRecipientName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
