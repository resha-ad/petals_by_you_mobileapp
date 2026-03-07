import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_item_by_id_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late GetItemByIdUsecase usecase;
  late MockItemRepository mockRepository;

  setUp(() {
    mockRepository = MockItemRepository();
    usecase = GetItemByIdUsecase(repository: mockRepository);
  });

  const tItemId = 'item_123';
  const tParams = GetItemByIdParams(itemId: tItemId);

  const tItemEntity = ItemEntity(
    id: tItemId,
    name: 'Red Roses',
    slug: 'red-roses',
    description: 'A beautiful arrangement of red roses',
    price: 1500,
    discountPrice: 1200,
    category: 'bouquets',
    images: ['img1.jpg', 'img2.jpg'],
    isFeatured: true,
    isAvailable: true,
    stock: 8,
    rating: 4.8,
    numReviews: 42,
    preparationTime: 30,
    deliveryType: 'standard',
  );

  group('GetItemByIdUsecase', () {
    test(
      'should return DataResult with item when repository succeeds',
      () async {
        // Arrange
        final tDataResult = DataResult(tItemEntity, fromCache: false);
        when(
          () => mockRepository.getItemById(tItemId),
        ).thenAnswer((_) async => Right(tDataResult));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should be Right'), (data) {
          expect(data.data, tItemEntity);
          expect(data.fromCache, false);
        });
        verify(() => mockRepository.getItemById(tItemId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should pass correct item id to repository', () async {
      // Arrange
      final tDataResult = DataResult(tItemEntity, fromCache: false);
      when(
        () => mockRepository.getItemById(any()),
      ).thenAnswer((_) async => Right(tDataResult));

      // Act
      await usecase(tParams);

      // Assert
      final captured =
          verify(() => mockRepository.getItemById(captureAny())).captured.first
              as String;
      expect(captured, tItemId);
    });

    test('should return ApiFailure when item is not found', () async {
      // Arrange
      const failure = ApiFailure(message: 'Item not found', statusCode: 404);
      when(
        () => mockRepository.getItemById(tItemId),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 404);
      }, (_) => fail('Should be Left'));
    });

    test(
      'should return LocalDatabaseFailure when offline and not cached',
      () async {
        // Arrange
        const failure = LocalDatabaseFailure(
          message: 'No internet and item not cached',
        );
        when(
          () => mockRepository.getItemById(tItemId),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tParams);

        // Assert
        result.fold(
          (f) => expect(f, isA<LocalDatabaseFailure>()),
          (_) => fail('Should be Left'),
        );
      },
    );

    test('should return fromCache=true when item served from cache', () async {
      // Arrange
      final cachedResult = DataResult(tItemEntity, fromCache: true);
      when(
        () => mockRepository.getItemById(tItemId),
      ).thenAnswer((_) async => Right(cachedResult));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold(
        (_) => fail('Should be Right'),
        (data) => expect(data.fromCache, true),
      );
    });

    test('should return correct item fields on success', () async {
      // Arrange
      final tDataResult = DataResult(tItemEntity, fromCache: false);
      when(
        () => mockRepository.getItemById(tItemId),
      ).thenAnswer((_) async => Right(tDataResult));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((_) => fail('Should be Right'), (data) {
        final item = data.data;
        expect(item.id, tItemId);
        expect(item.name, 'Red Roses');
        expect(item.price, 1500);
        expect(item.discountPrice, 1200);
        expect(item.effectivePrice, 1200);
        expect(item.hasDiscount, true);
        expect(item.isFeatured, true);
        expect(item.stock, 8);
        expect(item.images.length, 2);
        expect(item.primaryImage, 'img1.jpg');
      });
    });
  });

  group('GetItemByIdParams', () {
    test('should have correct itemId', () {
      expect(tParams.itemId, tItemId);
    });

    test('props should include itemId', () {
      expect(tParams.props, [tItemId]);
    });

    test('two params with same itemId should be equal', () {
      const p1 = GetItemByIdParams(itemId: 'abc');
      const p2 = GetItemByIdParams(itemId: 'abc');
      expect(p1, p2);
    });

    test('two params with different itemId should not be equal', () {
      const p1 = GetItemByIdParams(itemId: 'abc');
      const p2 = GetItemByIdParams(itemId: 'xyz');
      expect(p1, isNot(p2));
    });
  });

  group('ItemEntity computed properties', () {
    test('effectivePrice should return discountPrice when present', () {
      expect(tItemEntity.effectivePrice, 1200);
    });

    test('effectivePrice should return price when no discount', () {
      const entity = ItemEntity(
        id: '1',
        name: 'Test',
        slug: 'test',
        description: 'desc',
        price: 1000,
        images: [],
        isFeatured: false,
        isAvailable: true,
        stock: 5,
        rating: 3,
        numReviews: 1,
      );
      expect(entity.effectivePrice, 1000);
    });

    test('hasDiscount should be true when discountPrice < price', () {
      expect(tItemEntity.hasDiscount, true);
    });

    test('hasDiscount should be false when no discountPrice', () {
      const entity = ItemEntity(
        id: '1',
        name: 'Test',
        slug: 'test',
        description: 'desc',
        price: 1000,
        images: [],
        isFeatured: false,
        isAvailable: true,
        stock: 5,
        rating: 3,
        numReviews: 1,
      );
      expect(entity.hasDiscount, false);
    });

    test(
      'primaryImage should return first image when images are not empty',
      () {
        expect(tItemEntity.primaryImage, 'img1.jpg');
      },
    );

    test('primaryImage should return null when images are empty', () {
      const entity = ItemEntity(
        id: '1',
        name: 'Test',
        slug: 'test',
        description: 'desc',
        price: 1000,
        images: [],
        isFeatured: false,
        isAvailable: true,
        stock: 5,
        rating: 3,
        numReviews: 1,
      );
      expect(entity.primaryImage, isNull);
    });

    test('two entities with same values should be equal', () {
      const e1 = ItemEntity(
        id: '1',
        name: 'Roses',
        slug: 'roses',
        description: 'desc',
        price: 500,
        images: ['a.jpg'],
        isFeatured: false,
        isAvailable: true,
        stock: 3,
        rating: 4,
        numReviews: 5,
      );
      const e2 = ItemEntity(
        id: '1',
        name: 'Roses',
        slug: 'roses',
        description: 'desc',
        price: 500,
        images: ['a.jpg'],
        isFeatured: false,
        isAvailable: true,
        stock: 3,
        rating: 4,
        numReviews: 5,
      );
      expect(e1, e2);
    });
  });
}
