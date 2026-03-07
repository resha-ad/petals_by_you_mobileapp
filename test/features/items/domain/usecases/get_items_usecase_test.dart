import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_items_usecase.dart';

class MockItemRepository extends Mock implements IItemRepository {}

void main() {
  late GetItemsUsecase usecase;
  late MockItemRepository mockRepository;

  setUp(() {
    mockRepository = MockItemRepository();
    usecase = GetItemsUsecase(repository: mockRepository);
  });

  final tItems = [
    const ItemEntity(
      id: 'item_1',
      name: 'Red Roses',
      slug: 'red-roses',
      description: 'Beautiful red roses',
      price: 1500,
      images: ['img1.jpg'],
      isFeatured: true,
      isAvailable: true,
      stock: 10,
      rating: 4.5,
      numReviews: 20,
    ),
    const ItemEntity(
      id: 'item_2',
      name: 'Pink Tulips',
      slug: 'pink-tulips',
      description: 'Fresh pink tulips',
      price: 1200,
      images: [],
      isFeatured: false,
      isAvailable: true,
      stock: 5,
      rating: 4.0,
      numReviews: 10,
    ),
  ];

  final tDataResult = DataResult(tItems, fromCache: false);

  const tDefaultParams = GetItemsParams();

  group('GetItemsUsecase', () {
    test(
      'should return DataResult with items when repository succeeds',
      () async {
        // Arrange
        when(
          () => mockRepository.getItems(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
            category: any(named: 'category'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            featured: any(named: 'featured'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => Right(tDataResult));

        // Act
        final result = await usecase(tDefaultParams);

        // Assert
        expect(result.isRight(), true);
        result.fold((_) => fail('Should be Right'), (data) {
          expect(data.data, tItems);
          expect(data.fromCache, false);
        });
      },
    );

    test('should pass page and limit to repository', () async {
      // Arrange
      when(
        () => mockRepository.getItems(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          featured: any(named: 'featured'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => Right(tDataResult));

      const params = GetItemsParams(page: 2, limit: 5);

      // Act
      await usecase(params);

      // Assert
      verify(
        () => mockRepository.getItems(
          page: 2,
          limit: 5,
          search: null,
          category: null,
          minPrice: null,
          maxPrice: null,
          featured: null,
          sort: null,
        ),
      ).called(1);
    });

    test('should pass all filter params to repository', () async {
      // Arrange
      when(
        () => mockRepository.getItems(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          featured: any(named: 'featured'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => Right(tDataResult));

      const params = GetItemsParams(
        page: 1,
        limit: 10,
        search: 'roses',
        category: 'bouquets',
        minPrice: 500,
        maxPrice: 2000,
        featured: true,
        sort: 'price:asc',
      );

      // Act
      await usecase(params);

      // Assert
      verify(
        () => mockRepository.getItems(
          page: 1,
          limit: 10,
          search: 'roses',
          category: 'bouquets',
          minPrice: 500,
          maxPrice: 2000,
          featured: true,
          sort: 'price:asc',
        ),
      ).called(1);
    });

    test('should return ApiFailure when repository fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch items');
      when(
        () => mockRepository.getItems(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          featured: any(named: 'featured'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tDefaultParams);

      // Assert
      expect(result, const Left(failure));
    });

    test(
      'should return LocalDatabaseFailure when offline and no cache',
      () async {
        // Arrange
        const failure = LocalDatabaseFailure(
          message: 'No internet and no cached data',
        );
        when(
          () => mockRepository.getItems(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
            search: any(named: 'search'),
            category: any(named: 'category'),
            minPrice: any(named: 'minPrice'),
            maxPrice: any(named: 'maxPrice'),
            featured: any(named: 'featured'),
            sort: any(named: 'sort'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tDefaultParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<LocalDatabaseFailure>()),
          (_) => fail('Should be Left'),
        );
      },
    );

    test('should return fromCache=true when data comes from cache', () async {
      // Arrange
      final cachedResult = DataResult(tItems, fromCache: true);
      when(
        () => mockRepository.getItems(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          featured: any(named: 'featured'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => Right(cachedResult));

      // Act
      final result = await usecase(tDefaultParams);

      // Assert
      result.fold(
        (_) => fail('Should be Right'),
        (data) => expect(data.fromCache, true),
      );
    });

    test('should return empty list when repository returns no items', () async {
      // Arrange
      final emptyResult = DataResult(<ItemEntity>[], fromCache: false);
      when(
        () => mockRepository.getItems(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
          search: any(named: 'search'),
          category: any(named: 'category'),
          minPrice: any(named: 'minPrice'),
          maxPrice: any(named: 'maxPrice'),
          featured: any(named: 'featured'),
          sort: any(named: 'sort'),
        ),
      ).thenAnswer((_) async => Right(emptyResult));

      // Act
      final result = await usecase(tDefaultParams);

      // Assert
      result.fold(
        (_) => fail('Should be Right'),
        (data) => expect(data.data, isEmpty),
      );
    });
  });

  group('GetItemsParams', () {
    test('should have default values', () {
      const params = GetItemsParams();
      expect(params.page, 1);
      expect(params.limit, 10);
      expect(params.search, isNull);
      expect(params.category, isNull);
      expect(params.minPrice, isNull);
      expect(params.maxPrice, isNull);
      expect(params.featured, isNull);
      expect(params.sort, isNull);
    });

    test('two params with same values should be equal', () {
      const p1 = GetItemsParams(page: 1, limit: 10, category: 'bouquets');
      const p2 = GetItemsParams(page: 1, limit: 10, category: 'bouquets');
      expect(p1, p2);
    });

    test('two params with different category should not be equal', () {
      const p1 = GetItemsParams(category: 'bouquets');
      const p2 = GetItemsParams(category: 'flowers');
      expect(p1, isNot(p2));
    });

    test('props should include all fields', () {
      const params = GetItemsParams(
        page: 2,
        limit: 5,
        search: 'roses',
        category: 'bouquets',
        minPrice: 500,
        maxPrice: 2000,
        featured: true,
        sort: 'price:asc',
      );
      expect(params.props, [
        2,
        5,
        'roses',
        'bouquets',
        500.0,
        2000.0,
        true,
        'price:asc',
      ]);
    });
  });
}
