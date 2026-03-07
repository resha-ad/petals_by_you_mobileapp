import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/stock_override_service.dart';
import 'package:sprint1_project/features/items/data/repositories/item_repository.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_item_by_id_usecase.dart';
import 'package:sprint1_project/features/items/domain/usecases/get_items_usecase.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';
import 'package:sprint1_project/features/items/presentation/view_model/item_view_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockGetItemsUsecase extends Mock implements GetItemsUsecase {}

class MockGetItemByIdUsecase extends Mock implements GetItemByIdUsecase {}

class MockStockOverrideService extends Mock implements StockOverrideService {}

void main() {
  late MockGetItemsUsecase mockGetItemsUsecase;
  late MockGetItemByIdUsecase mockGetItemByIdUsecase;
  late MockStockOverrideService mockStockOverride;
  late ProviderContainer container;

  // ── Fixtures ──────────────────────────────────────────────────────────────
  const tItem1 = ItemEntity(
    id: 'item_1',
    name: 'Red Roses',
    slug: 'red-roses',
    description: 'Beautiful roses',
    price: 1500,
    images: ['img1.jpg'],
    isFeatured: true,
    isAvailable: true,
    stock: 10,
    rating: 4.5,
    numReviews: 20,
    category: 'bouquets',
  );
  const tItem2 = ItemEntity(
    id: 'item_2',
    name: 'Pink Tulips',
    slug: 'pink-tulips',
    description: 'Fresh tulips',
    price: 1200,
    images: [],
    isFeatured: false,
    isAvailable: true,
    stock: 5,
    rating: 4.0,
    numReviews: 10,
  );

  final tItemList = [tItem1, tItem2];

  setUpAll(() {
    registerFallbackValue(const GetItemsParams());
    registerFallbackValue(const GetItemByIdParams(itemId: 'fallback'));
    // Required because MockStockOverrideService.applyToList/applyToItem
    // use any() on ItemEntity and List<ItemEntity> types.
    registerFallbackValue(
      const ItemEntity(
        id: 'fallback',
        name: 'fallback',
        slug: 'fallback',
        description: 'fallback',
        price: 0,
        images: [],
        isFeatured: false,
        isAvailable: false,
        stock: 0,
        rating: 0,
        numReviews: 0,
      ),
    );
    registerFallbackValue(<ItemEntity>[]);
  });

  setUp(() {
    mockGetItemsUsecase = MockGetItemsUsecase();
    mockGetItemByIdUsecase = MockGetItemByIdUsecase();
    mockStockOverride = MockStockOverrideService();

    // Default stock override behaviour: pass items through unchanged
    when(() => mockStockOverride.load()).thenAnswer((_) async {});
    when(() => mockStockOverride.applyToList(any())).thenAnswer(
      (invocation) => invocation.positionalArguments[0] as List<ItemEntity>,
    );
    when(() => mockStockOverride.applyToItem(any())).thenAnswer(
      (invocation) => invocation.positionalArguments[0] as ItemEntity,
    );

    container = ProviderContainer(
      overrides: [
        getItemsUsecaseProvider.overrideWithValue(mockGetItemsUsecase),
        getItemByIdUsecaseProvider.overrideWithValue(mockGetItemByIdUsecase),
        stockOverrideServiceProvider.overrideWithValue(mockStockOverride),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── Initial state ─────────────────────────────────────────────────────────
  group('initial state', () {
    test('should have initial status', () {
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.initial);
      expect(state.items, isEmpty);
      expect(state.selectedItem, isNull);
      expect(state.errorMessage, isNull);
      expect(state.currentPage, 1);
      expect(state.hasMore, true);
      expect(state.isFromCache, false);
    });
  });

  // ── loadItems ─────────────────────────────────────────────────────────────
  group('loadItems', () {
    test('should emit loaded status with items when successful', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.loaded);
      expect(state.items, tItemList);
      expect(state.isFromCache, false);
      expect(state.errorMessage, isNull);
    });

    test('should emit loading then loaded in correct order', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      final statuses = <ItemStatus>[];
      container.listen(
        itemViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      expect(statuses, [ItemStatus.loading, ItemStatus.loaded]);
    });

    test('should emit error status when usecase fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch items');
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.error);
      expect(state.errorMessage, 'Failed to fetch items');
    });

    test('should emit loading then error in correct order', () async {
      // Arrange
      const failure = ApiFailure(message: 'Server error');
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final statuses = <ItemStatus>[];
      container.listen(
        itemViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      expect(statuses, [ItemStatus.loading, ItemStatus.error]);
    });

    test('should set fromCache=true when data comes from cache', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: true);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.isFromCache, true);
    });

    test('should reset page to 1 on each new load', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.currentPage, 1);
    });

    test('should set hasMore=false when items fewer than page size', () async {
      // Arrange — only 2 items, page size is 10
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.hasMore, false); // 2 < 10
    });

    test('should apply category filter', () async {
      // Arrange
      final dataResult = DataResult([tItem1], fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .loadItems(category: 'bouquets');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.activeCategory, 'bouquets');

      final captured =
          verify(() => mockGetItemsUsecase(captureAny())).captured.first
              as GetItemsParams;
      expect(captured.category, 'bouquets');
    });

    test('should apply search filter', () async {
      // Arrange
      final dataResult = DataResult([tItem1], fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .loadItems(search: 'roses');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.activeSearch, 'roses');
    });

    test('should apply sort filter', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .loadItems(sort: 'price:asc');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.activeSort, 'price:asc');
    });

    test('should call stockOverride.load() before applying items', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      verify(() => mockStockOverride.load()).called(1);
      verify(() => mockStockOverride.applyToList(tItemList)).called(1);
    });

    test('should handle LocalDatabaseFailure when offline', () async {
      // Arrange
      const failure = LocalDatabaseFailure(
        message: 'No internet and no cached data',
      );
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.error);
      expect(state.errorMessage, 'No internet and no cached data');
    });
  });

  // ── loadMore ──────────────────────────────────────────────────────────────
  group('loadMore', () {
    test('should append items when loadMore succeeds', () async {
      // Arrange — first load 10 items (full page)
      final page1Items = List.generate(
        10,
        (i) => ItemEntity(
          id: 'item_$i',
          name: 'Item $i',
          slug: 'item-$i',
          description: 'desc',
          price: 100,
          images: [],
          isFeatured: false,
          isAvailable: true,
          stock: 5,
          rating: 3,
          numReviews: 1,
        ),
      );
      final page1Result = DataResult(page1Items, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(page1Result));
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Second call returns page 2
      final page2Items = [tItem1, tItem2];
      final page2Result = DataResult(page2Items, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(page2Result));

      // Act
      await container.read(itemViewModelProvider.notifier).loadMore();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.items.length, 12); // 10 + 2
      expect(state.currentPage, 2);
    });

    test('should not loadMore when hasMore=false', () async {
      // Arrange — load with < 10 items so hasMore=false
      final dataResult = DataResult([tItem1], fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Act
      await container.read(itemViewModelProvider.notifier).loadMore();

      // Assert — only one call (from loadItems)
      verify(() => mockGetItemsUsecase(any())).called(1);
    });

    test('should not loadMore when data is from cache', () async {
      // Arrange — cache data
      final dataResult = DataResult(
        List.generate(10, (i) => tItem1),
        fromCache: true,
      );
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Act
      await container.read(itemViewModelProvider.notifier).loadMore();

      // Assert — only the initial loadItems call
      verify(() => mockGetItemsUsecase(any())).called(1);
    });

    test('should set hasMore=false when loadMore returns empty list', () async {
      // Arrange — first fill page 1
      final page1Items = List.generate(10, (i) => tItem1);
      when(() => mockGetItemsUsecase(any())).thenAnswer(
        (_) async => Right(DataResult(page1Items, fromCache: false)),
      );
      await container.read(itemViewModelProvider.notifier).loadItems();

      // loadMore returns empty
      when(() => mockGetItemsUsecase(any())).thenAnswer(
        (_) async => Right(DataResult(<ItemEntity>[], fromCache: false)),
      );

      // Act
      await container.read(itemViewModelProvider.notifier).loadMore();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.hasMore, false);
    });
  });

  // ── getItemById ───────────────────────────────────────────────────────────
  group('getItemById', () {
    test('should emit loaded with selectedItem when successful', () async {
      // Arrange
      final dataResult = DataResult(tItem1, fromCache: false);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('item_1');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.loaded);
      expect(state.selectedItem, tItem1);
      expect(state.isFromCache, false);
    });

    test('should emit loading then loaded in correct order', () async {
      // Arrange
      final dataResult = DataResult(tItem1, fromCache: false);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      final statuses = <ItemStatus>[];
      container.listen(
        itemViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('item_1');

      // Assert
      expect(statuses, [ItemStatus.loading, ItemStatus.loaded]);
    });

    test('should emit error status when item is not found', () async {
      // Arrange
      const failure = ApiFailure(message: 'Item not found', statusCode: 404);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('bad_id');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.error);
      expect(state.errorMessage, 'Item not found');
      expect(state.selectedItem, isNull);
    });

    test('should set fromCache=true when served from cache', () async {
      // Arrange
      final dataResult = DataResult(tItem1, fromCache: true);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('item_1');

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.isFromCache, true);
    });

    test('should pass correct id to usecase', () async {
      // Arrange
      final dataResult = DataResult(tItem1, fromCache: false);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('item_1');

      // Assert
      final captured =
          verify(() => mockGetItemByIdUsecase(captureAny())).captured.first
              as GetItemByIdParams;
      expect(captured.itemId, 'item_1');
    });

    test('should call stockOverride before setting item', () async {
      // Arrange
      final dataResult = DataResult(tItem1, fromCache: false);
      when(
        () => mockGetItemByIdUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .getItemById('item_1');

      // Assert
      verify(() => mockStockOverride.load()).called(1);
      verify(() => mockStockOverride.applyToItem(tItem1)).called(1);
    });
  });

  // ── search ────────────────────────────────────────────────────────────────
  group('search', () {
    test('should load items with search query', () async {
      // Arrange
      final dataResult = DataResult([tItem1], fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).search('roses');

      // Assert
      final captured =
          verify(() => mockGetItemsUsecase(captureAny())).captured.first
              as GetItemsParams;
      expect(captured.search, 'roses');
    });

    test('should load with null search when query is empty', () async {
      // Arrange
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container.read(itemViewModelProvider.notifier).search('');

      // Assert
      final captured =
          verify(() => mockGetItemsUsecase(captureAny())).captured.first
              as GetItemsParams;
      expect(captured.search, isNull);
    });
  });

  // ── applyFilter ───────────────────────────────────────────────────────────
  group('applyFilter', () {
    test('should load items with category and sort filter', () async {
      // Arrange
      final dataResult = DataResult([tItem1], fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));

      // Act
      await container
          .read(itemViewModelProvider.notifier)
          .applyFilter(category: 'bouquets', sort: 'price:asc');

      // Assert
      final captured =
          verify(() => mockGetItemsUsecase(captureAny())).captured.first
              as GetItemsParams;
      expect(captured.category, 'bouquets');
      expect(captured.sort, 'price:asc');
    });
  });

  // ── clearError ────────────────────────────────────────────────────────────
  group('clearError', () {
    test('should reset to loaded status and clear error message', () async {
      // Arrange — trigger error first
      const failure = ApiFailure(message: 'Server error');
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      await container.read(itemViewModelProvider.notifier).loadItems();

      expect(container.read(itemViewModelProvider).status, ItemStatus.error);

      // Act
      container.read(itemViewModelProvider.notifier).clearError();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.loaded);
      expect(state.errorMessage, isNull);
    });
  });

  // ── clearSearch/resetSearch ───────────────────────────────────────────────
  group('clearSearch / resetSearch', () {
    test('clearSearch should reset state to initial', () async {
      // Arrange — load items first
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Act
      container.read(itemViewModelProvider.notifier).clearSearch();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state, const ItemState());
    });

    test('resetSearch should reset state to initial', () async {
      // Arrange — load items first
      final dataResult = DataResult(tItemList, fromCache: false);
      when(
        () => mockGetItemsUsecase(any()),
      ).thenAnswer((_) async => Right(dataResult));
      await container.read(itemViewModelProvider.notifier).loadItems();

      // Act
      container.read(itemViewModelProvider.notifier).resetSearch();

      // Assert
      final state = container.read(itemViewModelProvider);
      expect(state.status, ItemStatus.initial);
      expect(state.items, isEmpty);
    });
  });

  // ── ItemState unit tests ──────────────────────────────────────────────────
  group('ItemState', () {
    test('should have correct initial values', () {
      const s = ItemState();
      expect(s.status, ItemStatus.initial);
      expect(s.items, isEmpty);
      expect(s.selectedItem, isNull);
      expect(s.errorMessage, isNull);
      expect(s.currentPage, 1);
      expect(s.hasMore, true);
      expect(s.isFromCache, false);
    });

    test('copyWith should update only specified fields', () {
      const s = ItemState();
      final updated = s.copyWith(
        status: ItemStatus.loaded,
        items: [tItem1],
        currentPage: 2,
      );
      expect(updated.status, ItemStatus.loaded);
      expect(updated.items, [tItem1]);
      expect(updated.currentPage, 2);
      expect(updated.hasMore, true); // unchanged
      expect(updated.isFromCache, false); // unchanged
    });

    test('clearSelectedItem=true should set selectedItem to null', () {
      final s = const ItemState().copyWith(selectedItem: tItem1);
      final cleared = s.copyWith(clearSelectedItem: true);
      expect(cleared.selectedItem, isNull);
    });

    test('clearErrorMessage=true should clear errorMessage', () {
      const s = ItemState(errorMessage: 'Some error');
      final cleared = s.copyWith(clearErrorMessage: true);
      expect(cleared.errorMessage, isNull);
    });

    test('clearActiveCategory=true should clear activeCategory', () {
      const s = ItemState(activeCategory: 'bouquets');
      final cleared = s.copyWith(clearActiveCategory: true);
      expect(cleared.activeCategory, isNull);
    });

    test('two states with same values should be equal', () {
      const s1 = ItemState(status: ItemStatus.loading);
      const s2 = ItemState(status: ItemStatus.loading);
      expect(s1, s2);
    });

    test('two states with different status should not be equal', () {
      const s1 = ItemState(status: ItemStatus.loading);
      const s2 = ItemState(status: ItemStatus.loaded);
      expect(s1, isNot(s2));
    });

    test('props should include all relevant fields', () {
      const s = ItemState(
        status: ItemStatus.loaded,
        currentPage: 2,
        hasMore: false,
        isFromCache: true,
      );
      expect(s.props, contains(ItemStatus.loaded));
      expect(s.props, contains(2));
      expect(s.props, contains(false));
      expect(s.props, contains(true));
    });
  });

  // ── ItemStatus enum coverage ──────────────────────────────────────────────
  group('ItemStatus', () {
    test('all status values should exist', () {
      expect(ItemStatus.values, contains(ItemStatus.initial));
      expect(ItemStatus.values, contains(ItemStatus.loading));
      expect(ItemStatus.values, contains(ItemStatus.loadingMore));
      expect(ItemStatus.values, contains(ItemStatus.loaded));
      expect(ItemStatus.values, contains(ItemStatus.error));
    });
  });
}
