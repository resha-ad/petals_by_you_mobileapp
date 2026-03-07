import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/items/data/models/item_api_model.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

void main() {
  // ── Fixture JSON ─────────────────────────────────────────────────────────
  final tFullJson = {
    '_id': 'item_001',
    'name': 'Red Roses Bouquet',
    'slug': 'red-roses-bouquet',
    'description': 'A stunning arrangement of fresh red roses',
    'price': 1500,
    'discountPrice': 1200,
    'category': 'bouquets',
    'images': ['img1.jpg', 'img2.jpg'],
    'isFeatured': true,
    'isAvailable': true,
    'stock': 10,
    'rating': 4.5,
    'numReviews': 25,
    'preparationTime': 30,
    'deliveryType': 'standard',
  };

  final tMinimalJson = {
    '_id': 'item_002',
    'name': 'Simple Flower',
    'slug': 'simple-flower',
    'description': 'A simple flower',
    'price': 500,
  };

  group('ItemApiModel.fromJson', () {
    test('should parse all fields from full JSON', () {
      // Act
      final model = ItemApiModel.fromJson(tFullJson);

      // Assert
      expect(model.id, 'item_001');
      expect(model.name, 'Red Roses Bouquet');
      expect(model.slug, 'red-roses-bouquet');
      expect(model.description, 'A stunning arrangement of fresh red roses');
      expect(model.price, 1500);
      expect(model.discountPrice, 1200);
      expect(model.category, 'bouquets');
      expect(model.images, ['img1.jpg', 'img2.jpg']);
      expect(model.isFeatured, true);
      expect(model.isAvailable, true);
      expect(model.stock, 10);
      expect(model.rating, 4.5);
      expect(model.numReviews, 25);
      expect(model.preparationTime, 30);
      expect(model.deliveryType, 'standard');
    });

    test('should use default values when optional fields are missing', () {
      // Act
      final model = ItemApiModel.fromJson(tMinimalJson);

      // Assert
      expect(model.id, 'item_002');
      expect(model.name, 'Simple Flower');
      expect(model.discountPrice, isNull);
      expect(model.category, isNull);
      expect(model.images, isEmpty);
      expect(model.isFeatured, false);
      expect(model.isAvailable, true); // default = true
      expect(model.stock, 0);
      expect(model.rating, 0);
      expect(model.numReviews, 0);
      expect(model.preparationTime, isNull);
      expect(model.deliveryType, isNull);
    });

    test('should handle integer price as double', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['price'] = 1500; // int, not double

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.price, 1500.0);
      expect(model.price, isA<double>());
    });

    test('should handle double price', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['price'] = 1499.99;

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.price, 1499.99);
    });

    test('should handle null discountPrice field', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['discountPrice'] = null;

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.discountPrice, isNull);
    });

    test('should handle missing _id gracefully', () {
      // Arrange
      final json = Map<String, dynamic>.from(tMinimalJson);
      json.remove('_id');

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.id, '');
    });

    test('should parse isFeatured correctly', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['isFeatured'] = false;

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.isFeatured, false);
    });

    test('should parse isAvailable=false correctly', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['isAvailable'] = false;

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.isAvailable, false);
    });

    test('should handle empty images list', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['images'] = [];

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.images, isEmpty);
    });

    test('should handle multiple images', () {
      // Arrange
      final json = Map<String, dynamic>.from(tFullJson);
      json['images'] = ['a.jpg', 'b.jpg', 'c.jpg'];

      // Act
      final model = ItemApiModel.fromJson(json);

      // Assert
      expect(model.images.length, 3);
      expect(model.images[2], 'c.jpg');
    });
  });

  group('ItemApiModel.toEntity', () {
    test('should convert model to entity with all fields', () {
      // Arrange
      final model = ItemApiModel.fromJson(tFullJson);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity, isA<ItemEntity>());
      expect(entity.id, 'item_001');
      expect(entity.name, 'Red Roses Bouquet');
      expect(entity.slug, 'red-roses-bouquet');
      expect(entity.description, 'A stunning arrangement of fresh red roses');
      expect(entity.price, 1500);
      expect(entity.discountPrice, 1200);
      expect(entity.category, 'bouquets');
      expect(entity.images, ['img1.jpg', 'img2.jpg']);
      expect(entity.isFeatured, true);
      expect(entity.isAvailable, true);
      expect(entity.stock, 10);
      expect(entity.rating, 4.5);
      expect(entity.numReviews, 25);
      expect(entity.preparationTime, 30);
      expect(entity.deliveryType, 'standard');
    });

    test('should set effectivePrice to discountPrice when discount exists', () {
      // Arrange
      final model = ItemApiModel.fromJson(tFullJson);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.effectivePrice, 1200);
      expect(entity.hasDiscount, true);
    });

    test('should set effectivePrice to price when no discount', () {
      // Arrange
      final model = ItemApiModel.fromJson(tMinimalJson);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.effectivePrice, 500);
      expect(entity.hasDiscount, false);
    });

    test('should set primaryImage to first image', () {
      // Arrange
      final model = ItemApiModel.fromJson(tFullJson);

      // Act
      final entity = model.toEntity();

      // Assert
      expect(entity.primaryImage, 'img1.jpg');
    });
  });

  group('ItemApiModel.toEntityList', () {
    test('should convert a list of models to entities', () {
      // Arrange
      final models = [
        ItemApiModel.fromJson(tFullJson),
        ItemApiModel.fromJson(tMinimalJson),
      ];

      // Act
      final entities = ItemApiModel.toEntityList(models);

      // Assert
      expect(entities.length, 2);
      expect(entities[0].id, 'item_001');
      expect(entities[1].id, 'item_002');
    });

    test('should return empty list when given empty list', () {
      // Arrange + Act
      final entities = ItemApiModel.toEntityList([]);

      // Assert
      expect(entities, isEmpty);
    });

    test('all items should be ItemEntity instances', () {
      // Arrange
      final models = [
        ItemApiModel.fromJson(tFullJson),
        ItemApiModel.fromJson(tMinimalJson),
      ];

      // Act
      final entities = ItemApiModel.toEntityList(models);

      // Assert
      for (final entity in entities) {
        expect(entity, isA<ItemEntity>());
      }
    });
  });

  group('DataResult', () {
    test('fromCache should be false for fresh data', () {
      final result = DataResult([
        const ItemEntity(
          id: '1',
          name: 'test',
          slug: 'test',
          description: 'desc',
          price: 100,
          images: [],
          isFeatured: false,
          isAvailable: true,
          stock: 1,
          rating: 0,
          numReviews: 0,
        ),
      ], fromCache: false);

      expect(result.fromCache, false);
    });

    test('fromCache should be true for cached data', () {
      final result = DataResult(<ItemEntity>[], fromCache: true);
      expect(result.fromCache, true);
    });

    test('data field should hold the wrapped value', () {
      const items = <ItemEntity>[];
      final result = DataResult(items, fromCache: false);
      expect(result.data, items);
    });
  });
}
