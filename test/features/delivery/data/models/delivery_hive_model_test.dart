import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_hive_model.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

void main() {
  // ── Fixtures ────────────────────────────────────────────────────────────────
  const tAddress = DeliveryAddressEntity(
    street: '123 Flower Street',
    city: 'Kathmandu',
    state: 'Bagmati',
    zip: '44600',
    country: 'Nepal',
  );

  final tTracking = TrackingUpdateEntity(
    message: 'Order picked up from warehouse',
    timestamp: DateTime(2024, 1, 15, 10),
    updatedBy: 'driver_01',
  );

  final tEntity = DeliveryEntity(
    id: 'delivery_abc',
    orderId: 'order_001',
    recipientName: 'Jane Doe',
    recipientPhone: '9800000000',
    address: tAddress,
    status: DeliveryStatus.inTransit,
    scheduledDate: DateTime(2024, 1, 15, 8),
    estimatedDelivery: DateTime(2024, 1, 15, 14),
    deliveredAt: null,
    trackingUpdates: [tTracking],
    deliveryNotes: 'Ring the bell',
    cancelReason: null,
    cancelledAt: null,
    createdAt: DateTime(2024, 1, 14, 12),
    updatedAt: DateTime(2024, 1, 15, 10),
  );

  // Helper to build a minimal entity for status-only round-trip tests
  DeliveryEntity entityWithStatus(DeliveryStatus status) => DeliveryEntity(
    id: 'x',
    orderId: 'o',
    recipientName: 'Test',
    recipientPhone: '0000000000',
    address: tAddress,
    status: status,
    trackingUpdates: const [],
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
  );

  // ── fromEntity ─────────────────────────────────────────────────────────────
  group('DeliveryHiveModel.fromEntity', () {
    test('should copy all scalar fields correctly', () {
      // Act
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.id, 'delivery_abc');
      expect(model.orderId, 'order_001');
      expect(model.recipientName, 'Jane Doe');
      expect(model.recipientPhone, '9800000000');
      expect(model.deliveryNotes, 'Ring the bell');
      expect(model.cancelReason, isNull);
      expect(model.scheduledDate, DateTime(2024, 1, 15, 8));
      expect(model.estimatedDelivery, DateTime(2024, 1, 15, 14));
      expect(model.deliveredAt, isNull);
      expect(model.createdAt, DateTime(2024, 1, 14, 12));
      expect(model.updatedAt, DateTime(2024, 1, 15, 10));
    });

    test('should store status as enum.name (inTransit, not in_transit)', () {
      // Arrange — inTransit.name == 'inTransit', NOT the API string 'in_transit'
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.status, 'inTransit');
    });

    test('should flatten address into individual fields', () {
      // Act
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.addressStreet, '123 Flower Street');
      expect(model.addressCity, 'Kathmandu');
      expect(model.addressState, 'Bagmati');
      expect(model.addressZip, '44600');
      expect(model.addressCountry, 'Nepal');
    });

    test('should flatten trackingUpdates into three parallel lists', () {
      // Act
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.trackingMessages, ['Order picked up from warehouse']);
      expect(model.trackingTimestamps, [DateTime(2024, 1, 15, 10)]);
      expect(model.trackingUpdatedBy, ['driver_01']);
    });

    test('should store all DeliveryStatus values as their enum.name', () {
      // Arrange + Act + Assert — every status's .name is what Hive stores
      final expectedNames = {
        DeliveryStatus.pending: 'pending',
        DeliveryStatus.assigned: 'assigned',
        DeliveryStatus.inTransit: 'inTransit',
        DeliveryStatus.delivered: 'delivered',
        DeliveryStatus.failed: 'failed',
        DeliveryStatus.cancelled: 'cancelled',
      };
      for (final entry in expectedNames.entries) {
        final model = DeliveryHiveModel.fromEntity(entityWithStatus(entry.key));
        expect(
          model.status,
          entry.value,
          reason: '${entry.key} should be stored as "${entry.value}"',
        );
      }
    });

    test(
      'should produce empty parallel lists when entity has no tracking updates',
      () {
        // Arrange
        final entity = entityWithStatus(DeliveryStatus.pending);

        // Act
        final model = DeliveryHiveModel.fromEntity(entity);

        // Assert
        expect(model.trackingMessages, isEmpty);
        expect(model.trackingTimestamps, isEmpty);
        expect(model.trackingUpdatedBy, isEmpty);
      },
    );

    test('should store null updatedBy in trackingUpdatedBy list', () {
      // Arrange — tracking update without updatedBy
      final entityNoDriver = DeliveryEntity(
        id: 'y',
        orderId: 'o2',
        recipientName: 'Bob',
        recipientPhone: '9900000000',
        address: tAddress,
        status: DeliveryStatus.assigned,
        trackingUpdates: [
          TrackingUpdateEntity(
            message: 'Assigned',
            timestamp: DateTime(2024, 1, 15),
            // updatedBy is null
          ),
        ],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );

      // Act
      final model = DeliveryHiveModel.fromEntity(entityNoDriver);

      // Assert
      expect(model.trackingUpdatedBy, [null]);
    });

    test(
      'should store nullable address state and zip as null when entity has none',
      () {
        // Arrange
        const addrMinimal = DeliveryAddressEntity(
          street: '10 Main',
          city: 'Pokhara',
          // state and zip omitted (null)
          country: 'Nepal',
        );
        final entity = DeliveryEntity(
          id: 'z',
          orderId: 'o3',
          recipientName: 'Alice',
          recipientPhone: '9700000000',
          address: addrMinimal,
          status: DeliveryStatus.pending,
          trackingUpdates: const [],
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        // Act
        final model = DeliveryHiveModel.fromEntity(entity);

        // Assert
        expect(model.addressState, isNull);
        expect(model.addressZip, isNull);
      },
    );
  });

  // ── toEntity ──────────────────────────────────────────────────────────────
  group('DeliveryHiveModel.toEntity', () {
    test('should reconstruct all scalar fields correctly', () {
      // Arrange
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.id, 'delivery_abc');
      expect(entity.orderId, 'order_001');
      expect(entity.recipientName, 'Jane Doe');
      expect(entity.recipientPhone, '9800000000');
      expect(entity.deliveryNotes, 'Ring the bell');
      expect(entity.cancelReason, isNull);
    });

    test(
      'should convert stored "inTransit" back to DeliveryStatus.inTransit',
      () {
        // Arrange — inTransit stored as 'inTransit'; toEntity swaps to 'in_transit'
        final model = DeliveryHiveModel.fromEntity(tEntity);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.status, DeliveryStatus.inTransit);
      },
    );

    test('should survive round-trip for all DeliveryStatus values', () {
      // Arrange + Act + Assert
      for (final status in DeliveryStatus.values) {
        final original = entityWithStatus(status);
        final roundTripped = DeliveryHiveModel.fromEntity(original).toEntity();
        expect(
          roundTripped.status,
          status,
          reason: '$status should survive entity → hive → entity round-trip',
        );
      }
    });

    test('should reconstruct address from flattened fields', () {
      // Arrange
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.address.street, '123 Flower Street');
      expect(entity.address.city, 'Kathmandu');
      expect(entity.address.state, 'Bagmati');
      expect(entity.address.zip, '44600');
      expect(entity.address.country, 'Nepal');
    });

    test('should reconstruct tracking updates from parallel lists', () {
      // Arrange
      final model = DeliveryHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();
      final update = entity.trackingUpdates.first;

      // Assert
      expect(update.message, 'Order picked up from warehouse');
      expect(update.timestamp, DateTime(2024, 1, 15, 10));
      expect(update.updatedBy, 'driver_01');
    });

    test('should reconstruct null updatedBy from parallel lists', () {
      // Arrange
      final entityNoDriver = DeliveryEntity(
        id: 'y',
        orderId: 'o2',
        recipientName: 'Bob',
        recipientPhone: '9900000000',
        address: tAddress,
        status: DeliveryStatus.assigned,
        trackingUpdates: [
          TrackingUpdateEntity(
            message: 'Assigned',
            timestamp: DateTime(2024, 1, 15),
          ),
        ],
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      final model = DeliveryHiveModel.fromEntity(entityNoDriver);

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.trackingUpdates.first.updatedBy, isNull);
    });

    test('should produce empty trackingUpdates list when model had none', () {
      // Arrange
      final entity = entityWithStatus(DeliveryStatus.pending);
      final model = DeliveryHiveModel.fromEntity(entity);

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.trackingUpdates, isEmpty);
    });

    test('full round-trip should preserve all core fields', () {
      // Act
      final result = DeliveryHiveModel.fromEntity(tEntity).toEntity();

      // Assert
      expect(result.id, tEntity.id);
      expect(result.orderId, tEntity.orderId);
      expect(result.status, tEntity.status);
      expect(result.recipientName, tEntity.recipientName);
      expect(result.recipientPhone, tEntity.recipientPhone);
      expect(result.scheduledDate, tEntity.scheduledDate);
      expect(result.estimatedDelivery, tEntity.estimatedDelivery);
      expect(result.trackingUpdates.length, tEntity.trackingUpdates.length);
    });
  });
}
