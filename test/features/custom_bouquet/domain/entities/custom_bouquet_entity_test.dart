import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';

void main() {
  // ── Fixtures ───────────────────────────────────────────────────────────────
  const tRose = BouquetFlower(
    flowerId: 'rose',
    name: 'Rose',
    count: 5,
    pricePerStem: 120,
  );
  const tTulip = BouquetFlower(
    flowerId: 'tulip',
    name: 'Tulip',
    count: 3,
    pricePerStem: 90,
  );
  const tWrapping = BouquetWrapping(
    id: 'kraft',
    name: 'Kraft Paper',
    price: 50,
    color: '#EFE',
    darkColor: '#5D4',
  );

  // ── BouquetFlower ──────────────────────────────────────────────────────────
  group('BouquetFlower', () {
    test('subtotal should equal count × pricePerStem', () {
      expect(tRose.subtotal, 5 * 120.0);
      expect(tTulip.subtotal, 3 * 90.0);
    });

    test('subtotal should be 0 when count is 0', () {
      const flower = BouquetFlower(
        flowerId: 'f',
        name: 'F',
        count: 0,
        pricePerStem: 100,
      );
      expect(flower.subtotal, 0.0);
    });

    test('copyWith should update count only', () {
      final updated = tRose.copyWith(count: 10);
      expect(updated.count, 10);
      expect(updated.flowerId, tRose.flowerId);
      expect(updated.name, tRose.name);
      expect(updated.pricePerStem, tRose.pricePerStem);
    });

    test('copyWith without args should return equivalent flower', () {
      final same = tRose.copyWith();
      expect(same, tRose);
    });

    test('toJson should include all fields', () {
      final json = tRose.toJson();
      expect(json['flowerId'], 'rose');
      expect(json['name'], 'Rose');
      expect(json['count'], 5);
      expect(json['pricePerStem'], 120.0);
    });

    test('props should contain flowerId and count', () {
      expect(tRose.props, ['rose', 5]);
    });

    test('two flowers with same flowerId and count should be equal', () {
      const f1 = BouquetFlower(
        flowerId: 'rose',
        name: 'Rose',
        count: 5,
        pricePerStem: 120,
      );
      const f2 = BouquetFlower(
        flowerId: 'rose',
        name: 'Rose',
        count: 5,
        pricePerStem: 120,
      );
      expect(f1, f2);
    });

    test('two flowers with different count should not be equal', () {
      const f1 = BouquetFlower(
        flowerId: 'rose',
        name: 'Rose',
        count: 3,
        pricePerStem: 120,
      );
      const f2 = BouquetFlower(
        flowerId: 'rose',
        name: 'Rose',
        count: 5,
        pricePerStem: 120,
      );
      expect(f1, isNot(f2));
    });
  });

  // ── BouquetWrapping ────────────────────────────────────────────────────────
  group('BouquetWrapping', () {
    test('toJson should include id, name, and price', () {
      final json = tWrapping.toJson();
      expect(json['id'], 'kraft');
      expect(json['name'], 'Kraft Paper');
      expect(json['price'], 50.0);
    });

    test('props should contain id only', () {
      expect(tWrapping.props, ['kraft']);
    });

    test('two wrappings with same id should be equal', () {
      const w1 = BouquetWrapping(
        id: 'kraft',
        name: 'Kraft',
        price: 50,
        color: '#A',
        darkColor: '#B',
      );
      const w2 = BouquetWrapping(
        id: 'kraft',
        name: 'Kraft',
        price: 50,
        color: '#A',
        darkColor: '#B',
      );
      expect(w1, w2);
    });

    test('two wrappings with different id should not be equal', () {
      const w1 = BouquetWrapping(
        id: 'kraft',
        name: 'Kraft',
        price: 50,
        color: '#A',
        darkColor: '#B',
      );
      const w2 = BouquetWrapping(
        id: 'silk',
        name: 'Silk',
        price: 120,
        color: '#A',
        darkColor: '#B',
      );
      expect(w1, isNot(w2));
    });
  });

  // ── CustomBouquetEntity ────────────────────────────────────────────────────
  group('CustomBouquetEntity - computed properties', () {
    final tBouquet = const CustomBouquetEntity(
      flowers: [tRose, tTulip],
      wrapping: tWrapping,
      note: 'With love',
      recipientName: 'Alice',
    );

    test('totalStems should sum all flower counts', () {
      // 5 + 3 = 8
      expect(tBouquet.totalStems, 8);
    });

    test('totalStems should be 0 for empty bouquet', () {
      expect(const CustomBouquetEntity().totalStems, 0);
    });

    test('totalPrice should sum flower subtotals and wrapping price', () {
      // (5×120) + (3×90) + 50 = 600 + 270 + 50 = 920
      expect(tBouquet.totalPrice, 920.0);
    });

    test('totalPrice should exclude wrapping when null', () {
      final noWrap = CustomBouquetEntity(flowers: const [tRose]);
      // 5 × 120 = 600
      expect(noWrap.totalPrice, 600.0);
    });

    test('totalPrice should be 0 for empty bouquet', () {
      expect(const CustomBouquetEntity().totalPrice, 0.0);
    });
  });

  group('CustomBouquetEntity - copyWith', () {
    final tBouquet = const CustomBouquetEntity(
      flowers: [tRose],
      wrapping: tWrapping,
      note: 'Hello',
      recipientName: 'Bob',
    );

    test('copyWith should update flowers', () {
      final updated = tBouquet.copyWith(flowers: [tRose, tTulip]);
      expect(updated.flowers.length, 2);
      expect(updated.note, 'Hello'); // unchanged
    });

    test('copyWith should update note', () {
      final updated = tBouquet.copyWith(note: 'New note');
      expect(updated.note, 'New note');
      expect(updated.recipientName, 'Bob'); // unchanged
    });

    test('copyWith should update recipientName', () {
      final updated = tBouquet.copyWith(recipientName: 'Carol');
      expect(updated.recipientName, 'Carol');
    });

    test('copyWith with clearWrapping=true should set wrapping to null', () {
      final updated = tBouquet.copyWith(clearWrapping: true);
      expect(updated.wrapping, isNull);
    });

    test('copyWith without args should return equivalent bouquet', () {
      final same = tBouquet.copyWith();
      expect(same, tBouquet);
    });
  });

  group('CustomBouquetEntity - toPayload', () {
    test(
      'should include flowers, wrapping, note, recipientName, totalPrice',
      () {
        final bouquet = const CustomBouquetEntity(
          flowers: [tRose],
          wrapping: tWrapping,
          note: 'With love',
          recipientName: 'Alice',
        );
        final payload = bouquet.toPayload();

        expect(payload['flowers'], isA<List>());
        expect((payload['flowers'] as List).length, 1);
        expect(payload['wrapping'], isA<Map>());
        expect(payload['note'], 'With love');
        expect(payload['recipientName'], 'Alice');
        expect(payload['totalPrice'], isA<double>());
      },
    );

    test('should trim note and recipientName in payload', () {
      final bouquet = const CustomBouquetEntity(
        note: '  hello  ',
        recipientName: '  Alice  ',
      );
      final payload = bouquet.toPayload();

      expect(payload['note'], 'hello');
      expect(payload['recipientName'], 'Alice');
    });

    test('wrapping should be null in payload when not selected', () {
      final payload = const CustomBouquetEntity().toPayload();
      expect(payload['wrapping'], isNull);
    });
  });

  group('CustomBouquetEntity - props and equality', () {
    test('props should contain flowers, wrapping, note, recipientName', () {
      final bouquet = CustomBouquetEntity(
        flowers: const [tRose],
        wrapping: tWrapping,
        note: 'Hi',
        recipientName: 'Bob',
      );
      expect(bouquet.props, [
        [tRose],
        tWrapping,
        'Hi',
        'Bob',
      ]);
    });

    test('two bouquets with same values should be equal', () {
      const b1 = CustomBouquetEntity(note: 'Same');
      const b2 = CustomBouquetEntity(note: 'Same');
      expect(b1, b2);
    });

    test('two bouquets with different notes should not be equal', () {
      const b1 = CustomBouquetEntity(note: 'A');
      const b2 = CustomBouquetEntity(note: 'B');
      expect(b1, isNot(b2));
    });
  });
}
