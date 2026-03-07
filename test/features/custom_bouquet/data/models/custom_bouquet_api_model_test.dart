import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/custom_bouquet/data/models/custom_bouquet_api_model.dart';

void main() {
  // ── JSON fixtures ──────────────────────────────────────────────────────────
  final tFullJson = {
    '_id': 'bouquet_001',
    'flowers': [
      {'flowerId': 'rose', 'name': 'Rose', 'count': 5, 'pricePerStem': 120},
      {'flowerId': 'tulip', 'name': 'Tulip', 'count': 3, 'pricePerStem': 90},
    ],
    'wrapping': {'id': 'kraft', 'name': 'Kraft Paper', 'price': 50},
    'note': 'With love',
    'recipientName': 'Alice',
    'totalPrice': 920,
  };

  final tNoWrappingJson = {
    '_id': 'bouquet_002',
    'flowers': [
      {'flowerId': 'lily', 'name': 'Lily', 'count': 4, 'pricePerStem': 110},
    ],
    'note': '',
    'recipientName': '',
    'totalPrice': 440,
  };

  final tMinimalJson = {'_id': 'bouquet_003'};

  // ── fromJson — full object ─────────────────────────────────────────────────
  group('CustomBouquetApiModel.fromJson - full object', () {
    test('should parse id from _id field', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.id, 'bouquet_001');
    });

    test('should parse all flowers', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.flowers.length, 2);
    });

    test('should parse first flower fields correctly', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      final rose = model.flowers[0];
      expect(rose.flowerId, 'rose');
      expect(rose.name, 'Rose');
      expect(rose.count, 5);
      expect(rose.pricePerStem, 120.0);
    });

    test('should parse wrapping when present', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.wrapping, isNotNull);
      expect(model.wrapping!.id, 'kraft');
      expect(model.wrapping!.name, 'Kraft Paper');
      expect(model.wrapping!.price, 50.0);
    });

    test('should set wrapping color fields to hardcoded values', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.wrapping!.color, '#F3E6E6');
      expect(model.wrapping!.darkColor, '#6B4E4E');
    });

    test('should parse note and recipientName', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.note, 'With love');
      expect(model.recipientName, 'Alice');
    });

    test('should parse totalPrice as double', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.totalPrice, 920.0);
      expect(model.totalPrice, isA<double>());
    });
  });

  // ── fromJson — no wrapping ─────────────────────────────────────────────────
  group('CustomBouquetApiModel.fromJson - no wrapping', () {
    test('should have null wrapping when wrapping key absent', () {
      final model = CustomBouquetApiModel.fromJson(tNoWrappingJson);
      expect(model.wrapping, isNull);
    });

    test('should parse single flower correctly', () {
      final model = CustomBouquetApiModel.fromJson(tNoWrappingJson);
      expect(model.flowers.length, 1);
      expect(model.flowers[0].flowerId, 'lily');
      expect(model.flowers[0].count, 4);
    });
  });

  // ── fromJson — minimal / edge cases ───────────────────────────────────────
  group('CustomBouquetApiModel.fromJson - edge cases', () {
    test('should use defaults when fields are missing', () {
      final model = CustomBouquetApiModel.fromJson(tMinimalJson);
      expect(model.id, 'bouquet_003');
      expect(model.flowers, isEmpty);
      expect(model.wrapping, isNull);
      expect(model.note, '');
      expect(model.recipientName, '');
      expect(model.totalPrice, 0.0);
    });

    test('should return empty id when _id is missing', () {
      final model = CustomBouquetApiModel.fromJson({});
      expect(model.id, '');
    });

    test('should handle integer pricePerStem as double', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.flowers.first.pricePerStem, isA<double>());
    });

    test('should handle integer totalPrice as double', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      expect(model.totalPrice, isA<double>());
    });

    test('should default flower count to 1 when missing', () {
      final json = {
        '_id': 'b',
        'flowers': [
          {'flowerId': 'rose', 'name': 'Rose', 'pricePerStem': 100},
        ],
      };
      final model = CustomBouquetApiModel.fromJson(json);
      expect(model.flowers.first.count, 1);
    });

    test('should default flower pricePerStem to 0 when missing', () {
      final json = {
        '_id': 'b',
        'flowers': [
          {'flowerId': 'rose', 'name': 'Rose', 'count': 3},
        ],
      };
      final model = CustomBouquetApiModel.fromJson(json);
      expect(model.flowers.first.pricePerStem, 0.0);
    });
  });

  // ── Parsed flowers are BouquetFlower domain entities ──────────────────────
  group('CustomBouquetApiModel - flowers are BouquetFlower', () {
    test('parsed flowers should have correct subtotal', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      // Rose: 5 × 120 = 600
      expect(model.flowers[0].subtotal, 600.0);
    });

    test('parsed flowers should support copyWith', () {
      final model = CustomBouquetApiModel.fromJson(tFullJson);
      final updated = model.flowers[0].copyWith(count: 10);
      expect(updated.count, 10);
      expect(updated.flowerId, 'rose');
    });
  });
}
