import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/orders/data/models/orders_api_model.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

void main() {
  // ── Shared fixtures ────────────────────────────────────────────────────────
  final tItemJson = <String, dynamic>{
    'type': 'product',
    'refId': 'ref_001',
    'name': 'Red Roses Bouquet',
    'unitPrice': 1500,
    'quantity': 2,
    'subtotal': 3000,
    'imageUrl': '/uploads/roses.jpg',
  };

  final tOrderJson = <String, dynamic>{
    '_id': 'order_abc123',
    'items': [tItemJson],
    'totalAmount': 3000,
    'status': 'pending',
    'paymentStatus': 'unpaid',
    'paymentMethod': 'cash_on_delivery',
    'notes': 'Please deliver in the morning',
    'cancelReason': null,
    'cancelledAt': null,
    'createdAt': '2024-01-15T10:00:00.000Z',
    'updatedAt': '2024-01-15T10:00:00.000Z',
  };

  // ── OrderItemApiModel ──────────────────────────────────────────────────────
  group('OrderItemApiModel', () {
    group('fromJson', () {
      test('should parse all fields from full JSON', () {
        // Act
        final model = OrderItemApiModel.fromJson(tItemJson);

        // Assert
        expect(model.type, 'product');
        expect(model.refId, 'ref_001');
        expect(model.name, 'Red Roses Bouquet');
        expect(model.unitPrice, 1500.0);
        expect(model.quantity, 2);
        expect(model.subtotal, 3000.0);
        expect(model.imageUrl, '/uploads/roses.jpg');
      });

      test('should default type to "product" when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson)..remove('type');

        // Act
        final model = OrderItemApiModel.fromJson(json);

        // Assert
        expect(model.type, 'product');
      });

      test('should handle null imageUrl', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson);
        json['imageUrl'] = null;

        // Act
        final model = OrderItemApiModel.fromJson(json);

        // Assert
        expect(model.imageUrl, isNull);
      });

      test(
        'should coerce integer unitPrice to double via (num).toDouble()',
        () {
          // Arrange
          final json = Map<String, dynamic>.from(tItemJson);
          json['unitPrice'] = 1500; // int, not double

          // Act
          final model = OrderItemApiModel.fromJson(json);

          // Assert
          expect(model.unitPrice, 1500.0);
          expect(model.unitPrice, isA<double>());
        },
      );

      test('should default quantity to 1 when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson)..remove('quantity');

        // Act
        final model = OrderItemApiModel.fromJson(json);

        // Assert
        expect(model.quantity, 1);
      });

      test('should default refId to empty string when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson)..remove('refId');

        // Act
        final model = OrderItemApiModel.fromJson(json);

        // Assert
        expect(model.refId, '');
      });

      test('should default unitPrice to 0.0 when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson)..remove('unitPrice');

        // Act
        final model = OrderItemApiModel.fromJson(json);

        // Assert
        expect(model.unitPrice, 0.0);
      });
    });

    group('toEntity', () {
      test('should return an OrderItemEntity with all matching fields', () {
        // Arrange
        final model = OrderItemApiModel.fromJson(tItemJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<OrderItemEntity>());
        expect(entity.type, 'product');
        expect(entity.refId, 'ref_001');
        expect(entity.name, 'Red Roses Bouquet');
        expect(entity.unitPrice, 1500.0);
        expect(entity.quantity, 2);
        expect(entity.subtotal, 3000.0);
        expect(entity.imageUrl, '/uploads/roses.jpg');
      });

      test('should carry null imageUrl through to entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(tItemJson);
        json['imageUrl'] = null;
        final model = OrderItemApiModel.fromJson(json);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.imageUrl, isNull);
      });
    });
  });

  // ── OrderApiModel ──────────────────────────────────────────────────────────
  group('OrderApiModel', () {
    group('fromJson', () {
      test('should parse all fields from a complete JSON object', () {
        // Act
        final model = OrderApiModel.fromJson(tOrderJson);

        // Assert
        expect(model.id, 'order_abc123');
        expect(model.items.length, 1);
        expect(model.totalAmount, 3000.0);
        expect(model.status, 'pending');
        expect(model.paymentStatus, 'unpaid');
        expect(model.paymentMethod, 'cash_on_delivery');
        expect(model.notes, 'Please deliver in the morning');
        expect(model.cancelReason, isNull);
        expect(model.cancelledAt, isNull);
        expect(model.createdAt, isA<DateTime>());
        expect(model.updatedAt, isA<DateTime>());
      });

      test('should parse nested item correctly', () {
        // Act
        final model = OrderApiModel.fromJson(tOrderJson);
        final item = model.items.first;

        // Assert
        expect(item.name, 'Red Roses Bouquet');
        expect(item.quantity, 2);
        expect(item.unitPrice, 1500.0);
      });

      test('should default id to empty string when _id is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson)..remove('_id');

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.id, '');
      });

      test('should default status to "pending" when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson)..remove('status');

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.status, 'pending');
      });

      test('should default paymentStatus to "unpaid" when key is absent', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson)
          ..remove('paymentStatus');

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.paymentStatus, 'unpaid');
      });

      test(
        'should default paymentMethod to "cash_on_delivery" when key is absent',
        () {
          // Arrange
          final json = Map<String, dynamic>.from(tOrderJson)
            ..remove('paymentMethod');

          // Act
          final model = OrderApiModel.fromJson(json);

          // Assert
          expect(model.paymentMethod, 'cash_on_delivery');
        },
      );

      test('should handle empty items list', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['items'] = <dynamic>[];

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.items, isEmpty);
      });

      test('should parse a list of multiple items', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['items'] = [tItemJson, tItemJson];

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.items.length, 2);
      });

      test('should parse cancelledAt into DateTime when present', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['cancelledAt'] = '2024-01-16T12:00:00.000Z';

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.cancelledAt, isA<DateTime>());
        expect(model.cancelledAt!.year, 2024);
        expect(model.cancelledAt!.month, 1);
        expect(model.cancelledAt!.day, 16);
      });

      test('should leave cancelledAt null when JSON value is null', () {
        // Act
        final model = OrderApiModel.fromJson(tOrderJson);

        // Assert
        expect(model.cancelledAt, isNull);
      });

      test('should coerce integer totalAmount to double', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['totalAmount'] = 3000; // int

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.totalAmount, 3000.0);
        expect(model.totalAmount, isA<double>());
      });

      test('should parse cancelReason string when present', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['cancelReason'] = 'Changed my mind';
        json['status'] = 'cancelled';

        // Act
        final model = OrderApiModel.fromJson(json);

        // Assert
        expect(model.cancelReason, 'Changed my mind');
      });
    });

    group('toEntity', () {
      test('should convert to OrderEntity with all correct fields', () {
        // Arrange
        final model = OrderApiModel.fromJson(tOrderJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity, isA<OrderEntity>());
        expect(entity.id, 'order_abc123');
        expect(entity.totalAmount, 3000.0);
        expect(entity.status, OrderStatus.pending);
        expect(entity.paymentStatus, 'unpaid');
        expect(entity.paymentMethod, 'cash_on_delivery');
        expect(entity.notes, 'Please deliver in the morning');
        expect(entity.cancelReason, isNull);
        expect(entity.items.length, 1);
      });

      test('should map all API status strings to correct enum values', () {
        // Arrange
        final statusMap = {
          'pending': OrderStatus.pending,
          'confirmed': OrderStatus.confirmed,
          'preparing': OrderStatus.preparing,
          'out_for_delivery': OrderStatus.outForDelivery,
          'delivered': OrderStatus.delivered,
          'cancelled': OrderStatus.cancelled,
        };

        // Act + Assert
        for (final entry in statusMap.entries) {
          final json = Map<String, dynamic>.from(tOrderJson);
          json['status'] = entry.key;
          final entity = OrderApiModel.fromJson(json).toEntity();
          expect(
            entity.status,
            entry.value,
            reason: '"${entry.key}" should map to ${entry.value}',
          );
        }
      });

      test('should convert items to List<OrderItemEntity>', () {
        // Arrange
        final model = OrderApiModel.fromJson(tOrderJson);

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.items.first, isA<OrderItemEntity>());
        expect(entity.items.first.name, 'Red Roses Bouquet');
      });

      test('isCancellable should be true for pending entity', () {
        // Arrange
        final model = OrderApiModel.fromJson(tOrderJson); // status='pending'

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.isCancellable, isTrue);
      });

      test('isCancellable should be false for confirmed entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['status'] = 'confirmed';

        // Act
        final entity = OrderApiModel.fromJson(json).toEntity();

        // Assert
        expect(entity.isCancellable, isFalse);
      });

      test('cancelledAt should be preserved in entity', () {
        // Arrange
        final json = Map<String, dynamic>.from(tOrderJson);
        json['cancelledAt'] = '2024-01-16T12:00:00.000Z';
        json['status'] = 'cancelled';

        // Act
        final entity = OrderApiModel.fromJson(json).toEntity();

        // Assert
        expect(entity.cancelledAt, isA<DateTime>());
      });
    });
  });

  // ── OrderStatus ────────────────────────────────────────────────────────────
  group('OrderStatus', () {
    group('fromString', () {
      test('should map each known API string to its enum value', () {
        expect(OrderStatus.fromString('pending'), OrderStatus.pending);
        expect(OrderStatus.fromString('confirmed'), OrderStatus.confirmed);
        expect(OrderStatus.fromString('preparing'), OrderStatus.preparing);
        expect(
          OrderStatus.fromString('out_for_delivery'),
          OrderStatus.outForDelivery,
        );
        expect(OrderStatus.fromString('delivered'), OrderStatus.delivered);
        expect(OrderStatus.fromString('cancelled'), OrderStatus.cancelled);
      });

      test('should return OrderStatus.pending for unknown strings', () {
        expect(OrderStatus.fromString('unknown'), OrderStatus.pending);
        expect(OrderStatus.fromString(''), OrderStatus.pending);
        // Note: enum.name 'outForDelivery' is NOT a known API string in fromString
        expect(OrderStatus.fromString('PENDING'), OrderStatus.pending);
      });
    });

    group('displayLabel', () {
      test('should return correct human-readable label for each status', () {
        expect(OrderStatus.pending.displayLabel, 'Pending');
        expect(OrderStatus.confirmed.displayLabel, 'Confirmed');
        expect(OrderStatus.preparing.displayLabel, 'Preparing');
        expect(OrderStatus.outForDelivery.displayLabel, 'Out for Delivery');
        expect(OrderStatus.delivered.displayLabel, 'Delivered');
        expect(OrderStatus.cancelled.displayLabel, 'Cancelled');
      });
    });
  });

  // ── OrderEntity unit tests ─────────────────────────────────────────────────
  group('OrderEntity', () {
    OrderEntity makeEntity({
      String id = 'order_001',
      OrderStatus status = OrderStatus.pending,
      double totalAmount = 1500,
      String paymentStatus = 'unpaid',
    }) {
      return OrderEntity(
        id: id,
        items: const [],
        totalAmount: totalAmount,
        status: status,
        paymentStatus: paymentStatus,
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );
    }

    group('isCancellable', () {
      test('should be true only for pending status', () {
        expect(makeEntity(status: OrderStatus.pending).isCancellable, isTrue);
      });

      test('should be false for all non-pending statuses', () {
        for (final status in [
          OrderStatus.confirmed,
          OrderStatus.preparing,
          OrderStatus.outForDelivery,
          OrderStatus.delivered,
          OrderStatus.cancelled,
        ]) {
          expect(
            makeEntity(status: status).isCancellable,
            isFalse,
            reason: '$status should not be cancellable',
          );
        }
      });
    });

    group('isActive', () {
      test(
        'should be true for pending, confirmed, preparing, outForDelivery',
        () {
          for (final status in [
            OrderStatus.pending,
            OrderStatus.confirmed,
            OrderStatus.preparing,
            OrderStatus.outForDelivery,
          ]) {
            expect(
              makeEntity(status: status).isActive,
              isTrue,
              reason: '$status should be active',
            );
          }
        },
      );

      test('should be false for delivered and cancelled', () {
        expect(makeEntity(status: OrderStatus.delivered).isActive, isFalse);
        expect(makeEntity(status: OrderStatus.cancelled).isActive, isFalse);
      });
    });

    group('copyWithPaymentStatus', () {
      test('should return a copy with updated paymentStatus only', () {
        // Arrange
        final entity = makeEntity(paymentStatus: 'unpaid');

        // Act
        final updated = entity.copyWithPaymentStatus('paid');

        // Assert
        expect(updated.paymentStatus, 'paid');
        expect(updated.id, entity.id);
        expect(updated.status, entity.status);
        expect(updated.totalAmount, entity.totalAmount);
        expect(updated.paymentMethod, entity.paymentMethod);
        expect(updated.notes, entity.notes);
      });

      test('original entity should be unchanged after copy', () {
        // Arrange
        final entity = makeEntity(paymentStatus: 'unpaid');

        // Act
        entity.copyWithPaymentStatus('paid');

        // Assert
        expect(entity.paymentStatus, 'unpaid');
      });
    });

    group('Equatable', () {
      test('props should be [id, status, totalAmount]', () {
        // Arrange
        final entity = makeEntity(
          id: 'order_001',
          status: OrderStatus.pending,
          totalAmount: 1500,
        );

        // Assert
        expect(
          entity.props,
          equals(['order_001', OrderStatus.pending, 1500.0]),
        );
      });

      test('two entities with same id/status/totalAmount should be equal', () {
        expect(makeEntity(), equals(makeEntity()));
      });

      test('entities with different id should not be equal', () {
        expect(
          makeEntity(id: 'order_001'),
          isNot(equals(makeEntity(id: 'order_002'))),
        );
      });

      test('entities with different status should not be equal', () {
        expect(
          makeEntity(status: OrderStatus.pending),
          isNot(equals(makeEntity(status: OrderStatus.delivered))),
        );
      });
    });
  });

  // ── OrderItemEntity unit tests ─────────────────────────────────────────────
  group('OrderItemEntity', () {
    test('props should be [type, refId, quantity] — NOT name or price', () {
      // Arrange — name/price differ but type/refId/quantity are same
      const i1 = OrderItemEntity(
        type: 'product',
        refId: 'ref_001',
        name: 'Roses',
        unitPrice: 1500,
        quantity: 2,
        subtotal: 3000,
      );

      // Assert
      expect(i1.props, equals(['product', 'ref_001', 2]));
    });

    test(
      'items with same type/refId/quantity but different name should be equal',
      () {
        // Arrange
        const i1 = OrderItemEntity(
          type: 'product',
          refId: 'ref_001',
          name: 'Roses',
          unitPrice: 1500,
          quantity: 2,
          subtotal: 3000,
        );
        const i2 = OrderItemEntity(
          type: 'product',
          refId: 'ref_001',
          name: 'Different Name',
          unitPrice: 9999,
          quantity: 2,
          subtotal: 0,
        );

        // Assert
        expect(i1, equals(i2));
      },
    );

    test('items with different quantity should not be equal', () {
      // Arrange
      const i1 = OrderItemEntity(
        type: 'product',
        refId: 'ref_001',
        name: 'Roses',
        unitPrice: 1500,
        quantity: 2,
        subtotal: 3000,
      );
      const i2 = OrderItemEntity(
        type: 'product',
        refId: 'ref_001',
        name: 'Roses',
        unitPrice: 1500,
        quantity: 3,
        subtotal: 4500,
      );

      // Assert
      expect(i1, isNot(equals(i2)));
    });
  });
}
