// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorites_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteItemHiveModelAdapter extends TypeAdapter<FavoriteItemHiveModel> {
  @override
  final int typeId = 3;

  @override
  FavoriteItemHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteItemHiveModel(
      type: fields[0] as String,
      refId: fields[1] as String,
      itemName: fields[2] as String?,
      itemPrice: fields[3] as double?,
      itemDiscountPrice: fields[4] as double?,
      itemImages: (fields[5] as List?)?.cast<String>(),
      itemCategory: fields[6] as String?,
      itemStock: fields[7] as int?,
      itemIsFeatured: fields[8] as bool?,
      itemIsAvailable: fields[9] as bool?,
      itemSlug: fields[10] as String?,
      itemDescription: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteItemHiveModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.refId)
      ..writeByte(2)
      ..write(obj.itemName)
      ..writeByte(3)
      ..write(obj.itemPrice)
      ..writeByte(4)
      ..write(obj.itemDiscountPrice)
      ..writeByte(5)
      ..write(obj.itemImages)
      ..writeByte(6)
      ..write(obj.itemCategory)
      ..writeByte(7)
      ..write(obj.itemStock)
      ..writeByte(8)
      ..write(obj.itemIsFeatured)
      ..writeByte(9)
      ..write(obj.itemIsAvailable)
      ..writeByte(10)
      ..write(obj.itemSlug)
      ..writeByte(11)
      ..write(obj.itemDescription);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteItemHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
