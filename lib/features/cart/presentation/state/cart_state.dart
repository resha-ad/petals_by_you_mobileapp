import 'package:equatable/equatable.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';

enum CartStatus { initial, loading, loaded, error }

class CartState extends Equatable {
  final CartStatus status;
  final CartEntity? cart;
  final String? errorMessage;
  final bool isFromCache;
  final Set<String> pendingIds; // refIds currently being modified

  const CartState({
    this.status = CartStatus.initial,
    this.cart,
    this.errorMessage,
    this.isFromCache = false,
    this.pendingIds = const {},
  });

  bool get isEmpty => cart == null || cart!.isEmpty;
  int get itemCount => cart?.itemCount ?? 0;
  double get total => cart?.total ?? 0;

  bool isPending(String refId) => pendingIds.contains(refId);

  CartState copyWith({
    CartStatus? status,
    CartEntity? cart,
    String? errorMessage,
    bool clearError = false,
    bool? isFromCache,
    Set<String>? pendingIds,
  }) {
    return CartState(
      status: status ?? this.status,
      cart: cart ?? this.cart,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    cart,
    errorMessage,
    isFromCache,
    pendingIds,
  ];
}
