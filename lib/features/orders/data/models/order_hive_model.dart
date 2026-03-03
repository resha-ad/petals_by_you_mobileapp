import 'package:hive/hive.dart';
import 'package:sprint1_project/core/constants/hive_table_constants.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

part 'order_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.orderTypeId)
class OrderHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final double totalAmount;

  @HiveField(2)
  final String status; // stored as string

  @HiveField(3)
  final String paymentStatus;

  @HiveField(4)
  final String paymentMethod;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final String? cancelReason;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime updatedAt;

  // Flattened items (stored as parallel lists to avoid nested type adapters)
  @HiveField(9)
  final List<String> itemTypes;

  @HiveField(10)
  final List<String> itemRefIds;

  @HiveField(11)
  final List<String> itemNames;

  @HiveField(12)
  final List<double> itemUnitPrices;

  @HiveField(13)
  final List<int> itemQuantities;

  @HiveField(14)
  final List<double> itemSubtotals;

  @HiveField(15)
  final List<String?> itemImageUrls;

  OrderHiveModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.notes,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
    required this.itemTypes,
    required this.itemRefIds,
    required this.itemNames,
    required this.itemUnitPrices,
    required this.itemQuantities,
    required this.itemSubtotals,
    required this.itemImageUrls,
  });

  factory OrderHiveModel.fromEntity(OrderEntity entity) {
    return OrderHiveModel(
      id: entity.id,
      totalAmount: entity.totalAmount,
      status: entity.status.name,
      paymentStatus: entity.paymentStatus,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      cancelReason: entity.cancelReason,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      itemTypes: entity.items.map((i) => i.type).toList(),
      itemRefIds: entity.items.map((i) => i.refId).toList(),
      itemNames: entity.items.map((i) => i.name).toList(),
      itemUnitPrices: entity.items.map((i) => i.unitPrice).toList(),
      itemQuantities: entity.items.map((i) => i.quantity).toList(),
      itemSubtotals: entity.items.map((i) => i.subtotal).toList(),
      itemImageUrls: entity.items.map((i) => i.imageUrl).toList(),
    );
  }

  OrderEntity toEntity() {
    final items = List.generate(
      itemTypes.length,
      (i) => OrderItemEntity(
        type: itemTypes[i],
        refId: itemRefIds[i],
        name: itemNames[i],
        unitPrice: itemUnitPrices[i],
        quantity: itemQuantities[i],
        subtotal: itemSubtotals[i],
        imageUrl: itemImageUrls[i],
      ),
    );

    // Map stored string back to enum — handle both 'outForDelivery' (enum.name)
    // and 'out_for_delivery' (API string) for robustness
    String rawStatus = status;
    if (rawStatus == 'outForDelivery') rawStatus = 'out_for_delivery';

    return OrderEntity(
      id: id,
      items: items,
      totalAmount: totalAmount,
      status: OrderStatus.fromString(rawStatus),
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      notes: notes,
      cancelReason: cancelReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
