import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/items/data/models/item_hive_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

void main() {
  final tEntity = const ItemEntity(
    id: 'item_abc',
    name: 'Sunflower Bouquet',
    slug: 'sunflower-bouquet',
    description: 'Fresh sunflowers',
    price: 900,
    discountPrice: 750,
    category: 'bouquets',
    images: ['sun1.jpg', 'sun2.jpg'],
    isFeatured: true,
    isAvailable: true,
    stock: 7,
    rating: 4.2,
    numReviews: 15,
    preparationTime: 20,
    deliveryType: 'express',
  );

  group('ItemHiveModel.fromEntity', () {
    test('should create model from entity with all fields', () {
      // Act
      final model = ItemHiveModel.fromEntity(tEntity);

      // Assert
      expect(model.itemId, 'item_abc');
      expect(model.name, 'Sunflower Bouquet');
      expect(model.slug, 'sunflower-bouquet');
      expect(model.description, 'Fresh sunflowers');
      expect(model.price, 900);
      expect(model.discountPrice, 750);
      expect(model.category, 'bouquets');
      expect(model.images, ['sun1.jpg', 'sun2.jpg']);
      expect(model.isFeatured, true);
      expect(model.isAvailable, true);
      expect(model.stock, 7);
      expect(model.preparationTime, 20);
      expect(model.deliveryType, 'express');
    });

    test('should set cachedAt to approximately now', () {
      // Act
      final before = DateTime.now();
      final model = ItemHiveModel.fromEntity(tEntity);
      final after = DateTime.now();

      // Assert
      expect(
        model.cachedAt.isAfter(before) ||
            model.cachedAt.isAtSameMomentAs(before),
        true,
      );
      expect(
        model.cachedAt.isBefore(after) ||
            model.cachedAt.isAtSameMomentAs(after),
        true,
      );
    });

    test('should handle entity with no optional fields', () {
      // Arrange
      const entity = ItemEntity(
        id: 'minimal',
        name: 'Minimal',
        slug: 'minimal',
        description: 'desc',
        price: 100,
        images: [],
        isFeatured: false,
        isAvailable: true,
        stock: 1,
        rating: 0,
        numReviews: 0,
      );

      // Act
      final model = ItemHiveModel.fromEntity(entity);

      // Assert
      expect(model.itemId, 'minimal');
      expect(model.discountPrice, isNull);
      expect(model.category, isNull);
      expect(model.images, isEmpty);
      expect(model.preparationTime, isNull);
      expect(model.deliveryType, isNull);
    });
  });

  group('ItemHiveModel.toEntity', () {
    test('should convert model back to entity correctly', () {
      // Arrange
      final model = ItemHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.id, 'item_abc');
      expect(entity.name, 'Sunflower Bouquet');
      expect(entity.slug, 'sunflower-bouquet');
      expect(entity.price, 900);
      expect(entity.discountPrice, 750);
      expect(entity.category, 'bouquets');
      expect(entity.images, ['sun1.jpg', 'sun2.jpg']);
      expect(entity.isFeatured, true);
      expect(entity.isAvailable, true);
      expect(entity.stock, 7);
      expect(entity.preparationTime, 20);
      expect(entity.deliveryType, 'express');
    });

    test('should default rating to 0 (not stored in Hive)', () {
      // Arrange
      final model = ItemHiveModel.fromEntity(tEntity);

      // Act
      final entity = model.toEntity();

      // Assert — rating and numReviews are not in Hive model
      expect(entity.rating, 0);
      expect(entity.numReviews, 0);
    });

    test('round-trip: entity → model → entity should preserve core fields', () {
      // Arrange
      const original = ItemEntity(
        id: 'rt_1',
        name: 'Rose',
        slug: 'rose',
        description: 'desc',
        price: 500,
        images: ['r.jpg'],
        isFeatured: false,
        isAvailable: false,
        stock: 0,
        rating: 3,
        numReviews: 5,
      );

      // Act
      final roundTripped = ItemHiveModel.fromEntity(original).toEntity();

      // Assert
      expect(roundTripped.id, original.id);
      expect(roundTripped.name, original.name);
      expect(roundTripped.slug, original.slug);
      expect(roundTripped.price, original.price);
      expect(roundTripped.isAvailable, original.isAvailable);
      expect(roundTripped.stock, original.stock);
    });
  });

  group('ItemHiveModel.toEntityList', () {
    test('should convert list of models to entities', () {
      // Arrange
      final models = [
        ItemHiveModel.fromEntity(tEntity),
        ItemHiveModel.fromEntity(
          const ItemEntity(
            id: 'item_2',
            name: 'Lily',
            slug: 'lily',
            description: 'desc',
            price: 600,
            images: [],
            isFeatured: false,
            isAvailable: true,
            stock: 3,
            rating: 0,
            numReviews: 0,
          ),
        ),
      ];

      // Act
      final entities = ItemHiveModel.toEntityList(models);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, 'item_abc');
      expect(entities[1].id, 'item_2');
    });

    test('should return empty list for empty input', () {
      expect(ItemHiveModel.toEntityList([]), isEmpty);
    });

    test('all converted items should be ItemEntity instances', () {
      final models = [ItemHiveModel.fromEntity(tEntity)];
      final entities = ItemHiveModel.toEntityList(models);

      for (final e in entities) {
        expect(e, isA<ItemEntity>());
      }
    });
  });
}
