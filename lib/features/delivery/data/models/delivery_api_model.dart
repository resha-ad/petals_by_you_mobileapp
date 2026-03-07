import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

class TrackingUpdateApiModel {
  final String message;
  final DateTime timestamp;
  final String? updatedBy;

  const TrackingUpdateApiModel({
    required this.message,
    required this.timestamp,
    this.updatedBy,
  });

  factory TrackingUpdateApiModel.fromJson(Map<String, dynamic> json) {
    return TrackingUpdateApiModel(
      message: json['message']?.toString() ?? '',
      timestamp:
          DateTime.tryParse(json['timestamp']?.toString() ?? '') ??
          DateTime.now(),
      updatedBy: json['updatedBy']?.toString(),
    );
  }

  TrackingUpdateEntity toEntity() => TrackingUpdateEntity(
    message: message,
    timestamp: timestamp,
    updatedBy: updatedBy,
  );
}

class DeliveryAddressApiModel {
  final String street;
  final String city;
  final String? state;
  final String? zip;
  final String country;

  const DeliveryAddressApiModel({
    required this.street,
    required this.city,
    this.state,
    this.zip,
    required this.country,
  });

  factory DeliveryAddressApiModel.fromJson(Map<String, dynamic> json) {
    return DeliveryAddressApiModel(
      street: json['street']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      state: json['state']?.toString(),
      zip: json['zip']?.toString(),
      country: json['country']?.toString() ?? 'Nepal',
    );
  }

  DeliveryAddressEntity toEntity() => DeliveryAddressEntity(
    street: street,
    city: city,
    state: state,
    zip: zip,
    country: country,
  );
}

class DeliveryApiModel {
  final String id;
  final String orderId;
  final String recipientName;
  final String recipientPhone;
  final DeliveryAddressApiModel address;
  final String status;
  final DateTime? scheduledDate;
  final DateTime? estimatedDelivery;
  final DateTime? deliveredAt;
  final List<TrackingUpdateApiModel> trackingUpdates;
  final String? deliveryNotes;
  final String? cancelReason;
  final DateTime? cancelledAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const DeliveryApiModel({
    required this.id,
    required this.orderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.status,
    this.scheduledDate,
    this.estimatedDelivery,
    this.deliveredAt,
    required this.trackingUpdates,
    this.deliveryNotes,
    this.cancelReason,
    this.cancelledAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryApiModel.fromJson(Map<String, dynamic> json) {
    // orderId may be a plain string or a populated object
    final rawOrderId = json['orderId'];
    final orderId = rawOrderId is Map
        ? rawOrderId['_id']?.toString() ?? ''
        : rawOrderId?.toString() ?? '';

    final rawUpdates = json['trackingUpdates'] as List<dynamic>? ?? [];

    return DeliveryApiModel(
      id: json['_id']?.toString() ?? '',
      orderId: orderId,
      recipientName: json['recipientName']?.toString() ?? '',
      recipientPhone: json['recipientPhone']?.toString() ?? '',
      address: DeliveryAddressApiModel.fromJson(
        json['address'] as Map<String, dynamic>? ?? {},
      ),
      status: json['status']?.toString() ?? 'pending',
      scheduledDate: json['scheduledDate'] != null
          ? DateTime.tryParse(json['scheduledDate'].toString())
          : null,
      estimatedDelivery: json['estimatedDelivery'] != null
          ? DateTime.tryParse(json['estimatedDelivery'].toString())
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.tryParse(json['deliveredAt'].toString())
          : null,
      trackingUpdates: rawUpdates
          .map(
            (e) => TrackingUpdateApiModel.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      deliveryNotes: json['deliveryNotes']?.toString(),
      cancelReason: json['cancelReason']?.toString(),
      cancelledAt: json['cancelledAt'] != null
          ? DateTime.tryParse(json['cancelledAt'].toString())
          : null,
      createdAt:
          DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  DeliveryEntity toEntity() => DeliveryEntity(
    id: id,
    orderId: orderId,
    recipientName: recipientName,
    recipientPhone: recipientPhone,
    address: address.toEntity(),
    status: DeliveryStatus.fromString(status),
    scheduledDate: scheduledDate,
    estimatedDelivery: estimatedDelivery,
    deliveredAt: deliveredAt,
    trackingUpdates: trackingUpdates.map((u) => u.toEntity()).toList(),
    deliveryNotes: deliveryNotes,
    cancelReason: cancelReason,
    cancelledAt: cancelledAt,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}
