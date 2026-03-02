// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ItemHiveModelAdapter extends TypeAdapter<ItemHiveModel> {
  @override
  final int typeId = 2;

  @override
  ItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ItemHiveModel(
      itemId: fields[0] as String,
      name: fields[1] as String,
      slug: fields[2] as String,
      description: fields[3] as String,
      price: fields[4] as double,
      discountPrice: fields[5] as double?,
      category: fields[6] as String?,
      images: (fields[7] as List).cast<String>(),
      isFeatured: fields[8] as bool,
      isAvailable: fields[9] as bool,
      stock: fields[10] as int,
      preparationTime: fields[11] as int?,
      deliveryType: fields[12] as String?,
      cachedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ItemHiveModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.slug)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.discountPrice)
      ..writeByte(6)
      ..write(obj.category)
      ..writeByte(7)
      ..write(obj.images)
      ..writeByte(8)
      ..write(obj.isFeatured)
      ..writeByte(9)
      ..write(obj.isAvailable)
      ..writeByte(10)
      ..write(obj.stock)
      ..writeByte(11)
      ..write(obj.preparationTime)
      ..writeByte(12)
      ..write(obj.deliveryType)
      ..writeByte(13)
      ..write(obj.cachedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
