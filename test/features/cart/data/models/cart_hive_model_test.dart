import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/cart/data/models/cart_hive_model.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

void main() {
  const tItem = ItemEntity(
    id: 'item_1',
    name: 'Sunflower Bouquet',
    slug: 'sunflower-bouquet',
    description: 'Fresh sunflowers',
    price: 900,
    discountPrice: 750,
    category: 'bouquets',
    images: ['sun1.jpg'],
    isFeatured: true,
    isAvailable: true,
    stock: 7,
    rating: 4.2,
    numReviews: 15,
  );

  const tProductEntity = CartItemEntity(
    type: 'product',
    refId: 'ref_abc',
    quantity: 3,
    unitPrice: 900,
    subtotal: 2700,
    refItem: tItem,
  );

  const tCustomEntity = CartItemEntity(
    type: 'custom',
    refId: 'cust_001',
    quantity: 1,
    unitPrice: 2500,
    subtotal: 2500,
    customDetails: {'recipientName': 'Bob'},
  );

  const tNoItemEntity = CartItemEntity(
    type: 'product',
    refId: 'ref_no_item',
    quantity: 1,
    unitPrice: 500,
    subtotal: 500,
    // no refItem
  );

  // ── fromEntity ────────────────────────────────────────────────────────────
  group('CartItemHiveModel.fromEntity - product with refItem', () {
    test('should copy core cart fields', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);

      expect(model.type, 'product');
      expect(model.refId, 'ref_abc');
      expect(model.quantity, 3);
      expect(model.unitPrice, 900.0);
      expect(model.subtotal, 2700.0);
    });

    test('should flatten item fields from refItem', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);

      expect(model.itemName, 'Sunflower Bouquet');
      expect(model.itemSlug, 'sunflower-bouquet');
      expect(model.itemDescription, 'Fresh sunflowers');
      expect(model.itemPrice, 900.0);
      expect(model.itemDiscountPrice, 750.0);
      expect(model.itemCategory, 'bouquets');
      expect(model.itemImages, ['sun1.jpg']);
      expect(model.itemStock, 7);
    });

    test('should have null customRecipientName for product type', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);
      expect(model.customRecipientName, isNull);
    });
  });

  group('CartItemHiveModel.fromEntity - custom type', () {
    test('should store recipientName from customDetails', () {
      final model = CartItemHiveModel.fromEntity(tCustomEntity);

      expect(model.type, 'custom');
      expect(model.customRecipientName, 'Bob');
    });

    test('should have null item fields for custom type', () {
      final model = CartItemHiveModel.fromEntity(tCustomEntity);

      expect(model.itemName, isNull);
      expect(model.itemPrice, isNull);
      expect(model.itemImages, isNull);
    });
  });

  group('CartItemHiveModel.fromEntity - no refItem', () {
    test('should have null item fields when no refItem', () {
      final model = CartItemHiveModel.fromEntity(tNoItemEntity);

      expect(model.itemName, isNull);
      expect(model.itemPrice, isNull);
      expect(model.itemImages, isNull);
      expect(model.itemStock, isNull);
    });
  });

  // ── toEntity ──────────────────────────────────────────────────────────────
  group('CartItemHiveModel.toEntity - product with item data', () {
    test('should restore core cart fields', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);
      final entity = model.toEntity();

      expect(entity.type, 'product');
      expect(entity.refId, 'ref_abc');
      expect(entity.quantity, 3);
      expect(entity.unitPrice, 900.0);
      expect(entity.subtotal, 2700.0);
    });

    test('should reconstruct refItem from flattened fields', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);
      final entity = model.toEntity();

      expect(entity.refItem, isNotNull);
      expect(entity.refItem!.name, 'Sunflower Bouquet');
      expect(entity.refItem!.price, 900.0);
      expect(entity.refItem!.discountPrice, 750.0);
      expect(entity.refItem!.category, 'bouquets');
      expect(entity.refItem!.images, ['sun1.jpg']);
      expect(entity.refItem!.stock, 7);
    });

    test('reconstructed refItem should have correct id (== refId)', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);
      final entity = model.toEntity();

      expect(entity.refItem!.id, 'ref_abc');
    });

    test('displayName should return item name from reconstructed refItem', () {
      final model = CartItemHiveModel.fromEntity(tProductEntity);
      final entity = model.toEntity();

      expect(entity.displayName, 'Sunflower Bouquet');
    });
  });

  group('CartItemHiveModel.toEntity - custom type', () {
    test('should restore customDetails with recipientName', () {
      final model = CartItemHiveModel.fromEntity(tCustomEntity);
      final entity = model.toEntity();

      expect(entity.type, 'custom');
      expect(entity.refItem, isNull);
      expect(entity.customDetails, isNotNull);
      expect(entity.customDetails!['recipientName'], 'Bob');
    });

    test('displayName should return custom bouquet with recipient', () {
      final model = CartItemHiveModel.fromEntity(tCustomEntity);
      final entity = model.toEntity();

      expect(entity.displayName, 'Custom Bouquet for Bob');
    });
  });

  group('CartItemHiveModel.toEntity - no item data', () {
    test('should have null refItem when no item fields stored', () {
      final model = CartItemHiveModel.fromEntity(tNoItemEntity);
      final entity = model.toEntity();

      expect(entity.refItem, isNull);
    });

    test('displayName should fall back to Custom Bouquet', () {
      final model = CartItemHiveModel.fromEntity(tNoItemEntity);
      final entity = model.toEntity();

      expect(entity.displayName, 'Custom Bouquet');
    });
  });

  // ── Round-trip ─────────────────────────────────────────────────────────────
  group('CartItemHiveModel round-trip', () {
    test('entity → model → entity should preserve all fields for product', () {
      final roundTripped = CartItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(roundTripped.type, tProductEntity.type);
      expect(roundTripped.refId, tProductEntity.refId);
      expect(roundTripped.quantity, tProductEntity.quantity);
      expect(roundTripped.unitPrice, tProductEntity.unitPrice);
      expect(roundTripped.subtotal, tProductEntity.subtotal);
      expect(roundTripped.refItem?.name, tProductEntity.refItem?.name);
      expect(roundTripped.refItem?.price, tProductEntity.refItem?.price);
    });

    test('entity → model → entity should preserve custom recipient name', () {
      final roundTripped = CartItemHiveModel.fromEntity(
        tCustomEntity,
      ).toEntity();

      expect(roundTripped.customDetails!['recipientName'], 'Bob');
    });
  });
}
