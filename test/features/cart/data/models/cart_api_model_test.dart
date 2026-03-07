import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/cart/data/models/cart_api_model.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';

void main() {
  // ── JSON fixtures ─────────────────────────────────────────────────────────
  final tProductItemJson = {
    'type': 'product',
    'refId': 'ref_001',
    'quantity': 2,
    'unitPrice': 1500,
    'subtotal': 3000,
    'refDetails': {
      'name': 'Red Roses',
      'slug': 'red-roses',
      'description': 'A beautiful bunch',
      'price': 1500,
      'discountPrice': null,
      'category': 'bouquets',
      'images': ['img1.jpg', 'img2.jpg'],
      'isFeatured': true,
      'isAvailable': true,
      'stock': 10,
      'rating': 4.5,
      'numReviews': 20,
    },
  };

  final tCustomItemJson = {
    'type': 'custom',
    'refId': 'cust_001',
    'quantity': 1,
    'unitPrice': 2500,
    'subtotal': 2500,
    'refDetails': {
      'recipientName': 'Alice',
      'flowers': [
        {'name': 'Rose', 'count': 5},
        {'name': 'Lily', 'count': 3},
      ],
    },
  };

  final tMinimalItemJson = {'type': 'product', 'refId': 'ref_002'};

  final tCartJson = {
    'userId': 'user_abc',
    'items': [tProductItemJson, tCustomItemJson],
    'total': 5500,
  };

  final tEmptyCartJson = {'userId': 'user_abc', 'items': [], 'total': 0};

  // ── CartItemApiModel.fromJson ──────────────────────────────────────────────
  group('CartItemApiModel.fromJson - product type', () {
    test('should parse all fields for a product item', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);

      expect(model.type, 'product');
      expect(model.refId, 'ref_001');
      expect(model.quantity, 2);
      expect(model.unitPrice, 1500.0);
      expect(model.subtotal, 3000.0);
    });

    test('should populate refItem from refDetails for product type', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);

      expect(model.refItem, isNotNull);
      expect(model.refItem!.name, 'Red Roses');
      expect(model.refItem!.slug, 'red-roses');
      expect(model.refItem!.price, 1500.0);
      expect(model.refItem!.images, ['img1.jpg', 'img2.jpg']);
    });

    test('should inject refId as _id into refItem', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);

      // The refId should be merged as _id so ItemApiModel.id == refId
      expect(model.refItem!.id, 'ref_001');
    });

    test('should have null customDetails for product type', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);
      expect(model.customDetails, isNull);
    });

    test('should handle integer unitPrice as double', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);
      expect(model.unitPrice, isA<double>());
    });
  });

  group('CartItemApiModel.fromJson - custom type', () {
    test('should parse type and refId for custom item', () {
      final model = CartItemApiModel.fromJson(tCustomItemJson);

      expect(model.type, 'custom');
      expect(model.refId, 'cust_001');
      expect(model.quantity, 1);
      expect(model.unitPrice, 2500.0);
    });

    test('should have null refItem for custom type', () {
      final model = CartItemApiModel.fromJson(tCustomItemJson);
      expect(model.refItem, isNull);
    });

    test('should populate customDetails from refDetails for custom type', () {
      final model = CartItemApiModel.fromJson(tCustomItemJson);

      expect(model.customDetails, isNotNull);
      expect(model.customDetails!['recipientName'], 'Alice');
    });
  });

  group('CartItemApiModel.fromJson - edge cases', () {
    test('should use default values when fields are missing', () {
      final model = CartItemApiModel.fromJson(tMinimalItemJson);

      expect(model.type, 'product');
      expect(model.refId, 'ref_002');
      expect(model.quantity, 1); // default
      expect(model.unitPrice, 0.0); // default
      expect(model.subtotal, 0.0); // default
      expect(model.refItem, isNull);
      expect(model.customDetails, isNull);
    });

    test('should parse refId from nested Map object', () {
      final jsonWithNestedRef = {
        'type': 'product',
        'refId': {'_id': 'nested_ref_id', 'name': 'Test'},
        'quantity': 1,
        'unitPrice': 500,
        'subtotal': 500,
      };

      final model = CartItemApiModel.fromJson(jsonWithNestedRef);
      expect(model.refId, 'nested_ref_id');
    });

    test('should handle missing refDetails gracefully', () {
      final jsonNoDetails = {
        'type': 'product',
        'refId': 'ref_003',
        'quantity': 1,
        'unitPrice': 1000,
        'subtotal': 1000,
      };

      final model = CartItemApiModel.fromJson(jsonNoDetails);
      expect(model.refItem, isNull);
      expect(model.customDetails, isNull);
    });
  });

  // ── CartItemApiModel.toEntity ─────────────────────────────────────────────
  group('CartItemApiModel.toEntity', () {
    test('should convert product item to CartItemEntity', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);
      final entity = model.toEntity();

      expect(entity, isA<CartItemEntity>());
      expect(entity.type, 'product');
      expect(entity.refId, 'ref_001');
      expect(entity.quantity, 2);
      expect(entity.unitPrice, 1500.0);
      expect(entity.subtotal, 3000.0);
    });

    test('should populate entity refItem from model refItem', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);
      final entity = model.toEntity();

      expect(entity.refItem, isNotNull);
      expect(entity.refItem!.name, 'Red Roses');
    });

    test('should set displayName to item name when refItem is present', () {
      final model = CartItemApiModel.fromJson(tProductItemJson);
      final entity = model.toEntity();

      expect(entity.displayName, 'Red Roses');
    });

    test('should convert custom item to entity with customDetails', () {
      final model = CartItemApiModel.fromJson(tCustomItemJson);
      final entity = model.toEntity();

      expect(entity.type, 'custom');
      expect(entity.refItem, isNull);
      expect(entity.customDetails, isNotNull);
      expect(entity.customDetails!['recipientName'], 'Alice');
    });

    test('should set displayName to custom bouquet for recipient', () {
      final model = CartItemApiModel.fromJson(tCustomItemJson);
      final entity = model.toEntity();

      expect(entity.displayName, 'Custom Bouquet for Alice');
    });
  });

  // ── CartApiModel.fromJson ─────────────────────────────────────────────────
  group('CartApiModel.fromJson', () {
    test('should parse userId and total', () {
      final model = CartApiModel.fromJson(tCartJson);

      expect(model.userId, 'user_abc');
      expect(model.total, 5500.0);
    });

    test('should parse all items in the list', () {
      final model = CartApiModel.fromJson(tCartJson);

      expect(model.items.length, 2);
      expect(model.items[0].type, 'product');
      expect(model.items[1].type, 'custom');
    });

    test('should return empty items list for empty cart', () {
      final model = CartApiModel.fromJson(tEmptyCartJson);

      expect(model.items, isEmpty);
      expect(model.total, 0.0);
    });

    test('should use default values when fields are missing', () {
      final model = CartApiModel.fromJson({});

      expect(model.userId, '');
      expect(model.items, isEmpty);
      expect(model.total, 0.0);
    });

    test('should handle integer total as double', () {
      final model = CartApiModel.fromJson(tCartJson);
      expect(model.total, isA<double>());
    });
  });

  // ── CartApiModel.toEntity ─────────────────────────────────────────────────
  group('CartApiModel.toEntity', () {
    test('should convert to CartEntity with correct fields', () {
      final model = CartApiModel.fromJson(tCartJson);
      final entity = model.toEntity();

      expect(entity, isA<CartEntity>());
      expect(entity.userId, 'user_abc');
      expect(entity.total, 5500.0);
      expect(entity.items.length, 2);
    });

    test('should set isEmpty=false when items exist', () {
      final model = CartApiModel.fromJson(tCartJson);
      final entity = model.toEntity();

      expect(entity.isEmpty, false);
    });

    test('should set isEmpty=true for empty cart', () {
      final model = CartApiModel.fromJson(tEmptyCartJson);
      final entity = model.toEntity();

      expect(entity.isEmpty, true);
    });

    test('should calculate itemCount from item quantities', () {
      final model = CartApiModel.fromJson(tCartJson);
      final entity = model.toEntity();

      // product item: qty=2, custom item: qty=1 → total=3
      expect(entity.itemCount, 3);
    });

    test('empty CartApiModel constructor should produce empty entity', () {
      const model = CartApiModel(userId: 'u1', items: [], total: 0);
      final entity = model.toEntity();

      expect(entity.isEmpty, true);
      expect(entity.total, 0.0);
    });
  });
}
