import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/delivery/data/models/delivery_api_model.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';

void main() {
  // ── Shared fixtures ────────────────────────────────────────────────────────
  final tTrackingJson = <String, dynamic>{
    'message': 'Order picked up from warehouse',
    'timestamp': '2024-01-15T10:00:00.000Z',
    'updatedBy': 'driver_01',
  };

  final tAddressJson = <String, dynamic>{
    'street': '123 Flower Street',
    'city': 'Kathmandu',
    'state': 'Bagmati',
    'zip': '44600',
    'country': 'Nepal',
  };

  final tDeliveryJson = <String, dynamic>{
    '_id': 'delivery_abc',
    'orderId': 'order_001',
    'recipientName': 'Jane Doe',
    'recipientPhone': '9800000000',
    'address': tAddressJson,
    'status': 'in_transit',
    'scheduledDate': '2024-01-15T08:00:00.000Z',
    'estimatedDelivery': '2024-01-15T14:00:00.000Z',
    'deliveredAt': null,
    'trackingUpdates': [tTrackingJson],
    'deliveryNotes': 'Ring the bell',
    'cancelReason': null,
    'cancelledAt': null,
    'createdAt': '2024-01-14T12:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
  };

  // ── TrackingUpdateApiModel ─────────────────────────────────────────────────
  group('TrackingUpdateApiModel', () {
    group('fromJson', () {
      test('should parse all fields from full JSON', () {
        // Act
        final model = TrackingUpdateApiModel.fromJson(tTrackingJson);

        // Assert
        expect(model.message, 'Order picked up from warehouse');
        expect(model.timestamp, isA<DateTime>());
        expect(model.updatedBy, 'driver_01');
      });

      test('should default message to empty string when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tTrackingJson)
          ..remove('message');

        // Act
        final model = TrackingUpdateApiModel.fromJson(json);

        // Assert
        expect(model.message, '');
      });

      test('should set updatedBy to null when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tTrackingJson)
          ..remove('updatedBy');

        // Act
        final model = TrackingUpdateApiModel.fromJson(json);

        // Assert
        expect(model.updatedBy, isNull);
      });

      test(
        'should fall back to DateTime.now() for an unparseable timestamp',
        () {
          // Arrange
          final json = Map<String, dynamic>.from(tTrackingJson);
          json['timestamp'] = 'not-a-date';
          final before = DateTime.now();

          // Act
          final model = TrackingUpdateApiModel.fromJson(json);

          // Assert — timestamp should be very close to now()
          expect(
            model.timestamp.isAfter(
              before.subtract(const Duration(seconds: 1)),
            ),
            isTrue,
          );
        },
      );
    });

    group('toEntity', () {
      test(
        'should produce a TrackingUpdateEntity with all matching fields',
        () {
          // Arrange
          final model = TrackingUpdateApiModel.fromJson(tTrackingJson);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, isA<TrackingUpdateEntity>());
          expect(entity.message, 'Order picked up from warehouse');
          expect(entity.timestamp, isA<DateTime>());
          expect(entity.updatedBy, 'driver_01');
        },
      );

      test('should carry null updatedBy through to entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(tTrackingJson)
          ..remove('updatedBy');
        final model = TrackingUpdateApiModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.updatedBy, isNull);
      });
    });
  });

  // ── DeliveryAddressApiModel ────────────────────────────────────────────────
  group('DeliveryAddressApiModel', () {
    group('fromJson', () {
      test('should parse all fields from a full JSON object', () {
        // Act
        final model = DeliveryAddressApiModel.fromJson(tAddressJson);

        // Assert
        expect(model.street, '123 Flower Street');
        expect(model.city, 'Kathmandu');
        expect(model.state, 'Bagmati');
        expect(model.zip, '44600');
        expect(model.country, 'Nepal');
      });

      test('should default country to "Nepal" when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tAddressJson)..remove('country');

        // Act
        final model = DeliveryAddressApiModel.fromJson(json);

        // Assert
        expect(model.country, 'Nepal');
      });

      test('should set state to null when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tAddressJson)..remove('state');

        // Act
        final model = DeliveryAddressApiModel.fromJson(json);

        // Assert
        expect(model.state, isNull);
      });

      test('should set zip to null when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tAddressJson)..remove('zip');

        // Act
        final model = DeliveryAddressApiModel.fromJson(json);

        // Assert
        expect(model.zip, isNull);
      });

      test('should default street and city to empty string when absent', () {
        // Arrange — completely empty JSON
        final json = <String, dynamic>{};

        // Act
        final model = DeliveryAddressApiModel.fromJson(json);

        // Assert
        expect(model.street, '');
        expect(model.city, '');
        expect(model.country, 'Nepal'); // default
      });
    });

    group('toEntity', () {
      test(
        'should return a DeliveryAddressEntity with all matching fields',
        () {
          // Arrange
          final model = DeliveryAddressApiModel.fromJson(tAddressJson);

          // Act
          final entity = model.toEntity();

          // Assert
          expect(entity, isA<DeliveryAddressEntity>());
          expect(entity.street, '123 Flower Street');
          expect(entity.city, 'Kathmandu');
          expect(entity.state, 'Bagmati');
          expect(entity.zip, '44600');
          expect(entity.country, 'Nepal');
        },
      );

      test('should carry null state through to entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(tAddressJson)..remove('state');
        final model = DeliveryAddressApiModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.state, isNull);
      });
    });
  });

  // ── DeliveryApiModel ───────────────────────────────────────────────────────
  group('DeliveryApiModel', () {
    group('fromJson', () {
      test('should parse all fields from a complete JSON object', () {
        // Act
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Assert
        expect(model.id, 'delivery_abc');
        expect(model.orderId, 'order_001');
        expect(model.recipientName, 'Jane Doe');
        expect(model.recipientPhone, '9800000000');
        expect(model.status, 'in_transit');
        expect(model.trackingUpdates.length, 1);
        expect(model.deliveryNotes, 'Ring the bell');
        expect(model.cancelReason, isNull);
        expect(model.cancelledAt, isNull);
        expect(model.createdAt, isA<DateTime>());
        expect(model.updatedAt, isA<DateTime>());
      });

      test('should parse scheduledDate and estimatedDelivery as DateTime', () {
        // Act
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Assert
        expect(model.scheduledDate, isA<DateTime>());
        expect(model.estimatedDelivery, isA<DateTime>());
      });

      test('should leave scheduledDate null when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson)
          ..remove('scheduledDate');

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.scheduledDate, isNull);
      });

      test('should leave estimatedDelivery null when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson)
          ..remove('estimatedDelivery');

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.estimatedDelivery, isNull);
      });

      test('should parse deliveredAt as DateTime when present', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson);
        json['deliveredAt'] = '2024-01-15T16:00:00.000Z';
        json['status'] = 'delivered';

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.deliveredAt, isA<DateTime>());
        expect(model.deliveredAt!.hour, 16);
      });

      test('should extract orderId from a populated Map orderId field', () {
        // Arrange — backend sometimes returns orderId as a populated object
        final json = Map<String, dynamic>.from(tDeliveryJson);
        json['orderId'] = {'_id': 'order_from_map', 'status': 'pending'};

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.orderId, 'order_from_map');
      });

      test('should extract orderId directly when it is a plain string', () {
        // Act
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Assert
        expect(model.orderId, 'order_001');
      });

      test('should default id to empty string when _id is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson)..remove('_id');

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.id, '');
      });

      test('should default status to "pending" when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson)..remove('status');

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.status, 'pending');
      });

      test('should handle an empty trackingUpdates list', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson);
        json['trackingUpdates'] = <dynamic>[];

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.trackingUpdates, isEmpty);
      });

      test('should parse multiple tracking updates', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson);
        json['trackingUpdates'] = [tTrackingJson, tTrackingJson];

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.trackingUpdates.length, 2);
      });

      test('should use empty map for address when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson)
          ..remove('address');

        // Act — should not throw; defaults to empty address
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.address.street, '');
        expect(model.address.city, '');
        expect(model.address.country, 'Nepal');
      });

      test('should parse cancelledAt when present', () {
        // Arrange
        final json = Map<String, dynamic>.from(tDeliveryJson);
        json['cancelledAt'] = '2024-01-16T09:00:00.000Z';
        json['status'] = 'cancelled';

        // Act
        final model = DeliveryApiModel.fromJson(json);

        // Assert
        expect(model.cancelledAt, isA<DateTime>());
        expect(model.cancelledAt!.day, 16);
      });
    });

    group('toEntity', () {
      test('should convert to DeliveryEntity with all correct fields', () {
        // Arrange
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<DeliveryEntity>());
        expect(entity.id, 'delivery_abc');
        expect(entity.orderId, 'order_001');
        expect(entity.recipientName, 'Jane Doe');
        expect(entity.recipientPhone, '9800000000');
        expect(entity.status, DeliveryStatus.inTransit);
        expect(entity.trackingUpdates.length, 1);
        expect(entity.deliveryNotes, 'Ring the bell');
      });

      test(
        'should map all API status strings to correct DeliveryStatus values',
        () {
          // Arrange
          final statusMap = {
            'pending': DeliveryStatus.pending,
            'assigned': DeliveryStatus.assigned,
            'in_transit': DeliveryStatus.inTransit,
            'delivered': DeliveryStatus.delivered,
            'failed': DeliveryStatus.failed,
            'cancelled': DeliveryStatus.cancelled,
          };

          // Act + Assert
          for (final entry in statusMap.entries) {
            final json = Map<String, dynamic>.from(tDeliveryJson);
            json['status'] = entry.key;
            final entity = DeliveryApiModel.fromJson(json).toEntity();
            expect(
              entity.status,
              entry.value,
              reason: '"${entry.key}" should map to ${entry.value}',
            );
          }
        },
      );

      test('should convert address to DeliveryAddressEntity', () {
        // Arrange
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.address, isA<DeliveryAddressEntity>());
        expect(entity.address.street, '123 Flower Street');
        expect(entity.address.city, 'Kathmandu');
      });

      test('should convert trackingUpdates to List<TrackingUpdateEntity>', () {
        // Arrange
        final model = DeliveryApiModel.fromJson(tDeliveryJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.trackingUpdates.first, isA<TrackingUpdateEntity>());
        expect(
          entity.trackingUpdates.first.message,
          'Order picked up from warehouse',
        );
      });
    });
  });

  // ── DeliveryStatus ─────────────────────────────────────────────────────────
  group('DeliveryStatus', () {
    group('fromString', () {
      test('should map each known API string to the correct enum value', () {
        // Assert — 'pending' falls through to default, others are explicit cases
        expect(DeliveryStatus.fromString('pending'), DeliveryStatus.pending);
        expect(DeliveryStatus.fromString('assigned'), DeliveryStatus.assigned);
        expect(
          DeliveryStatus.fromString('in_transit'),
          DeliveryStatus.inTransit,
        );
        expect(
          DeliveryStatus.fromString('delivered'),
          DeliveryStatus.delivered,
        );
        expect(DeliveryStatus.fromString('failed'), DeliveryStatus.failed);
        expect(
          DeliveryStatus.fromString('cancelled'),
          DeliveryStatus.cancelled,
        );
      });

      test('should return pending for unknown strings', () {
        expect(DeliveryStatus.fromString('unknown'), DeliveryStatus.pending);
        expect(DeliveryStatus.fromString(''), DeliveryStatus.pending);
        // enum.name 'inTransit' is NOT the API string — it falls to default
        expect(DeliveryStatus.fromString('inTransit'), DeliveryStatus.pending);
      });
    });

    group('displayLabel', () {
      test('should return correct human-readable label for each status', () {
        expect(DeliveryStatus.pending.displayLabel, 'Pending');
        expect(DeliveryStatus.assigned.displayLabel, 'Assigned');
        expect(DeliveryStatus.inTransit.displayLabel, 'Out for Delivery');
        expect(DeliveryStatus.delivered.displayLabel, 'Delivered');
        expect(DeliveryStatus.failed.displayLabel, 'Failed');
        expect(DeliveryStatus.cancelled.displayLabel, 'Cancelled');
      });
    });
  });

  // ── DeliveryEntity ─────────────────────────────────────────────────────────
  group('DeliveryEntity', () {
    const tAddress = DeliveryAddressEntity(
      street: '123 Flower St',
      city: 'Kathmandu',
      country: 'Nepal',
    );

    DeliveryEntity makeEntity({
      String id = 'delivery_001',
      String orderId = 'order_001',
      DeliveryStatus status = DeliveryStatus.pending,
    }) {
      return DeliveryEntity(
        id: id,
        orderId: orderId,
        recipientName: 'Jane',
        recipientPhone: '9800000000',
        address: tAddress,
        status: status,
        trackingUpdates: const [],
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    }

    group('isActive', () {
      test('should be true for pending, assigned, and inTransit', () {
        for (final status in [
          DeliveryStatus.pending,
          DeliveryStatus.assigned,
          DeliveryStatus.inTransit,
        ]) {
          expect(
            makeEntity(status: status).isActive,
            isTrue,
            reason: '$status should be active',
          );
        }
      });

      test('should be false for delivered, failed, and cancelled', () {
        for (final status in [
          DeliveryStatus.delivered,
          DeliveryStatus.failed,
          DeliveryStatus.cancelled,
        ]) {
          expect(
            makeEntity(status: status).isActive,
            isFalse,
            reason: '$status should not be active',
          );
        }
      });
    });

    group('Equatable', () {
      test('props should be [id, orderId, status]', () {
        final entity = makeEntity();
        expect(entity.props, [
          'delivery_001',
          'order_001',
          DeliveryStatus.pending,
        ]);
      });

      test('two entities with same id/orderId/status should be equal', () {
        expect(makeEntity(), equals(makeEntity()));
      });

      test('entities with different id should not be equal', () {
        expect(
          makeEntity(id: 'delivery_001'),
          isNot(equals(makeEntity(id: 'delivery_002'))),
        );
      });

      test('entities with different status should not be equal', () {
        expect(
          makeEntity(status: DeliveryStatus.pending),
          isNot(equals(makeEntity(status: DeliveryStatus.delivered))),
        );
      });
    });
  });

  // ── DeliveryAddressEntity ──────────────────────────────────────────────────
  group('DeliveryAddressEntity', () {
    test(
      'displayAddress should join all non-null, non-empty parts with ", "',
      () {
        // Arrange
        const addr = DeliveryAddressEntity(
          street: '123 Flower St',
          city: 'Kathmandu',
          state: 'Bagmati',
          country: 'Nepal',
        );

        // Act + Assert
        expect(addr.displayAddress, '123 Flower St, Kathmandu, Bagmati, Nepal');
      },
    );

    test('displayAddress should omit state when it is null', () {
      // Arrange
      const addr = DeliveryAddressEntity(
        street: '456 Rose Ave',
        city: 'Pokhara',
        // state omitted (null)
        country: 'Nepal',
      );

      // Act + Assert — state is not included when null
      expect(addr.displayAddress, '456 Rose Ave, Pokhara, Nepal');
    });

    test('displayAddress should skip empty street parts', () {
      // Arrange
      const addr = DeliveryAddressEntity(
        street: '',
        city: 'Lalitpur',
        country: 'Nepal',
      );

      // Act + Assert — empty string filtered out by .where((p) => p.isNotEmpty)
      expect(addr.displayAddress, 'Lalitpur, Nepal');
    });

    test('props should contain [street, city, state, zip, country]', () {
      // Arrange
      const addr = DeliveryAddressEntity(
        street: '123 Flower St',
        city: 'Kathmandu',
        state: 'Bagmati',
        zip: '44600',
        country: 'Nepal',
      );

      // Assert
      expect(addr.props, [
        '123 Flower St',
        'Kathmandu',
        'Bagmati',
        '44600',
        'Nepal',
      ]);
    });

    test('two addresses with identical values should be equal', () {
      const a1 = DeliveryAddressEntity(
        street: '123 Main',
        city: 'Ktm',
        country: 'Nepal',
      );
      const a2 = DeliveryAddressEntity(
        street: '123 Main',
        city: 'Ktm',
        country: 'Nepal',
      );
      expect(a1, equals(a2));
    });

    test('addresses with different city should not be equal', () {
      const a1 = DeliveryAddressEntity(
        street: '123 Main',
        city: 'Ktm',
        country: 'Nepal',
      );
      const a2 = DeliveryAddressEntity(
        street: '123 Main',
        city: 'Pokhara',
        country: 'Nepal',
      );
      expect(a1, isNot(equals(a2)));
    });
  });

  // ── TrackingUpdateEntity ───────────────────────────────────────────────────
  group('TrackingUpdateEntity', () {
    test('props should be [message, timestamp] — updatedBy is excluded', () {
      // Arrange
      final ts = DateTime(2024, 1, 15, 10);
      final entity = TrackingUpdateEntity(
        message: 'Picked up',
        timestamp: ts,
        updatedBy: 'driver_01',
      );

      // Assert — updatedBy is NOT in props per source
      expect(entity.props, ['Picked up', ts]);
    });

    test('two updates with same message and timestamp should be equal '
        'regardless of updatedBy', () {
      final ts = DateTime(2024, 1, 15, 10);
      final u1 = TrackingUpdateEntity(
        message: 'Picked up',
        timestamp: ts,
        updatedBy: 'driver_A',
      );
      final u2 = TrackingUpdateEntity(
        message: 'Picked up',
        timestamp: ts,
        updatedBy: 'driver_B', // different but NOT in props
      );
      expect(u1, equals(u2));
    });

    test('updates with different messages should not be equal', () {
      final ts = DateTime(2024, 1, 15, 10);
      final u1 = TrackingUpdateEntity(message: 'Picked up', timestamp: ts);
      final u2 = TrackingUpdateEntity(message: 'Delivered', timestamp: ts);
      expect(u1, isNot(equals(u2)));
    });

    test('updates with different timestamps should not be equal', () {
      final u1 = TrackingUpdateEntity(
        message: 'Picked up',
        timestamp: DateTime(2024, 1, 15, 10),
      );
      final u2 = TrackingUpdateEntity(
        message: 'Picked up',
        timestamp: DateTime(2024, 1, 15, 12),
      );
      expect(u1, isNot(equals(u2)));
    });
  });
}
