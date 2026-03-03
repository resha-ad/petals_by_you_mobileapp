import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_hive_model.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

abstract interface class IDeliveryLocalDatasource {
  Future<void> saveDelivery(DeliveryEntity entity);
  DeliveryEntity? getDeliveryByOrderId(String orderId);
  Future<void> clearAll();
}

final deliveryLocalDatasourceProvider = Provider<IDeliveryLocalDatasource>((
  ref,
) {
  return DeliveryLocalDatasource();
});

const _kBoxName = 'delivery_table';

class DeliveryLocalDatasource implements IDeliveryLocalDatasource {
  Box<DeliveryHiveModel> get _box => Hive.box<DeliveryHiveModel>(_kBoxName);

  @override
  Future<void> saveDelivery(DeliveryEntity entity) async {
    final model = DeliveryHiveModel.fromEntity(entity);
    // Key by orderId so we can look it up easily
    await _box.put(entity.orderId, model);
  }

  @override
  DeliveryEntity? getDeliveryByOrderId(String orderId) {
    final model = _box.get(orderId);
    return model?.toEntity();
  }

  @override
  Future<void> clearAll() async => await _box.clear();
}
