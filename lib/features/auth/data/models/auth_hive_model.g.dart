// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_hive_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthHiveModelAdapter extends TypeAdapter<AuthHiveModel> {
  @override
  final int typeId = 1;

  @override
  AuthHiveModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthHiveModel(
      authId: fields[0] as String?,
      fullName: fields[1] as String,
      email: fields[2] as String,
      username: fields[3] as String?,
      password: fields[4] as String?,
      phoneNumber: fields[5] as String?,
      profilePicture: fields[6] as String?,
      address: fields[7] as String?,
      dateOfBirth: fields[8] as String?,
      preferredDeliveryTime: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AuthHiveModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.authId)
      ..writeByte(1)
      ..write(obj.fullName)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.password)
      ..writeByte(5)
      ..write(obj.phoneNumber)
      ..writeByte(6)
      ..write(obj.profilePicture)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.dateOfBirth)
      ..writeByte(9)
      ..write(obj.preferredDeliveryTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthHiveModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
