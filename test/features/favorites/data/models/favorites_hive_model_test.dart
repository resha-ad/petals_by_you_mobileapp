import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/favorites/data/models/favorites_hive_model.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
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

  const tProductEntity = FavoriteEntity(
    type: 'product',
    refId: 'item_1',
    refItem: tItem,
  );

  const tNoItemEntity = FavoriteEntity(
    type: 'product',
    refId: 'item_2',
    // no refItem — plain refId, not yet enriched
  );

  const tCustomEntity = FavoriteEntity(type: 'custom', refId: 'cust_001');

  // ── fromEntity ─────────────────────────────────────────────────────────────
  group('FavoriteItemHiveModel.fromEntity - product with refItem', () {
    test('should copy type and refId', () {
      final model = FavoriteItemHiveModel.fromEntity(tProductEntity);

      expect(model.type, 'product');
      expect(model.refId, 'item_1');
    });

    test('should flatten all item fields from refItem', () {
      final model = FavoriteItemHiveModel.fromEntity(tProductEntity);

      expect(model.itemName, 'Sunflower Bouquet');
      expect(model.itemSlug, 'sunflower-bouquet');
      expect(model.itemDescription, 'Fresh sunflowers');
      expect(model.itemPrice, 900.0);
      expect(model.itemDiscountPrice, 750.0);
      expect(model.itemCategory, 'bouquets');
      expect(model.itemImages, ['sun1.jpg']);
      expect(model.itemStock, 7);
      expect(model.itemIsFeatured, true);
      expect(model.itemIsAvailable, true);
    });
  });

  group('FavoriteItemHiveModel.fromEntity - no refItem', () {
    test('should have null item fields when no refItem', () {
      final model = FavoriteItemHiveModel.fromEntity(tNoItemEntity);

      expect(model.itemName, isNull);
      expect(model.itemPrice, isNull);
      expect(model.itemImages, isNull);
      expect(model.itemStock, isNull);
    });
  });

  group('FavoriteItemHiveModel.fromEntity - custom type', () {
    test('should store type and refId with null item fields', () {
      final model = FavoriteItemHiveModel.fromEntity(tCustomEntity);

      expect(model.type, 'custom');
      expect(model.refId, 'cust_001');
      expect(model.itemName, isNull);
    });
  });

  // ── toEntity ───────────────────────────────────────────────────────────────
  group('FavoriteItemHiveModel.toEntity - product with item data', () {
    test('should restore type and refId', () {
      final entity = FavoriteItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(entity.type, 'product');
      expect(entity.refId, 'item_1');
    });

    test('should reconstruct refItem from flattened fields', () {
      final entity = FavoriteItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(entity.refItem, isNotNull);
      expect(entity.refItem!.name, 'Sunflower Bouquet');
      expect(entity.refItem!.price, 900.0);
      expect(entity.refItem!.discountPrice, 750.0);
      expect(entity.refItem!.category, 'bouquets');
      expect(entity.refItem!.images, ['sun1.jpg']);
      expect(entity.refItem!.stock, 7);
      expect(entity.refItem!.isFeatured, true);
      expect(entity.refItem!.isAvailable, true);
    });

    test('reconstructed refItem id should equal refId', () {
      final entity = FavoriteItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(entity.refItem!.id, 'item_1');
    });

    test('rating and numReviews default to 0 (not cached in Hive)', () {
      final entity = FavoriteItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(entity.refItem!.rating, 0);
      expect(entity.refItem!.numReviews, 0);
    });
  });

  group('FavoriteItemHiveModel.toEntity - no item data', () {
    test('should have null refItem when no item fields stored', () {
      final entity = FavoriteItemHiveModel.fromEntity(tNoItemEntity).toEntity();

      expect(entity.refItem, isNull);
    });
  });

  group('FavoriteItemHiveModel.toEntity - custom type', () {
    test('should restore custom entity with null refItem', () {
      final entity = FavoriteItemHiveModel.fromEntity(tCustomEntity).toEntity();

      expect(entity.type, 'custom');
      expect(entity.refId, 'cust_001');
      expect(entity.refItem, isNull);
    });
  });

  // ── Round-trip ─────────────────────────────────────────────────────────────
  group('FavoriteItemHiveModel round-trip', () {
    test('entity → model → entity should preserve all fields for product', () {
      final roundTripped = FavoriteItemHiveModel.fromEntity(
        tProductEntity,
      ).toEntity();

      expect(roundTripped.type, tProductEntity.type);
      expect(roundTripped.refId, tProductEntity.refId);
      expect(roundTripped.refItem?.name, tProductEntity.refItem?.name);
      expect(roundTripped.refItem?.price, tProductEntity.refItem?.price);
      expect(
        roundTripped.refItem?.discountPrice,
        tProductEntity.refItem?.discountPrice,
      );
      expect(roundTripped.refItem?.slug, tProductEntity.refItem?.slug);
      expect(roundTripped.refItem?.category, tProductEntity.refItem?.category);
      expect(roundTripped.refItem?.images, tProductEntity.refItem?.images);
      expect(roundTripped.refItem?.stock, tProductEntity.refItem?.stock);
    });

    test('entity with no refItem round-trips cleanly', () {
      final roundTripped = FavoriteItemHiveModel.fromEntity(
        tNoItemEntity,
      ).toEntity();

      expect(roundTripped.refId, tNoItemEntity.refId);
      expect(roundTripped.refItem, isNull);
    });
  });
}
