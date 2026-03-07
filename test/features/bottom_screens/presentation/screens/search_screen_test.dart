import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/search_screen.dart';
import 'package:sprint1_project/features/items/presentation/state/item_state.dart';
import 'package:sprint1_project/features/items/presentation/view_model/item_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

// ── Fake ItemViewModel ───────────────────────────────────────────────────────
// Extends the real class so that the provider's type contract is satisfied.
// We override build() to return a preset state and all action methods to no-ops.
class _FakeItemViewModel extends ItemViewModel {
  final ItemState _presetState;
  _FakeItemViewModel(this._presetState);

  @override
  ItemState build() => _presetState;

  @override
  Future<void> loadItems({
    String? category,
    String? search,
    String? sort,
  }) async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<void> applyFilter({String? category, String? sort}) async {}

  @override
  Future<void> search(String query) async {}

  @override
  void clearSearch() {}

  @override
  Future<void> getItemById(String id) async {}

  @override
  void clearError() {}

  @override
  void resetSearch() {}
}

// ── Fixtures ──────────────────────────────────────────────────────────────────
const tItem1 = ItemEntity(
  id: 'item_1',
  name: 'Red Roses',
  slug: 'red-roses',
  description: 'Beautiful roses',
  price: 1500,
  images: [],
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

// ── Helper ────────────────────────────────────────────────────────────────────
Widget buildSearchScreen(ItemState state) {
  return ProviderScope(
    overrides: [
      searchItemsProvider.overrideWith(() => _FakeItemViewModel(state)),
    ],
    child: const MaterialApp(home: SearchScreen()),
  );
}

void main() {
  // ── UI Elements ─────────────────────────────────────────────────────────────
  group('SearchScreen - Header UI', () {
    testWidgets('should display Shop title', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Shop'), findsOneWidget);
    });

    testWidgets('should display subtitle text', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Browse our full collection'), findsOneWidget);
    });

    testWidgets('should display search TextField', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should display search hint text', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Search flowers, bouquets...'), findsOneWidget);
    });

    testWidgets('should display search icon prefix', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });

  // ── Category Filter Bar ────────────────────────────────────────────────────
  group('SearchScreen - Category Bar', () {
    testWidgets('should display All category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('All'), findsOneWidget);
    });

    testWidgets('should display Bouquets category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Bouquets'), findsOneWidget);
    });

    testWidgets('should display Flowers category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Flowers'), findsOneWidget);
    });

    testWidgets('should display Arrangements category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Arrangements'), findsOneWidget);
    });

    testWidgets('should display Gift Sets category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Gift Sets'), findsOneWidget);
    });

    testWidgets('should display Others category chip', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Others'), findsOneWidget);
    });
  });

  // ── Sort Bar ───────────────────────────────────────────────────────────────
  group('SearchScreen - Sort Bar', () {
    testWidgets('should display Newest sort option', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Newest'), findsOneWidget);
    });

    testWidgets('should display Price: Low sort option', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Price: Low'), findsOneWidget);
    });

    testWidgets('should display Price: High sort option', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.text('Price: High'), findsOneWidget);
    });
  });

  // ── Loading State ──────────────────────────────────────────────────────────
  group('SearchScreen - Loading State', () {
    testWidgets('should show CircularProgressIndicator when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(status: ItemStatus.loading, items: []),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Empty State ────────────────────────────────────────────────────────────
  group('SearchScreen - Empty State', () {
    testWidgets(
      'should show no results message when items is empty and loaded',
      (tester) async {
        await tester.pumpWidget(
          buildSearchScreen(
            const ItemState(status: ItemStatus.loaded, items: []),
          ),
        );
        await tester.pump();

        expect(find.text('No results found'), findsOneWidget);
      },
    );

    testWidgets('should show search_off icon for empty results', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(status: ItemStatus.loaded, items: []),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });

    testWidgets('should show try different keywords hint', (tester) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(status: ItemStatus.loaded, items: []),
        ),
      );
      await tester.pump();

      expect(find.text('Try different keywords or filters'), findsOneWidget);
    });
  });

  // ── Error State ────────────────────────────────────────────────────────────
  group('SearchScreen - Error State', () {
    testWidgets('should show error message when status is error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(
            status: ItemStatus.error,
            items: [],
            errorMessage: 'Network error',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Could not load products'), findsOneWidget);
    });

    testWidgets('should show errorMessage text when present', (tester) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(
            status: ItemStatus.error,
            items: [],
            errorMessage: 'Network error',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Network error'), findsOneWidget);
    });

    testWidgets('should show fallback message when errorMessage is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSearchScreen(const ItemState(status: ItemStatus.error, items: [])),
      );
      await tester.pump();

      expect(find.text('Check your connection'), findsOneWidget);
    });

    testWidgets('should show wifi_off icon in error state', (tester) async {
      await tester.pumpWidget(
        buildSearchScreen(const ItemState(status: ItemStatus.error, items: [])),
      );
      await tester.pump();

      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });
  });

  // ── Offline Banner ─────────────────────────────────────────────────────────
  group('SearchScreen - Offline Indicator', () {
    testWidgets('should show Offline label when data is from cache', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSearchScreen(
          const ItemState(
            status: ItemStatus.loaded,
            items: [tItem1],
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Offline'), findsOneWidget);
    });
  });

  // ── Search Input ───────────────────────────────────────────────────────────
  group('SearchScreen - Search Input', () {
    testWidgets('should accept text input in search field', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'roses');
      await tester.pump();

      expect(find.text('roses'), findsOneWidget);
    });

    testWidgets('should show clear button when text is entered', (
      tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'roses');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should not show clear button when search is empty', (
      tester,
    ) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });
  });

  // ── Scaffold Structure ─────────────────────────────────────────────────────
  group('SearchScreen - Scaffold', () {
    testWidgets('should have Scaffold widget', (tester) async {
      await tester.pumpWidget(buildSearchScreen(const ItemState()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have back button when pushed on stack', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchItemsProvider.overrideWith(
              () => _FakeItemViewModel(const ItemState()),
            ),
          ],
          child: MaterialApp(
            home: Builder(
              builder: (ctx) => ElevatedButton(
                onPressed: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });
}
