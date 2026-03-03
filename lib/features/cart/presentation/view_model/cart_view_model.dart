import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/cart/domain/usecases/cart_usecases.dart';
import 'package:sprint1_project/features/cart/presentation/state/cart_state.dart';

final cartViewModelProvider = NotifierProvider<CartViewModel, CartState>(
  CartViewModel.new,
);

class CartViewModel extends Notifier<CartState> {
  late final GetCartUsecase _getCart;
  late final AddProductUsecase _addProduct;
  late final RemoveCartItemUsecase _removeItem;
  late final UpdateCartQuantityUsecase _updateQuantity;
  late final ClearCartUsecase _clearCart;
  late final INetworkInfo _networkInfo;

  @override
  CartState build() {
    _getCart = ref.read(getCartUsecaseProvider);
    _addProduct = ref.read(addProductUsecaseProvider);
    _removeItem = ref.read(removeCartItemUsecaseProvider);
    _updateQuantity = ref.read(updateCartQuantityUsecaseProvider);
    _clearCart = ref.read(clearCartUsecaseProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const CartState();
  }

  // ── loadCart ──────────────────────────────────────────────────────────────
  Future<void> loadCart() async {
    state = state.copyWith(status: CartStatus.loading, clearError: true);
    final isOnline = await _networkInfo.isConnected;
    final result = await _getCart();
    result.fold(
      (failure) => state = state.copyWith(
        status: CartStatus.error,
        errorMessage: failure.message,
      ),
      (cart) => state = state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        isFromCache: !isOnline,
      ),
    );
  }

  // ── addProduct ────────────────────────────────────────────────────────────
  Future<bool> addProduct({required String itemId, int quantity = 1}) async {
    state = state.copyWith(pendingIds: {...state.pendingIds, itemId});
    final result = await _addProduct(
      AddProductParams(itemId: itemId, quantity: quantity),
    );
    bool success = false;
    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({itemId}),
        errorMessage: failure.message,
      ),
      (cart) {
        success = true;
        state = state.copyWith(
          status: CartStatus.loaded,
          cart: cart,
          pendingIds: state.pendingIds.difference({itemId}),
          isFromCache: false,
          clearError: true,
        );
      },
    );
    return success;
  }

  // ── removeItem ────────────────────────────────────────────────────────────
  Future<void> removeItem(String refId) async {
    state = state.copyWith(pendingIds: {...state.pendingIds, refId});
    final result = await _removeItem(refId);
    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({refId}),
        errorMessage: failure.message,
      ),
      (cart) => state = state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        pendingIds: state.pendingIds.difference({refId}),
        isFromCache: false,
        clearError: true,
      ),
    );
  }

  // ── updateQuantity ────────────────────────────────────────────────────────
  Future<void> updateQuantity({
    required String refId,
    required int quantity,
  }) async {
    state = state.copyWith(pendingIds: {...state.pendingIds, refId});
    final result = await _updateQuantity(
      UpdateQuantityParams(refId: refId, quantity: quantity),
    );
    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({refId}),
        errorMessage: failure.message,
      ),
      (cart) => state = state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        pendingIds: state.pendingIds.difference({refId}),
        isFromCache: false,
        clearError: true,
      ),
    );
  }

  // ── clearCart ─────────────────────────────────────────────────────────────
  Future<void> clearCart() async {
    state = state.copyWith(status: CartStatus.loading);
    final result = await _clearCart();
    result.fold(
      (failure) => state = state.copyWith(
        status: CartStatus.error,
        errorMessage: failure.message,
      ),
      (cart) => state = state.copyWith(
        status: CartStatus.loaded,
        cart: cart,
        isFromCache: false,
        clearError: true,
      ),
    );
  }

  void clearError() => state = state.copyWith(clearError: true);
}
