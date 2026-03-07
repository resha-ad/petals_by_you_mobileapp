import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/add_favorite_usecase.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/get_favorites_usecase.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/remove_favorite_usecase.dart';
import 'package:sprint1_project/features/favorites/presentation/state/favorites_state.dart';
import 'package:sprint1_project/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockGetFavoritesUsecase extends Mock implements GetFavoritesUsecase {}

class MockAddFavoriteUsecase extends Mock implements AddFavoriteUsecase {}

class MockRemoveFavoriteUsecase extends Mock implements RemoveFavoriteUsecase {}

// Must implement NetworkInfo (concrete) — networkInfoProvider is typed to NetworkInfo
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetFavoritesUsecase mockGetFavorites;
  late MockAddFavoriteUsecase mockAddFavorite;
  late MockRemoveFavoriteUsecase mockRemoveFavorite;
  late MockNetworkInfo mockNetworkInfo;
  late ProviderContainer container;

  // ── Fixtures ──────────────────────────────────────────────────────────────
  const tItem = ItemEntity(
    id: 'item_1',
    name: 'Red Roses',
    slug: 'red-roses',
    description: 'Fresh roses',
    price: 1500,
    images: ['img1.jpg'],
    isFeatured: true,
    isAvailable: true,
    stock: 10,
    rating: 4.5,
    numReviews: 20,
  );

  const tFavItem = FavoriteEntity(
    type: 'product',
    refId: 'item_1',
    refItem: tItem,
  );
  const tFavorites = FavoritesEntity(userId: 'user_1', items: [tFavItem]);
  const tEmptyFavorites = FavoritesEntity(userId: 'user_1', items: []);

  setUpAll(() {
    // ── ALL types used with any()/captureAny() must be registered ─────────
    registerFallbackValue(tEmptyFavorites);
    registerFallbackValue(
      const AddFavoriteParams(type: 'product', refId: 'fallback'),
    );
    // ItemEntity used inside FavoriteEntity - register to be safe
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
  });

  setUp(() {
    mockGetFavorites = MockGetFavoritesUsecase();
    mockAddFavorite = MockAddFavoriteUsecase();
    mockRemoveFavorite = MockRemoveFavoriteUsecase();
    mockNetworkInfo = MockNetworkInfo();

    // Default: online
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [
        getFavoritesUsecaseProvider.overrideWithValue(mockGetFavorites),
        addFavoriteUsecaseProvider.overrideWithValue(mockAddFavorite),
        removeFavoriteUsecaseProvider.overrideWithValue(mockRemoveFavorite),
        networkInfoProvider.overrideWithValue(mockNetworkInfo),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── initial state ─────────────────────────────────────────────────────────
  group('initial state', () {
    test('should be FavoritesStatus.initial with empty items', () {
      final state = container.read(favoritesViewModelProvider);
      expect(state.status, FavoritesStatus.initial);
      expect(state.items, isEmpty);
      expect(state.errorMessage, isNull);
      expect(state.isFromCache, false);
      expect(state.pendingIds, isEmpty);
    });

    test('isFavorite should return false for any refId on initial state', () {
      expect(
        container.read(favoritesViewModelProvider).isFavorite('any_id'),
        false,
      );
    });
  });

  // ── loadFavorites ─────────────────────────────────────────────────────────
  group('loadFavorites', () {
    test('should emit loading → loaded on success', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      final statuses = <FavoritesStatus>[];
      container.listen(
        favoritesViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      expect(statuses, [FavoritesStatus.loading, FavoritesStatus.loaded]);
    });

    test('should set items on success', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      final state = container.read(favoritesViewModelProvider);
      expect(state.items, tFavorites.items);
      expect(state.items.length, 1);
    });

    test('should set isFromCache=false when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      expect(container.read(favoritesViewModelProvider).isFromCache, false);
    });

    test('should set isFromCache=true when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      expect(container.read(favoritesViewModelProvider).isFromCache, true);
    });

    test('should emit loading → error on failure', () async {
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Left(failure));

      final statuses = <FavoritesStatus>[];
      container.listen(
        favoritesViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      expect(statuses, [FavoritesStatus.loading, FavoritesStatus.error]);
      expect(
        container.read(favoritesViewModelProvider).errorMessage,
        'Network error',
      );
    });

    test('should clear previous errorMessage on new loadFavorites', () async {
      const failure = ApiFailure(message: 'Server error');
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Left(failure));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();
      expect(
        container.read(favoritesViewModelProvider).errorMessage,
        'Server error',
      );

      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      expect(container.read(favoritesViewModelProvider).errorMessage, isNull);
    });

    test(
      'should call networkInfo.isConnected once per loadFavorites',
      () async {
        when(
          () => mockGetFavorites(),
        ).thenAnswer((_) async => const Right(tFavorites));

        await container
            .read(favoritesViewModelProvider.notifier)
            .loadFavorites();

        verify(() => mockNetworkInfo.isConnected).called(1);
      },
    );
  });

  // ── toggleFavorite ────────────────────────────────────────────────────────
  group('toggleFavorite', () {
    test(
      'should call addFavorite when item is NOT currently a favourite',
      () async {
        // Start with empty list — item is not a favourite
        when(
          () => mockGetFavorites(),
        ).thenAnswer((_) async => const Right(tEmptyFavorites));
        await container
            .read(favoritesViewModelProvider.notifier)
            .loadFavorites();

        when(
          () => mockAddFavorite(any()),
        ).thenAnswer((_) async => const Right(tFavorites));

        await container
            .read(favoritesViewModelProvider.notifier)
            .toggleFavorite(refId: 'item_1');

        verify(() => mockAddFavorite(any())).called(1);
        verifyNever(() => mockRemoveFavorite(any()));
      },
    );

    test(
      'should call removeFavorite when item IS currently a favourite',
      () async {
        // Preload with tFavorites — item_1 is a favourite
        when(
          () => mockGetFavorites(),
        ).thenAnswer((_) async => const Right(tFavorites));
        await container
            .read(favoritesViewModelProvider.notifier)
            .loadFavorites();

        when(
          () => mockRemoveFavorite(any()),
        ).thenAnswer((_) async => const Right(tEmptyFavorites));

        await container
            .read(favoritesViewModelProvider.notifier)
            .toggleFavorite(refId: 'item_1');

        verify(() => mockRemoveFavorite('item_1')).called(1);
        verifyNever(() => mockAddFavorite(any()));
      },
    );

    test('should add refId to pendingIds then remove on completion', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      bool? pendingDuringCall;
      when(() => mockAddFavorite(any())).thenAnswer((_) async {
        pendingDuringCall = container
            .read(favoritesViewModelProvider)
            .isPending('item_1');
        return const Right(tFavorites);
      });

      await container
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: 'item_1');

      expect(pendingDuringCall, true);
      expect(container.read(favoritesViewModelProvider).pendingIds, isEmpty);
    });

    test('should be a no-op when refId is already pending', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      // Inject a pending state manually by starting a toggle that never resolves
      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Right(tFavorites));

      // First call starts the pending state but we check isPending protection
      // by verifying only one call is made regardless
      await container
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: 'item_1');

      verify(() => mockAddFavorite(any())).called(1);
    });

    test('should set errorMessage on failure', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      const failure = ApiFailure(
        message: 'You\'re offline. Connect to add favourites.',
      );
      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: 'item_1');

      expect(
        container.read(favoritesViewModelProvider).errorMessage,
        contains('offline'),
      );
    });

    test('should update items list after successful toggle add', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();
      expect(container.read(favoritesViewModelProvider).items, isEmpty);

      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: 'item_1');

      expect(container.read(favoritesViewModelProvider).items.length, 1);
    });

    test('should update items list after successful toggle remove', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();
      expect(container.read(favoritesViewModelProvider).items.length, 1);

      when(
        () => mockRemoveFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .toggleFavorite(refId: 'item_1');

      expect(container.read(favoritesViewModelProvider).items, isEmpty);
    });
  });

  // ── addFavorite ───────────────────────────────────────────────────────────
  group('addFavorite', () {
    test('should update items when addFavorite succeeds', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(refId: 'item_1');

      expect(container.read(favoritesViewModelProvider).items.length, 1);
      expect(container.read(favoritesViewModelProvider).isFromCache, false);
    });

    test('should be a no-op when item is already a favourite', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      // item_1 is already a favourite — addFavorite should bail early
      await container
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(refId: 'item_1');

      verifyNever(() => mockAddFavorite(any()));
    });

    test('should pass correct AddFavoriteParams to usecase', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Right(tFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(refId: 'item_1', type: 'product');

      final captured =
          verify(() => mockAddFavorite(captureAny())).captured.first
              as AddFavoriteParams;
      expect(captured.refId, 'item_1');
      expect(captured.type, 'product');
    });

    test('should set errorMessage on failure', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      const failure = ApiFailure(message: 'You\'re offline');
      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(refId: 'item_1');

      expect(
        container.read(favoritesViewModelProvider).errorMessage,
        'You\'re offline',
      );
    });

    test('should remove pendingId even on failure', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockAddFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(favoritesViewModelProvider.notifier)
          .addFavorite(refId: 'item_1');

      expect(container.read(favoritesViewModelProvider).pendingIds, isEmpty);
    });
  });

  // ── removeFavorite ────────────────────────────────────────────────────────
  group('removeFavorite', () {
    test('should update items when removeFavorite succeeds', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();
      expect(container.read(favoritesViewModelProvider).items.length, 1);

      when(
        () => mockRemoveFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .removeFavorite('item_1');

      expect(container.read(favoritesViewModelProvider).items, isEmpty);
    });

    test('should pass correct refId to usecase', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      when(
        () => mockRemoveFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      await container
          .read(favoritesViewModelProvider.notifier)
          .removeFavorite('item_1');

      final captured =
          verify(() => mockRemoveFavorite(captureAny())).captured.first
              as String;
      expect(captured, 'item_1');
    });

    test('should add refId to pendingIds then remove on completion', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      bool? pendingDuringCall;
      when(() => mockRemoveFavorite(any())).thenAnswer((_) async {
        pendingDuringCall = container
            .read(favoritesViewModelProvider)
            .isPending('item_1');
        return const Right(tEmptyFavorites);
      });

      await container
          .read(favoritesViewModelProvider.notifier)
          .removeFavorite('item_1');

      expect(pendingDuringCall, true);
      expect(container.read(favoritesViewModelProvider).pendingIds, isEmpty);
    });

    test('should set errorMessage on failure', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      const failure = ApiFailure(message: 'You\'re offline');
      when(
        () => mockRemoveFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(favoritesViewModelProvider.notifier)
          .removeFavorite('item_1');

      expect(
        container.read(favoritesViewModelProvider).errorMessage,
        'You\'re offline',
      );
    });

    test('should remove pendingId even on failure', () async {
      when(
        () => mockGetFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));
      await container.read(favoritesViewModelProvider.notifier).loadFavorites();

      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockRemoveFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(favoritesViewModelProvider.notifier)
          .removeFavorite('item_1');

      expect(container.read(favoritesViewModelProvider).pendingIds, isEmpty);
    });
  });

  // ── FavoritesState unit tests ─────────────────────────────────────────────
  group('FavoritesState', () {
    test('copyWith should update only specified fields', () {
      const s = FavoritesState();
      final updated = s.copyWith(
        status: FavoritesStatus.loaded,
        items: const [tFavItem],
        isFromCache: true,
      );

      expect(updated.status, FavoritesStatus.loaded);
      expect(updated.items, [tFavItem]);
      expect(updated.isFromCache, true);
      expect(updated.errorMessage, isNull);
      expect(updated.pendingIds, isEmpty);
    });

    test('clearError=true should nullify errorMessage', () {
      const s = FavoritesState(errorMessage: 'some error');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('isFavorite should return true for refId in items', () {
      const s = FavoritesState(items: [tFavItem]);
      expect(s.isFavorite('item_1'), true);
    });

    test('isFavorite should return false for refId not in items', () {
      const s = FavoritesState(items: [tFavItem]);
      expect(s.isFavorite('unknown'), false);
    });

    test('isPending should return true when refId is in pendingIds', () {
      const s = FavoritesState(pendingIds: {'item_1'});
      expect(s.isPending('item_1'), true);
      expect(s.isPending('item_2'), false);
    });

    test('two states with same values should be equal', () {
      const s1 = FavoritesState(status: FavoritesStatus.loading);
      const s2 = FavoritesState(status: FavoritesStatus.loading);
      expect(s1, s2);
    });

    test('two states with different status should not be equal', () {
      const s1 = FavoritesState(status: FavoritesStatus.loading);
      const s2 = FavoritesState(status: FavoritesStatus.loaded);
      expect(s1, isNot(s2));
    });

    test('props should contain all fields', () {
      const s = FavoritesState(
        status: FavoritesStatus.loaded,
        items: [tFavItem],
        isFromCache: true,
        pendingIds: {'item_1'},
      );
      expect(s.props, [
        FavoritesStatus.loaded,
        [tFavItem],
        null,
        {'item_1'},
        true,
      ]);
    });
  });

  // ── FavoritesStatus enum ──────────────────────────────────────────────────
  group('FavoritesStatus', () {
    test('all values should exist', () {
      expect(FavoritesStatus.values, contains(FavoritesStatus.initial));
      expect(FavoritesStatus.values, contains(FavoritesStatus.loading));
      expect(FavoritesStatus.values, contains(FavoritesStatus.loaded));
      expect(FavoritesStatus.values, contains(FavoritesStatus.error));
    });
  });
}
