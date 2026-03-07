import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/favorites/data/models/favorite_api_model.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';

void main() {
  // ── JSON fixtures ─────────────────────────────────────────────────────────

  // refId as a populated object (backend populates with product data)
  final tPopulatedItemJson = {
    'type': 'product',
    'refId': {
      '_id': 'item_001',
      'name': 'Red Roses',
      'slug': 'red-roses',
      'description': 'A beautiful bunch',
      'price': 1500,
      'discountPrice': null,
      'category': 'bouquets',
      'images': ['img1.jpg'],
      'isFeatured': true,
      'isAvailable': true,
      'stock': 10,
      'rating': 4.5,
      'numReviews': 20,
    },
  };

  // refId as a plain string (backend did not populate)
  final tPlainRefItemJson = {'type': 'product', 'refId': 'item_002'};

  // Custom type
  final tCustomItemJson = {'type': 'custom', 'refId': 'cust_001'};

  final tFavoritesJson = {
    'userId': 'user_abc',
    'items': [tPopulatedItemJson, tPlainRefItemJson],
  };

  final tEmptyFavoritesJson = {'userId': 'user_abc', 'items': []};

  // ── FavoriteItemApiModel.fromJson — populated refId ───────────────────────
  group('FavoriteItemApiModel.fromJson - populated refId', () {
    test('should parse type and extract _id as refId', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);

      expect(model.type, 'product');
      expect(model.refId, 'item_001');
    });

    test('should build refItem from populated refId map', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);

      expect(model.refItem, isNotNull);
      expect(model.refItem!.name, 'Red Roses');
      expect(model.refItem!.slug, 'red-roses');
      expect(model.refItem!.price, 1500.0);
      expect(model.refItem!.images, ['img1.jpg']);
      expect(model.refItem!.category, 'bouquets');
    });

    test('should set refItem.id to the extracted _id', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);

      expect(model.refItem!.id, 'item_001');
    });

    test('should handle integer price as double', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);
      expect(model.refItem!.price, isA<double>());
    });
  });

  // ── FavoriteItemApiModel.fromJson — plain string refId ───────────────────
  group('FavoriteItemApiModel.fromJson - plain string refId', () {
    test('should use plain string as refId', () {
      final model = FavoriteItemApiModel.fromJson(tPlainRefItemJson);

      expect(model.refId, 'item_002');
    });

    test('should have null refItem when refId is plain string', () {
      final model = FavoriteItemApiModel.fromJson(tPlainRefItemJson);

      expect(model.refItem, isNull);
    });

    test('should default type to "product" when missing', () {
      final model = FavoriteItemApiModel.fromJson({'refId': 'ref_x'});

      expect(model.type, 'product');
    });
  });

  // ── FavoriteItemApiModel.fromJson — custom type ───────────────────────────
  group('FavoriteItemApiModel.fromJson - custom type', () {
    test('should parse custom type correctly', () {
      final model = FavoriteItemApiModel.fromJson(tCustomItemJson);

      expect(model.type, 'custom');
      expect(model.refId, 'cust_001');
      expect(model.refItem, isNull);
    });
  });

  // ── FavoriteItemApiModel.toEntity ─────────────────────────────────────────
  group('FavoriteItemApiModel.toEntity', () {
    test('should convert to FavoriteEntity with correct fields', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);
      final entity = model.toEntity();

      expect(entity, isA<FavoriteEntity>());
      expect(entity.type, 'product');
      expect(entity.refId, 'item_001');
    });

    test('should populate entity refItem from model refItem', () {
      final model = FavoriteItemApiModel.fromJson(tPopulatedItemJson);
      final entity = model.toEntity();

      expect(entity.refItem, isNotNull);
      expect(entity.refItem!.name, 'Red Roses');
    });

    test('should have null entity refItem when model refItem is null', () {
      final model = FavoriteItemApiModel.fromJson(tPlainRefItemJson);
      final entity = model.toEntity();

      expect(entity.refItem, isNull);
    });
  });

  // ── FavoritesApiModel.fromJson ────────────────────────────────────────────
  group('FavoritesApiModel.fromJson', () {
    test('should parse userId', () {
      final model = FavoritesApiModel.fromJson(tFavoritesJson);

      expect(model.userId, 'user_abc');
    });

    test('should parse all items in the list', () {
      final model = FavoritesApiModel.fromJson(tFavoritesJson);

      expect(model.items.length, 2);
      expect(model.items[0].refId, 'item_001');
      expect(model.items[1].refId, 'item_002');
    });

    test('should return empty items for empty favourites', () {
      final model = FavoritesApiModel.fromJson(tEmptyFavoritesJson);

      expect(model.items, isEmpty);
    });

    test('should use default values when fields are missing', () {
      final model = FavoritesApiModel.fromJson({});

      expect(model.userId, '');
      expect(model.items, isEmpty);
    });
  });

  // ── FavoritesApiModel.toEntity ────────────────────────────────────────────
  group('FavoritesApiModel.toEntity', () {
    test('should convert to FavoritesEntity with correct userId', () {
      final model = FavoritesApiModel.fromJson(tFavoritesJson);
      final entity = model.toEntity();

      expect(entity, isA<FavoritesEntity>());
      expect(entity.userId, 'user_abc');
    });

    test('should convert all items to FavoriteEntity list', () {
      final model = FavoritesApiModel.fromJson(tFavoritesJson);
      final entity = model.toEntity();

      expect(entity.items.length, 2);
      expect(entity.items[0].refId, 'item_001');
    });

    test('empty FavoritesApiModel should produce empty entity', () {
      const model = FavoritesApiModel(userId: 'u1', items: []);
      final entity = model.toEntity();

      expect(entity.items, isEmpty);
    });
  });

  // ── FavoriteEntity equality ───────────────────────────────────────────────
  group('FavoriteEntity', () {
    test('two entities with same type and refId should be equal', () {
      const e1 = FavoriteEntity(type: 'product', refId: 'ref_1');
      const e2 = FavoriteEntity(type: 'product', refId: 'ref_1');
      expect(e1, e2);
    });

    test('two entities with different refId should not be equal', () {
      const e1 = FavoriteEntity(type: 'product', refId: 'ref_1');
      const e2 = FavoriteEntity(type: 'product', refId: 'ref_2');
      expect(e1, isNot(e2));
    });

    test('props should contain type and refId only (not refItem)', () {
      const e = FavoriteEntity(type: 'product', refId: 'ref_1');
      expect(e.props, ['product', 'ref_1']);
    });
  });

  // ── FavoritesEntity equality ──────────────────────────────────────────────
  group('FavoritesEntity', () {
    test('two entities with same values should be equal', () {
      const e1 = FavoritesEntity(userId: 'u1', items: []);
      const e2 = FavoritesEntity(userId: 'u1', items: []);
      expect(e1, e2);
    });

    test('props should contain userId and items', () {
      const e = FavoritesEntity(userId: 'u1', items: []);
      expect(e.props, ['u1', <FavoriteEntity>[]]);
    });
  });
}
