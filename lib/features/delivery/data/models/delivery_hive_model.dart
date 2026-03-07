import 'package:hive/hive.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

part 'delivery_hive_model.g.dart';

// typeId = 6  (auth=1, items=2, favorites=3, cart=4, orders=5, delivery=6)
@HiveType(typeId: 6)
class DeliveryHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String orderId;

  @HiveField(2)
  final String recipientName;

  @HiveField(3)
  final String recipientPhone;

  // Address fields (flattened — no nested type adapter needed)
  @HiveField(4)
  final String addressStreet;

  @HiveField(5)
  final String addressCity;

  @HiveField(6)
  final String? addressState;

  @HiveField(7)
  final String? addressZip;

  @HiveField(8)
  final String addressCountry;

  @HiveField(9)
  final String status;

  @HiveField(10)
  final DateTime? scheduledDate;

  @HiveField(11)
  final DateTime? estimatedDelivery;

  @HiveField(12)
  final DateTime? deliveredAt;

  // Tracking updates stored as parallel lists to avoid nested adapters
  @HiveField(13)
  final List<String> trackingMessages;

  @HiveField(14)
  final List<DateTime> trackingTimestamps;

  @HiveField(15)
  final List<String?> trackingUpdatedBy;

  @HiveField(16)
  final String? deliveryNotes;

  @HiveField(17)
  final String? cancelReason;

  @HiveField(18)
  final DateTime? cancelledAt;

  @HiveField(19)
  final DateTime createdAt;

  @HiveField(20)
  final DateTime updatedAt;

  DeliveryHiveModel({
    required this.id,
    required this.orderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.addressStreet,
    required this.addressCity,
    this.addressState,
    this.addressZip,
    required this.addressCountry,
    required this.status,
    this.scheduledDate,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.trackingMessages,
    required this.trackingTimestamps,
    required this.trackingUpdatedBy,
    this.deliveryNotes,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryHiveModel.fromEntity(DeliveryEntity entity) {
    return DeliveryHiveModel(
      id: entity.id,
      orderId: entity.orderId,
      recipientName: entity.recipientName,
      recipientPhone: entity.recipientPhone,
      addressStreet: entity.address.street,
      addressCity: entity.address.city,
      addressState: entity.address.state,
      addressZip: entity.address.zip,
      addressCountry: entity.address.country,
      status: entity.status.name, // e.g. "inTransit"
      scheduledDate: entity.scheduledDate,
      estimatedDelivery: entity.estimatedDelivery,
      deliveredAt: entity.deliveredAt,
      trackingMessages: entity.trackingUpdates.map((u) => u.message).toList(),
      trackingTimestamps: entity.trackingUpdates
          .map((u) => u.timestamp)
          .toList(),
      trackingUpdatedBy: entity.trackingUpdates
          .map((u) => u.updatedBy)
          .toList(),
      deliveryNotes: entity.deliveryNotes,
      cancelReason: entity.cancelReason,
      cancelledAt: entity.cancelledAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  DeliveryEntity toEntity() {
    final updates = List.generate(
      trackingMessages.length,
      (i) => TrackingUpdateEntity(
        message: trackingMessages[i],
        timestamp: trackingTimestamps[i],
        updatedBy: trackingUpdatedBy[i],
      ),
    );

    // Map stored enum name back to DeliveryStatus
    // Handles both camelCase enum names ('inTransit') and API snake_case ('in_transit')
    String rawStatus = status;
    if (rawStatus == 'inTransit') rawStatus = 'in_transit';

    return DeliveryEntity(
      id: id,
      orderId: orderId,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
      address: DeliveryAddressEntity(
        street: addressStreet,
        city: addressCity,
        state: addressState,
        zip: addressZip,
        country: addressCountry,
      ),
      status: DeliveryStatus.fromString(rawStatus),
      scheduledDate: scheduledDate,
      estimatedDelivery: estimatedDelivery,
      deliveredAt: deliveredAt,
      trackingUpdates: updates,
      deliveryNotes: deliveryNotes,
      cancelReason: cancelReason,
      cancelledAt: cancelledAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
