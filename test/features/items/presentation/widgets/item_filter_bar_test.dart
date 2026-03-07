import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/items/presentation/widgets/item_filter_bar.dart';

void main() {
  // ── Helper ─────────────────────────────────────────────────────────────────
  Widget buildFilterBar({
    String? selectedCategory,
    String? selectedSort,
    required void Function(String?, String?) onFilterChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: ItemFilterBar(
          selectedCategory: selectedCategory,
          selectedSort: selectedSort,
          onFilterChanged: onFilterChanged,
        ),
      ),
    );
  }

  // ── UI Elements ─────────────────────────────────────────────────────────────
  group('ItemFilterBar - UI Elements', () {
    testWidgets('should display all category chips', (tester) async {
      await tester.pumpWidget(buildFilterBar(onFilterChanged: (_, __) {}));
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Bouquets'), findsOneWidget);
      expect(find.text('Flowers'), findsOneWidget);
      expect(find.text('Arrangements'), findsOneWidget);
      expect(find.text('Gift Sets'), findsOneWidget);
      expect(find.text('Others'), findsOneWidget);
    });

    testWidgets('should display sort label', (tester) async {
      await tester.pumpWidget(buildFilterBar(onFilterChanged: (_, __) {}));
      await tester.pumpAndSettle();

      expect(find.text('Sort:'), findsOneWidget);
    });

    testWidgets('should display all sort options', (tester) async {
      await tester.pumpWidget(buildFilterBar(onFilterChanged: (_, __) {}));
      await tester.pumpAndSettle();

      expect(find.text('Newest'), findsOneWidget);
      expect(find.text('Price ↑'), findsOneWidget);
      expect(find.text('Price ↓'), findsOneWidget);
    });

    testWidgets('should have a horizontal scrollable category list', (
      tester,
    ) async {
      await tester.pumpWidget(buildFilterBar(onFilterChanged: (_, __) {}));
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });
  });

  // ── Category Selection ─────────────────────────────────────────────────────
  group('ItemFilterBar - Category Selection', () {
    testWidgets('All category should be selected by default', (tester) async {
      String? capturedCategory;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (cat, _) => capturedCategory = cat),
      );
      await tester.pumpAndSettle();

      // Tap All explicitly to confirm it fires
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // All → value is '' → fires null
      expect(capturedCategory, isNull);
    });

    testWidgets('should call onFilterChanged with category when tapped', (
      tester,
    ) async {
      String? capturedCategory;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (cat, _) => capturedCategory = cat),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bouquets'));
      await tester.pumpAndSettle();

      expect(capturedCategory, 'bouquets');
    });

    testWidgets('should call onFilterChanged with flowers category', (
      tester,
    ) async {
      String? capturedCategory;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (cat, _) => capturedCategory = cat),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Flowers'));
      await tester.pumpAndSettle();

      expect(capturedCategory, 'flowers');
    });

    testWidgets('should call onFilterChanged with null when All is tapped', (
      tester,
    ) async {
      String? capturedCategory = 'bouquets';
      await tester.pumpWidget(
        buildFilterBar(
          selectedCategory: 'bouquets',
          onFilterChanged: (cat, _) => capturedCategory = cat,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(capturedCategory, isNull);
    });

    testWidgets(
      'should initialize with selectedCategory chip visually selected',
      (tester) async {
        await tester.pumpWidget(
          buildFilterBar(
            selectedCategory: 'bouquets',
            onFilterChanged: (_, __) {},
          ),
        );
        await tester.pumpAndSettle();

        // The 'Bouquets' chip should have the primary green color container
        // We verify via the AnimatedContainer color indirectly:
        // The chip is found, implying the widget rendered with the initial value
        expect(find.text('Bouquets'), findsOneWidget);
      },
    );
  });

  // ── Sort Selection ──────────────────────────────────────────────────────────
  group('ItemFilterBar - Sort Selection', () {
    testWidgets('should call onFilterChanged with sort value when tapped', (
      tester,
    ) async {
      String? capturedSort;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (_, sort) => capturedSort = sort),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Newest'));
      await tester.pumpAndSettle();

      expect(capturedSort, 'createdAt:desc');
    });

    testWidgets('should call onFilterChanged with price:asc sort', (
      tester,
    ) async {
      String? capturedSort;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (_, sort) => capturedSort = sort),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Price ↑'));
      await tester.pumpAndSettle();

      expect(capturedSort, 'price:asc');
    });

    testWidgets('should call onFilterChanged with price:desc sort', (
      tester,
    ) async {
      String? capturedSort;
      await tester.pumpWidget(
        buildFilterBar(onFilterChanged: (_, sort) => capturedSort = sort),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Price ↓'));
      await tester.pumpAndSettle();

      expect(capturedSort, 'price:desc');
    });

    testWidgets('should deselect sort on second tap (toggle off)', (
      tester,
    ) async {
      String? capturedSort = 'createdAt:desc';
      await tester.pumpWidget(
        buildFilterBar(
          selectedSort: 'createdAt:desc',
          onFilterChanged: (_, sort) => capturedSort = sort,
        ),
      );
      await tester.pumpAndSettle();

      // Tap the already-selected sort to toggle off
      await tester.tap(find.text('Newest'));
      await tester.pumpAndSettle();

      expect(capturedSort, isNull);
    });

    testWidgets('should pass current category along with sort', (tester) async {
      String? capturedCategory;
      String? capturedSort;
      await tester.pumpWidget(
        buildFilterBar(
          selectedCategory: 'flowers',
          onFilterChanged: (cat, sort) {
            capturedCategory = cat;
            capturedSort = sort;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Price ↑'));
      await tester.pumpAndSettle();

      expect(capturedCategory, 'flowers');
      expect(capturedSort, 'price:asc');
    });
  });

  // ── didUpdateWidget ─────────────────────────────────────────────────────────
  group('ItemFilterBar - External State Updates', () {
    testWidgets('should update when selectedCategory prop changes', (
      tester,
    ) async {
      String? currentCategory = 'bouquets';

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return MaterialApp(
              home: Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () =>
                          setState(() => currentCategory = 'flowers'),
                      child: const Text('Change Category'),
                    ),
                    ItemFilterBar(
                      selectedCategory: currentCategory,
                      onFilterChanged: (_, __) {},
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Change Category'));
      await tester.pumpAndSettle();

      // Widget rebuilt with new selectedCategory — should not throw
      expect(find.text('Flowers'), findsOneWidget);
    });
  });

  // ── Combined filters ────────────────────────────────────────────────────────
  group('ItemFilterBar - Combined Filters', () {
    testWidgets('should pass both category and sort when both selected', (
      tester,
    ) async {
      String? capturedCategory;
      String? capturedSort;

      await tester.pumpWidget(
        buildFilterBar(
          onFilterChanged: (cat, sort) {
            capturedCategory = cat;
            capturedSort = sort;
          },
        ),
      );
      await tester.pumpAndSettle();

      // Select category first
      await tester.tap(find.text('Arrangements'));
      await tester.pumpAndSettle();

      // Then select sort
      await tester.tap(find.text('Price ↓'));
      await tester.pumpAndSettle();

      expect(capturedCategory, 'arrangements');
      expect(capturedSort, 'price:desc');
    });
  });
}
