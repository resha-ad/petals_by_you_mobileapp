import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/presentation/screen/cart_screen.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

// ── Fake CartViewModel ───────────────────────────────────────────────────────
// Extends CartViewModel so NotifierProvider type contract is satisfied.
// All action methods are no-ops; build() returns a preset state.
class _FakeCartViewModel extends CartViewModel {
  final CartState _presetState;
  _FakeCartViewModel(this._presetState);

  @override
  CartState build() => _presetState;

  @override
  Future<void> loadCart() async {}

  @override
  Future<bool> addProduct({required String itemId, int quantity = 1}) async =>
      true;

  @override
  Future<void> removeItem(String refId) async {}

  @override
  Future<void> updateQuantity({
    required String refId,
    required int quantity,
  }) async {}

  @override
  Future<void> clearCart() async {}

  @override
  void clearError() {}
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

const tCartItem = CartItemEntity(
  type: 'product',
  refId: 'ref_1',
  quantity: 2,
  unitPrice: 1500,
  subtotal: 3000,
  refItem: tItem,
);

const tCart = CartEntity(userId: 'user_1', items: [tCartItem], total: 3000);
const tEmptyCart = CartEntity(userId: 'user_1', items: [], total: 0);

// ── Helper ────────────────────────────────────────────────────────────────────
Widget buildCartScreen(CartState state) {
  return ProviderScope(
    overrides: [
      cartViewModelProvider.overrideWith(() => _FakeCartViewModel(state)),
    ],
    child: const MaterialApp(home: CartScreen()),
  );
}

void main() {
  // ── Header UI ──────────────────────────────────────────────────────────────
  group('CartScreen - Header', () {
    testWidgets('should display My Cart title', (tester) async {
      await tester.pumpWidget(buildCartScreen(const CartState()));
      await tester.pump();

      expect(find.text('My Cart'), findsOneWidget);
    });

    testWidgets(
      'should show "Your cart is empty" in header when cart is empty',
      (tester) async {
        await tester.pumpWidget(
          buildCartScreen(
            const CartState(status: CartStatus.loaded, cart: tEmptyCart),
          ),
        );
        await tester.pump();

        // Header subtitle when empty
        expect(find.text('Your cart is empty'), findsWidgets);
      },
    );

    testWidgets('should show item count in header when cart has items', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      // tCartItem.quantity = 2, itemCount = 2
      expect(find.text('2 items'), findsOneWidget);
    });

    testWidgets('should show singular "item" for count of 1', (tester) async {
      const singleItemCart = CartEntity(
        userId: 'u1',
        items: [
          CartItemEntity(
            type: 'product',
            refId: 'ref_2',
            quantity: 1,
            unitPrice: 1000,
            subtotal: 1000,
            refItem: tItem,
          ),
        ],
        total: 1000,
      );
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: singleItemCart),
        ),
      );
      await tester.pump();

      expect(find.text('1 item'), findsOneWidget);
    });

    testWidgets('should show Clear all button when cart has items', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Clear all'), findsOneWidget);
    });

    testWidgets('should NOT show Clear all button when cart is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tEmptyCart),
        ),
      );
      await tester.pump();

      expect(find.text('Clear all'), findsNothing);
    });

    testWidgets('should NOT show Clear all button when offline', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Clear all'), findsNothing);
    });
  });

  // ── Loading State ──────────────────────────────────────────────────────────
  group('CartScreen - Loading State', () {
    testWidgets('should show CircularProgressIndicator when loading', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(const CartState(status: CartStatus.loading)),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should not show progress indicator when loaded', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tEmptyCart),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Empty State ────────────────────────────────────────────────────────────
  group('CartScreen - Empty State', () {
    testWidgets('should show empty state message when cart is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tEmptyCart),
        ),
      );
      await tester.pump();

      expect(
        find.text('Add flowers from the shop to get started'),
        findsOneWidget,
      );
    });

    testWidgets('should show shopping_bag icon in empty state', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tEmptyCart),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.shopping_bag_outlined), findsWidgets);
    });

    testWidgets('should NOT show checkout bar when cart is empty', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tEmptyCart),
        ),
      );
      await tester.pump();

      expect(find.text('Proceed to Checkout'), findsNothing);
    });
  });

  // ── Error State ────────────────────────────────────────────────────────────
  group('CartScreen - Error State', () {
    testWidgets('should show error message when status is error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.error,
            errorMessage: 'Network error',
          ),
        ),
      );
      await tester.pump();

      expect(find.text("Couldn't load cart"), findsOneWidget);
    });

    testWidgets('should show errorMessage text when present', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.error,
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
        buildCartScreen(const CartState(status: CartStatus.error)),
      );
      await tester.pump();

      expect(find.text('Check your connection and try again'), findsOneWidget);
    });

    testWidgets('should show Try Again button in error state', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(const CartState(status: CartStatus.error)),
      );
      await tester.pump();

      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  // ── Offline Banner ─────────────────────────────────────────────────────────
  group('CartScreen - Offline Banner', () {
    testWidgets('should show offline banner when isFromCache=true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text("You're offline — showing saved cart"), findsOneWidget);
    });

    testWidgets('should show Retry button in offline banner', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should NOT show offline banner when data is fresh', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: false,
          ),
        ),
      );
      await tester.pump();

      expect(find.text("You're offline — showing saved cart"), findsNothing);
    });

    testWidgets('should NOT show checkout bar when offline', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Proceed to Checkout'), findsNothing);
    });
  });

  // ── Cart Items ─────────────────────────────────────────────────────────────
  group('CartScreen - Cart Items', () {
    testWidgets('should display item name when refItem is set', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Red Roses'), findsOneWidget);
    });

    testWidgets('should display item unit price', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Rs. 1500 each'), findsOneWidget);
    });

    testWidgets('should display quantity for item', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('should display remove (×) button for each item', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('should display + and - quantity buttons', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
      expect(find.byIcon(Icons.remove_rounded), findsOneWidget);
    });

    testWidgets('should NOT show qty buttons when offline', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(find.byIcon(Icons.remove_rounded), findsNothing);
    });

    testWidgets('should show "Qty: 2" label for offline items', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(
            status: CartStatus.loaded,
            cart: tCart,
            isFromCache: true,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Qty: 2'), findsOneWidget);
    });
  });

  // ── Order Summary ──────────────────────────────────────────────────────────
  group('CartScreen - Order Summary', () {
    testWidgets('should display Order Summary section', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('should display Subtotal row', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      // itemCount=2 → 'Subtotal (2 items)'
      expect(find.text('Subtotal (2 items)'), findsOneWidget);
    });

    testWidgets('should display Delivery fee row', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Delivery'), findsOneWidget);
      expect(find.text('Rs. 150'), findsOneWidget);
    });

    testWidgets('should display correct grand total (subtotal + delivery)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      // cart.total=3000 + kDeliveryFee=150 = 3150
      expect(find.text('Rs. 3150'), findsWidgets);
    });
  });

  // ── Checkout Bar ───────────────────────────────────────────────────────────
  group('CartScreen - Checkout Bar', () {
    testWidgets('should show checkout bar when cart has items and is online', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.text('Proceed to Checkout'), findsOneWidget);
    });

    testWidgets('should show lock icon in checkout button', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
    });

    testWidgets('should show grand total in checkout bar', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      // 3000 + 150 = 3150 shown in checkout bar
      expect(find.text('Rs. 3150'), findsWidgets);
    });
  });

  // ── Clear Cart Dialog ──────────────────────────────────────────────────────
  group('CartScreen - Clear Cart Dialog', () {
    testWidgets('should show confirmation dialog when Clear all is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cart'), findsOneWidget);
      expect(find.text('Remove all items from your cart?'), findsOneWidget);
    });

    testWidgets('should show Cancel and Clear buttons in dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('should dismiss dialog when Cancel is tapped', (tester) async {
      await tester.pumpWidget(
        buildCartScreen(
          const CartState(status: CartStatus.loaded, cart: tCart),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Clear Cart'), findsNothing);
    });
  });

  // ── Scaffold ───────────────────────────────────────────────────────────────
  group('CartScreen - Scaffold', () {
    testWidgets('should have a Scaffold widget', (tester) async {
      await tester.pumpWidget(buildCartScreen(const CartState()));
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have a RefreshIndicator', (tester) async {
      await tester.pumpWidget(buildCartScreen(const CartState()));
      await tester.pump();

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });
}
