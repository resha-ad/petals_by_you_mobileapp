import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/usecases/add_product_usecase.dart';
import 'package:sprint1_project/features/cart/domain/usecases/clear_cart_usecase.dart';
import 'package:sprint1_project/features/cart/domain/usecases/get_cart_usecase.dart';
import 'package:sprint1_project/features/cart/domain/usecases/remove_cart_item_usecase.dart';
import 'package:sprint1_project/features/cart/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';
import 'package:sprint1_project/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:sprint1_project/features/items/domain/entities/item_entity.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockGetCartUsecase extends Mock implements GetCartUsecase {}

class MockAddProductUsecase extends Mock implements AddProductUsecase {}

class MockRemoveCartItemUsecase extends Mock implements RemoveCartItemUsecase {}

class MockUpdateCartQuantityUsecase extends Mock
    implements UpdateCartQuantityUsecase {}

class MockClearCartUsecase extends Mock implements ClearCartUsecase {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetCartUsecase mockGetCart;
  late MockAddProductUsecase mockAddProduct;
  late MockRemoveCartItemUsecase mockRemoveItem;
  late MockUpdateCartQuantityUsecase mockUpdateQuantity;
  late MockClearCartUsecase mockClearCart;
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

  setUpAll(() {
    // ── Register ALL types used with any()/captureAny() ──────────────────────
    // AddProductParams — used in mockAddProduct(any())
    registerFallbackValue(const AddProductParams(itemId: 'fallback'));
    // UpdateQuantityParams — used in mockUpdateQuantity(any())
    registerFallbackValue(
      const UpdateQuantityParams(refId: 'fallback', quantity: 1),
    );
    // CartEntity — used if captureAny() is applied to it
    registerFallbackValue(tEmptyCart);
    // String — built-in, no registration needed for removeItem(any())
    // ItemEntity — not directly passed to mocks in this file but register to be safe
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
    mockGetCart = MockGetCartUsecase();
    mockAddProduct = MockAddProductUsecase();
    mockRemoveItem = MockRemoveCartItemUsecase();
    mockUpdateQuantity = MockUpdateCartQuantityUsecase();
    mockClearCart = MockClearCartUsecase();
    mockNetworkInfo = MockNetworkInfo();

    // Default: online
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    container = ProviderContainer(
      overrides: [
        getCartUsecaseProvider.overrideWithValue(mockGetCart),
        addProductUsecaseProvider.overrideWithValue(mockAddProduct),
        removeCartItemUsecaseProvider.overrideWithValue(mockRemoveItem),
        updateCartQuantityUsecaseProvider.overrideWithValue(mockUpdateQuantity),
        clearCartUsecaseProvider.overrideWithValue(mockClearCart),
        networkInfoProvider.overrideWithValue(mockNetworkInfo),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── initial state ─────────────────────────────────────────────────────────
  group('initial state', () {
    test('should be CartStatus.initial with null cart', () {
      final state = container.read(cartViewModelProvider);
      expect(state.status, CartStatus.initial);
      expect(state.cart, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isFromCache, false);
      expect(state.pendingIds, isEmpty);
    });

    test('isEmpty should be true on initial state', () {
      expect(container.read(cartViewModelProvider).isEmpty, true);
    });

    test('itemCount should be 0 on initial state', () {
      expect(container.read(cartViewModelProvider).itemCount, 0);
    });

    test('total should be 0.0 on initial state', () {
      expect(container.read(cartViewModelProvider).total, 0.0);
    });
  });

  // ── loadCart ──────────────────────────────────────────────────────────────
  group('loadCart', () {
    test('should emit loading → loaded on success', () async {
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      final statuses = <CartStatus>[];
      container.listen(
        cartViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(cartViewModelProvider.notifier).loadCart();

      expect(statuses, [CartStatus.loading, CartStatus.loaded]);
    });

    test('should set cart when loadCart succeeds', () async {
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      await container.read(cartViewModelProvider.notifier).loadCart();

      final state = container.read(cartViewModelProvider);
      expect(state.cart, tCart);
      expect(state.status, CartStatus.loaded);
    });

    test('should set isFromCache=false when online', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      await container.read(cartViewModelProvider.notifier).loadCart();

      expect(container.read(cartViewModelProvider).isFromCache, false);
    });

    test('should set isFromCache=true when offline', () async {
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      await container.read(cartViewModelProvider.notifier).loadCart();

      expect(container.read(cartViewModelProvider).isFromCache, true);
    });

    test('should emit loading → error when usecase fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch cart');
      when(() => mockGetCart()).thenAnswer((_) async => const Left(failure));

      final statuses = <CartStatus>[];
      container.listen(
        cartViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(cartViewModelProvider.notifier).loadCart();

      expect(statuses, [CartStatus.loading, CartStatus.error]);
      expect(
        container.read(cartViewModelProvider).errorMessage,
        'Failed to fetch cart',
      );
    });

    test('should clear previous errorMessage on new loadCart', () async {
      // First call fails
      const failure = ApiFailure(message: 'Server error');
      when(() => mockGetCart()).thenAnswer((_) async => const Left(failure));
      await container.read(cartViewModelProvider.notifier).loadCart();
      expect(
        container.read(cartViewModelProvider).errorMessage,
        'Server error',
      );

      // Second call succeeds
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));
      await container.read(cartViewModelProvider.notifier).loadCart();

      expect(container.read(cartViewModelProvider).errorMessage, isNull);
    });

    test('should call networkInfo.isConnected once per loadCart', () async {
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      await container.read(cartViewModelProvider.notifier).loadCart();

      verify(() => mockNetworkInfo.isConnected).called(1);
    });

    test('should call getCart usecase exactly once', () async {
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));

      await container.read(cartViewModelProvider.notifier).loadCart();

      verify(() => mockGetCart()).called(1);
      verifyNoMoreInteractions(mockGetCart);
    });
  });

  // ── addProduct ────────────────────────────────────────────────────────────
  group('addProduct', () {
    test('should return true and update cart on success', () async {
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Right(tCart));

      final success = await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_1', quantity: 2);

      expect(success, true);
      expect(container.read(cartViewModelProvider).cart, tCart);
      expect(container.read(cartViewModelProvider).status, CartStatus.loaded);
    });

    test('should return false and set errorMessage on failure', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to add items to cart.',
      );
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Left(failure));

      final success = await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_1');

      expect(success, false);
      expect(
        container.read(cartViewModelProvider).errorMessage,
        contains('offline'),
      );
    });

    test(
      'should add itemId to pendingIds then remove it on completion',
      () async {
        // Use a completer to pause the usecase mid-flight
        bool? pendingDuringCall;
        when(() => mockAddProduct(any())).thenAnswer((_) async {
          pendingDuringCall = container
              .read(cartViewModelProvider)
              .isPending('item_1');
          return const Right(tCart);
        });

        await container
            .read(cartViewModelProvider.notifier)
            .addProduct(itemId: 'item_1');

        // During the call, pendingIds contained 'item_1'
        expect(pendingDuringCall, true);
        // After completion, pendingIds should be empty
        expect(container.read(cartViewModelProvider).pendingIds, isEmpty);
      },
    );

    test('should pass correct itemId and quantity to usecase', () async {
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_abc', quantity: 3);

      final captured =
          verify(() => mockAddProduct(captureAny())).captured.first
              as AddProductParams;
      expect(captured.itemId, 'item_abc');
      expect(captured.quantity, 3);
    });

    test('should default quantity to 1 when not specified', () async {
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_1');

      final captured =
          verify(() => mockAddProduct(captureAny())).captured.first
              as AddProductParams;
      expect(captured.quantity, 1);
    });

    test('should set isFromCache=false on successful add', () async {
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_1');

      expect(container.read(cartViewModelProvider).isFromCache, false);
    });

    test('should remove pendingId even on failure', () async {
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockAddProduct(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(cartViewModelProvider.notifier)
          .addProduct(itemId: 'item_1');

      expect(container.read(cartViewModelProvider).pendingIds, isEmpty);
    });
  });

  // ── removeItem ────────────────────────────────────────────────────────────
  group('removeItem', () {
    test('should update cart when removeItem succeeds', () async {
      when(
        () => mockRemoveItem(any()),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await container.read(cartViewModelProvider.notifier).removeItem('ref_1');

      final state = container.read(cartViewModelProvider);
      expect(state.cart, tEmptyCart);
      expect(state.status, CartStatus.loaded);
    });

    test('should pass correct refId to usecase', () async {
      when(
        () => mockRemoveItem(any()),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await container
          .read(cartViewModelProvider.notifier)
          .removeItem('ref_abc');

      final captured =
          verify(() => mockRemoveItem(captureAny())).captured.first as String;
      expect(captured, 'ref_abc');
    });

    test('should add refId to pendingIds then remove on completion', () async {
      bool? pendingDuringCall;
      when(() => mockRemoveItem(any())).thenAnswer((_) async {
        pendingDuringCall = container
            .read(cartViewModelProvider)
            .isPending('ref_1');
        return const Right(tEmptyCart);
      });

      await container.read(cartViewModelProvider.notifier).removeItem('ref_1');

      expect(pendingDuringCall, true);
      expect(container.read(cartViewModelProvider).pendingIds, isEmpty);
    });

    test('should set errorMessage on failure', () async {
      const failure = ApiFailure(message: 'You\'re offline');
      when(
        () => mockRemoveItem(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(cartViewModelProvider.notifier).removeItem('ref_1');

      expect(
        container.read(cartViewModelProvider).errorMessage,
        'You\'re offline',
      );
    });

    test('should remove pendingId even on failure', () async {
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockRemoveItem(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container.read(cartViewModelProvider.notifier).removeItem('ref_1');

      expect(container.read(cartViewModelProvider).pendingIds, isEmpty);
    });
  });

  // ── updateQuantity ────────────────────────────────────────────────────────
  group('updateQuantity', () {
    test('should update cart when updateQuantity succeeds', () async {
      when(
        () => mockUpdateQuantity(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .updateQuantity(refId: 'ref_1', quantity: 3);

      final state = container.read(cartViewModelProvider);
      expect(state.cart, tCart);
      expect(state.status, CartStatus.loaded);
    });

    test('should pass correct refId and quantity to usecase', () async {
      when(
        () => mockUpdateQuantity(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .updateQuantity(refId: 'ref_xyz', quantity: 5);

      final captured =
          verify(() => mockUpdateQuantity(captureAny())).captured.first
              as UpdateQuantityParams;
      expect(captured.refId, 'ref_xyz');
      expect(captured.quantity, 5);
    });

    test('should add refId to pendingIds then remove on completion', () async {
      bool? pendingDuringCall;
      when(() => mockUpdateQuantity(any())).thenAnswer((_) async {
        pendingDuringCall = container
            .read(cartViewModelProvider)
            .isPending('ref_1');
        return const Right(tCart);
      });

      await container
          .read(cartViewModelProvider.notifier)
          .updateQuantity(refId: 'ref_1', quantity: 2);

      expect(pendingDuringCall, true);
      expect(container.read(cartViewModelProvider).pendingIds, isEmpty);
    });

    test('should set errorMessage on failure', () async {
      const failure = ApiFailure(message: 'Quantity must be at least 1');
      when(
        () => mockUpdateQuantity(any()),
      ).thenAnswer((_) async => const Left(failure));

      await container
          .read(cartViewModelProvider.notifier)
          .updateQuantity(refId: 'ref_1', quantity: 0);

      expect(
        container.read(cartViewModelProvider).errorMessage,
        'Quantity must be at least 1',
      );
    });

    test('should set isFromCache=false on success', () async {
      when(
        () => mockUpdateQuantity(any()),
      ).thenAnswer((_) async => const Right(tCart));

      await container
          .read(cartViewModelProvider.notifier)
          .updateQuantity(refId: 'ref_1', quantity: 2);

      expect(container.read(cartViewModelProvider).isFromCache, false);
    });
  });

  // ── clearCart ─────────────────────────────────────────────────────────────
  group('clearCart', () {
    test('should emit loading → loaded on success', () async {
      when(
        () => mockClearCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      final statuses = <CartStatus>[];
      container.listen(
        cartViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(cartViewModelProvider.notifier).clearCart();

      expect(statuses, [CartStatus.loading, CartStatus.loaded]);
    });

    test('should set cart to empty cart on success', () async {
      when(
        () => mockClearCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await container.read(cartViewModelProvider.notifier).clearCart();

      final state = container.read(cartViewModelProvider);
      expect(state.cart, tEmptyCart);
      expect(state.cart!.isEmpty, true);
      expect(state.isFromCache, false);
    });

    test('should emit loading → error on failure', () async {
      const failure = ApiFailure(message: 'You\'re offline');
      when(() => mockClearCart()).thenAnswer((_) async => const Left(failure));

      final statuses = <CartStatus>[];
      container.listen(
        cartViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      await container.read(cartViewModelProvider.notifier).clearCart();

      expect(statuses, [CartStatus.loading, CartStatus.error]);
      expect(
        container.read(cartViewModelProvider).errorMessage,
        'You\'re offline',
      );
    });

    test('should call clearCart usecase exactly once', () async {
      when(
        () => mockClearCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await container.read(cartViewModelProvider.notifier).clearCart();

      verify(() => mockClearCart()).called(1);
      verifyNoMoreInteractions(mockClearCart);
    });
  });

  // ── clearError ────────────────────────────────────────────────────────────
  group('clearError', () {
    test('should clear errorMessage', () async {
      const failure = ApiFailure(message: 'Some error');
      when(() => mockGetCart()).thenAnswer((_) async => const Left(failure));
      await container.read(cartViewModelProvider.notifier).loadCart();
      expect(container.read(cartViewModelProvider).errorMessage, 'Some error');

      container.read(cartViewModelProvider.notifier).clearError();

      expect(container.read(cartViewModelProvider).errorMessage, isNull);
    });

    test('should not change other state fields when clearing error', () async {
      when(() => mockGetCart()).thenAnswer((_) async => const Right(tCart));
      await container.read(cartViewModelProvider.notifier).loadCart();

      container.read(cartViewModelProvider.notifier).clearError();

      final state = container.read(cartViewModelProvider);
      expect(state.cart, tCart);
      expect(state.status, CartStatus.loaded);
    });
  });

  // ── isPending ─────────────────────────────────────────────────────────────
  group('isPending', () {
    test('should return false for refId not in pendingIds', () {
      expect(container.read(cartViewModelProvider).isPending('ref_999'), false);
    });
  });

  // ── CartState unit tests ──────────────────────────────────────────────────
  group('CartState', () {
    test('copyWith should update only specified fields', () {
      const s = CartState();
      final updated = s.copyWith(
        status: CartStatus.loaded,
        cart: tCart,
        isFromCache: true,
      );
      expect(updated.status, CartStatus.loaded);
      expect(updated.cart, tCart);
      expect(updated.isFromCache, true);
      expect(updated.errorMessage, isNull); // unchanged
      expect(updated.pendingIds, isEmpty); // unchanged
    });

    test('clearError=true should set errorMessage to null', () {
      const s = CartState(errorMessage: 'some error');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('isEmpty should be true when cart is null', () {
      expect(const CartState().isEmpty, true);
    });

    test('isEmpty should be true when cart has no items', () {
      const s = CartState(cart: tEmptyCart);
      expect(s.isEmpty, true);
    });

    test('isEmpty should be false when cart has items', () {
      const s = CartState(cart: tCart);
      expect(s.isEmpty, false);
    });

    test('itemCount should reflect cart item quantities', () {
      const s = CartState(cart: tCart);
      // tCartItem has quantity=2
      expect(s.itemCount, 2);
    });

    test('total should return cart total', () {
      const s = CartState(cart: tCart);
      expect(s.total, 3000);
    });

    test('total should be 0 when cart is null', () {
      expect(const CartState().total, 0.0);
    });

    test('isPending should return true when refId is in pendingIds', () {
      const s = CartState(pendingIds: {'ref_1', 'ref_2'});
      expect(s.isPending('ref_1'), true);
      expect(s.isPending('ref_3'), false);
    });

    test('two states with same values should be equal', () {
      const s1 = CartState(status: CartStatus.loading);
      const s2 = CartState(status: CartStatus.loading);
      expect(s1, s2);
    });

    test('two states with different status should not be equal', () {
      const s1 = CartState(status: CartStatus.loading);
      const s2 = CartState(status: CartStatus.loaded);
      expect(s1, isNot(s2));
    });

    test('props should contain all fields', () {
      const s = CartState(
        status: CartStatus.loaded,
        cart: tCart,
        isFromCache: true,
        pendingIds: {'ref_1'},
      );
      expect(s.props, [
        CartStatus.loaded,
        tCart,
        null, // errorMessage
        true, // isFromCache
        {'ref_1'}, // pendingIds
      ]);
    });
  });

  // ── CartStatus enum ───────────────────────────────────────────────────────
  group('CartStatus', () {
    test('all values should exist', () {
      expect(CartStatus.values, contains(CartStatus.initial));
      expect(CartStatus.values, contains(CartStatus.loading));
      expect(CartStatus.values, contains(CartStatus.loaded));
      expect(CartStatus.values, contains(CartStatus.error));
    });
  });
}
