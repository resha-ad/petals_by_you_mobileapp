import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/orders/data/models/order_hive_model.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';

void main() {
  // ── Fixtures ────────────────────────────────────────────────────────────────
  const tItem = OrderItemEntity(
    type: 'product',
    refId: 'ref_001',
    name: 'Red Roses Bouquet',
    unitPrice: 1500,
    quantity: 2,
    subtotal: 3000,
    imageUrl: '/uploads/roses.jpg',
  );

  final tEntity = OrderEntity(
    id: 'order_abc123',
    items: const [tItem],
    totalAmount: 3000,
    status: OrderStatus.pending,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    notes: 'Deliver in the morning',
    cancelReason: null,
    createdAt: DateTime(2024, 1, 15, 10),
    updatedAt: DateTime(2024, 1, 15, 10),
  );

  // Helper to build a minimal entity for status-only tests
  OrderEntity entityWithStatus(OrderStatus status) => OrderEntity(
    id: 'x',
    items: const [],
    totalAmount: 100,
    status: status,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  // ── fromEntity ─────────────────────────────────────────────────────────────
  group('OrderHiveModel.fromEntity', () {
    test('should copy all scalar fields from the entity', () {
      // Act
      final model = OrderHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.id, 'order_abc123');
      expect(model.totalAmount, 3000.0);
      expect(model.paymentStatus, 'unpaid');
      expect(model.paymentMethod, 'cash_on_delivery');
      expect(model.notes, 'Deliver in the morning');
      expect(model.cancelReason, isNull);
      expect(model.createdAt, DateTime(2024, 1, 15, 10));
      expect(model.updatedAt, DateTime(2024, 1, 15, 10));
    });

    test('should store status as enum.name string (not the API string)', () {
      // Act — pending.name == 'pending'
      final model = OrderHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.status, 'pending');
    });

    test('should store outForDelivery as "outForDelivery" (enum.name)', () {
      // Arrange — outForDelivery.name == 'outForDelivery', NOT 'out_for_delivery'
      final entity = entityWithStatus(OrderStatus.outForDelivery);

      // Act
      final model = OrderHiveModel.fromEntity(entity);

      // Assert
      expect(model.status, 'outForDelivery');
    });

    test('should flatten items into parallel lists correctly', () {
      // Act
      final model = OrderHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.itemTypes, ['product']);
      expect(model.itemRefIds, ['ref_001']);
      expect(model.itemNames, ['Red Roses Bouquet']);
      expect(model.itemUnitPrices, [1500.0]);
      expect(model.itemQuantities, [2]);
      expect(model.itemSubtotals, [3000.0]);
      expect(model.itemImageUrls, ['/uploads/roses.jpg']);
    });

    test('should produce empty parallel lists for an entity with no items', () {
      // Arrange
      final emptyEntity = OrderEntity(
        id: 'x',
        items: const [],
        totalAmount: 0,
        status: OrderStatus.pending,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final model = OrderHiveModel.fromEntity(emptyEntity);

      // Assert
      expect(model.itemTypes, isEmpty);
      expect(model.itemRefIds, isEmpty);
      expect(model.itemNames, isEmpty);
      expect(model.itemUnitPrices, isEmpty);
      expect(model.itemQuantities, isEmpty);
      expect(model.itemSubtotals, isEmpty);
      expect(model.itemImageUrls, isEmpty);
    });

    test('should store null imageUrl in itemImageUrls list', () {
      // Arrange
      const itemNoImage = OrderItemEntity(
        type: 'product',
        refId: 'ref_002',
        name: 'Lily',
        unitPrice: 500,
        quantity: 1,
        subtotal: 500,
        // imageUrl defaults to null
      );
      final entity = OrderEntity(
        id: 'y',
        items: const [itemNoImage],
        totalAmount: 500,
        status: OrderStatus.pending,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final model = OrderHiveModel.fromEntity(entity);

      // Assert
      expect(model.itemImageUrls, [null]);
    });

    test('should handle multiple items in parallel lists', () {
      // Arrange
      const item2 = OrderItemEntity(
        type: 'product',
        refId: 'ref_002',
        name: 'Lily',
        unitPrice: 500,
        quantity: 1,
        subtotal: 500,
      );
      final entity = OrderEntity(
        id: 'z',
        items: const [tItem, item2],
        totalAmount: 3500,
        status: OrderStatus.confirmed,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act
      final model = OrderHiveModel.fromEntity(entity);

      // Assert
      expect(model.itemRefIds, ['ref_001', 'ref_002']);
      expect(model.itemQuantities, [2, 1]);
      expect(model.itemNames, ['Red Roses Bouquet', 'Lily']);
    });
  });

  // ── toEntity ──────────────────────────────────────────────────────────────
  group('OrderHiveModel.toEntity', () {
    test('should reconstruct an OrderEntity with correct scalar fields', () {
      // Arrange
      final model = OrderHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.id, 'order_abc123');
      expect(entity.totalAmount, 3000.0);
      expect(entity.paymentStatus, 'unpaid');
      expect(entity.paymentMethod, 'cash_on_delivery');
      expect(entity.notes, 'Deliver in the morning');
      expect(entity.cancelReason, isNull);
    });

    test('should reconstruct OrderStatus.pending from stored "pending"', () {
      // Arrange
      final model = OrderHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.status, OrderStatus.pending);
    });

    test(
      'should reconstruct OrderStatus.outForDelivery from stored "outForDelivery"',
      () {
        // Arrange — enum.name 'outForDelivery' is stored, toEntity converts it
        final model = OrderHiveModel.fromEntity(
          entityWithStatus(OrderStatus.outForDelivery),
        );

        // Act
        final entity = model.toEntity();

        // Assert
        expect(entity.status, OrderStatus.outForDelivery);
      },
    );

    test('should survive round-trip for all possible status values', () {
      // Arrange + Act + Assert
      for (final status in OrderStatus.values) {
        final original = entityWithStatus(status);
        final roundTripped = OrderHiveModel.fromEntity(original).toEntity();
        expect(
          roundTripped.status,
          status,
          reason: '$status should survive entity → hive → entity round-trip',
        );
      }
    });

    test('should reconstruct items from parallel lists correctly', () {
      // Arrange
      final model = OrderHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();
      final item = entity.items.first;

      // Assert
      expect(item.type, 'product');
      expect(item.refId, 'ref_001');
      expect(item.name, 'Red Roses Bouquet');
      expect(item.unitPrice, 1500.0);
      expect(item.quantity, 2);
      expect(item.subtotal, 3000.0);
      expect(item.imageUrl, '/uploads/roses.jpg');
    });

    test('should reconstruct null imageUrl from parallel list', () {
      // Arrange
      const itemNoImage = OrderItemEntity(
        type: 'product',
        refId: 'ref_002',
        name: 'Lily',
        unitPrice: 500,
        quantity: 1,
        subtotal: 500,
      );
      final entityNoImage = OrderEntity(
        id: 'y',
        items: const [itemNoImage],
        totalAmount: 500,
        status: OrderStatus.pending,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final model = OrderHiveModel.fromEntity(entityNoImage);

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.items.first.imageUrl, isNull);
    });

    test('should produce an empty items list when model has no items', () {
      // Arrange
      final emptyEntity = OrderEntity(
        id: 'x',
        items: const [],
        totalAmount: 0,
        status: OrderStatus.pending,
        paymentStatus: 'unpaid',
        paymentMethod: 'cash_on_delivery',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final model = OrderHiveModel.fromEntity(emptyEntity);

      // Act
      final result = model.toEntity();

      // Assert
      expect(result.items, isEmpty);
    });

    test('full round-trip should preserve all core fields', () {
      // Act
      final roundTripped = OrderHiveModel.fromEntity(tEntity).toEntity();

      // Assert
      expect(roundTripped.id, tEntity.id);
      expect(roundTripped.totalAmount, tEntity.totalAmount);
      expect(roundTripped.status, tEntity.status);
      expect(roundTripped.paymentStatus, tEntity.paymentStatus);
      expect(roundTripped.paymentMethod, tEntity.paymentMethod);
      expect(roundTripped.notes, tEntity.notes);
      expect(roundTripped.items.length, tEntity.items.length);
    });
  });
}
