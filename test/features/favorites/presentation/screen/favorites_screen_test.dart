import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/presentation/screen/favorites_screen.dart';
import 'package:sprint1_project/features/favorites/presentation/state/favorites_state.dart';
import 'package:sprint1_project/features/favorites/presentation/view_model/favorites_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

// ── Fake FavoritesViewModel ───────────────────────────────────────────────────
// Extends the real class so NotifierProvider type contract is satisfied.
// build() returns a preset state; all action methods are no-ops.
class _FakeFavoritesViewModel extends FavoritesViewModel {
  final FavoritesState _presetState;
  _FakeFavoritesViewModel(this._presetState);

  @override
  FavoritesState build() => _presetState;

  @override
  Future<void> loadFavorites() async {}

  @override
  Future<void> toggleFavorite({
    required String refId,
    String type = 'product',
  }) async {}

  @override
  Future<void> addFavorite({
    required String refId,
    String type = 'product',
  }) async {}

  @override
  Future<void> removeFavorite(String refId) async {}
}

// ── Fixtures ──────────────────────────────────────────────────────────────────
const tItem = ItemEntity(
  id: 'item_1',
  name: 'Red Roses',
  slug: 'red-roses',
  description: 'Beautiful roses',
  price: 1500,
  images: [], // no network images in widget tests
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

const tFavItem2 = FavoriteEntity(
  type: 'product',
  refId: 'item_2',
  refItem: ItemEntity(
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
  ),
);

// ── Helper ─────────────────────────────────────────────────────────────────────
Widget buildFavoritesScreen(FavoritesState state) {
  return ProviderScope(
    overrides: [
      favoritesViewModelProvider.overrideWith(
        () => _FakeFavoritesViewModel(state),
      ),
    ],
    child: const MaterialApp(home: FavoritesScreen()),
  );
}

void main() {
  // ── Header UI ──────────────────────────────────────────────────────────────
  group('FavoritesScreen - Header', () {
    testWidgets('should display My Favourites title', (tester) async {
      await tester.pumpWidget(buildFavoritesScreen(const FavoritesState()));
      await tester.pump();

      expect(find.text('My Favourites'), findsOneWidget);
    });

    testWidgets('should show "Nothing saved yet" when no items', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.loaded),
        ),
      );
      await tester.pump();

      expect(find.text('Nothing saved yet'), findsOneWidget);
    });

    testWidgets('should show item count when items exist', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem, tFavItem2],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('2 items saved'), findsOneWidget);
    });

    testWidgets('should show singular "item" for count of 1', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('1 item saved'), findsOneWidget);
    });

    testWidgets('should show heart icon in header', (tester) async {
      await tester.pumpWidget(buildFavoritesScreen(const FavoritesState()));
      await tester.pump();

      expect(find.byIcon(Icons.favorite_rounded), findsOneWidget);
    });
  });

  // ── Loading State ──────────────────────────────────────────────────────────
  group('FavoritesScreen - Loading State', () {
    testWidgets(
      'should show CircularProgressIndicator when loading with no items',
      (tester) async {
        await tester.pumpWidget(
          buildFavoritesScreen(
            const FavoritesState(status: FavoritesStatus.loading),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'should NOT show loading indicator when loading but items already loaded',
      (tester) async {
        // Items already present (e.g. refresh) → no full-screen spinner
        await tester.pumpWidget(
          buildFavoritesScreen(
            const FavoritesState(
              status: FavoritesStatus.loading,
              items: [tFavItem],
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsNothing);
      },
    );
  });

  // ── Empty State ────────────────────────────────────────────────────────────
  group('FavoritesScreen - Empty State', () {
    testWidgets('should show empty state when no items and loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.loaded),
        ),
      );
      await tester.pump();

      expect(find.text('No favourites yet'), findsOneWidget);
    });

    testWidgets('should show hint text in empty state', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.loaded),
        ),
      );
      await tester.pump();

      expect(
        find.text('Tap the ♡ on any product to save it here'),
        findsOneWidget,
      );
    });

    testWidgets('should show heart_border icon in empty state', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.loaded),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });
  });

  // ── Error State ────────────────────────────────────────────────────────────
  group('FavoritesScreen - Error State', () {
    testWidgets('should show error title when status is error with no items', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.error,
            errorMessage: 'Network error',
          ),
        ),
      );
      await tester.pump();

      expect(find.text("Couldn't load favourites"), findsOneWidget);
    });

    testWidgets('should show errorMessage text when present', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.error,
            errorMessage: 'Network error',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('should show fallback text when errorMessage is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.error),
        ),
      );
      await tester.pump();

      expect(find.text('Check your connection and try again'), findsOneWidget);
    });

    testWidgets('should show Try Again button in error state', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.error),
        ),
      );
      await tester.pump();

      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets(
      'should show items grid (not error) when error but items already loaded',
      (tester) async {
        // If items are present, we show them even in error status
        await tester.pumpWidget(
          buildFavoritesScreen(
            const FavoritesState(
              status: FavoritesStatus.error,
              items: [tFavItem],
            ),
          ),
        );
        await tester.pump();

        expect(find.text("Couldn't load favourites"), findsNothing);
      },
    );
  });

  // ── Offline Banner ─────────────────────────────────────────────────────────
  group('FavoritesScreen - Offline Banner', () {
    testWidgets('should show offline banner when isFromCache=true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text("You're offline — showing saved favourites"),
        findsOneWidget,
      );
    });

    testWidgets('should show Retry button in offline banner', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should show wifi_off icon in offline banner', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.wifi_off_rounded), findsWidgets);
    });

    testWidgets('should NOT show offline banner when data is fresh', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
            isFromCache: false,
          ),
        ),
      );
      await tester.pump();

      expect(
        find.text("You're offline — showing saved favourites"),
        findsNothing,
      );
    });
  });

  // ── Items Grid ─────────────────────────────────────────────────────────────
  group('FavoritesScreen - Items Grid', () {
    testWidgets('should show item names when items are loaded', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem, tFavItem2],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Red Roses'), findsOneWidget);
      expect(find.text('Pink Tulips'), findsOneWidget);
    });

    testWidgets('should show item prices', (tester) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Rs. 1500'), findsOneWidget);
    });

    testWidgets('should show remove (heart) button for each item', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem],
          ),
        ),
      );
      await tester.pump();

      // The filled heart icon is the remove button on the card
      expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    });

    testWidgets('should show 2-column SliverGrid when items exist', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(
            status: FavoritesStatus.loaded,
            items: [tFavItem, tFavItem2],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(SliverGrid), findsOneWidget);
    });

    testWidgets('should NOT show grid when items list is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildFavoritesScreen(
          const FavoritesState(status: FavoritesStatus.loaded),
        ),
      );
      await tester.pump();

      expect(find.byType(SliverGrid), findsNothing);
    });
  });

  // ── Scaffold ───────────────────────────────────────────────────────────────
  group('FavoritesScreen - Scaffold', () {
    testWidgets('should have a Scaffold widget', (tester) async {
      await tester.pumpWidget(buildFavoritesScreen(const FavoritesState()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have a RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildFavoritesScreen(const FavoritesState()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
