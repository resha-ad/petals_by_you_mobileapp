import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/usecases/orders_usecases.dart';

// ── State ─────────────────────────────────────────────────────────────────────
enum OrdersStatus { initial, loading, loaded, error }

class OrdersState extends Equatable {
  final OrdersStatus status;
  final List<OrderEntity> orders;
  final OrderEntity? selectedOrder;
  final String? errorMessage;
  final bool isFromCache;
  final Set<String> pendingIds;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.selectedOrder,
    this.errorMessage,
    this.isFromCache = false,
    this.pendingIds = const {},
  });

  bool isPending(String id) => pendingIds.contains(id);

  OrdersState copyWith({
    OrdersStatus? status,
    List<OrderEntity>? orders,
    OrderEntity? selectedOrder,
    bool clearSelected = false,
    String? errorMessage,
    bool clearError = false,
    bool? isFromCache,
    Set<String>? pendingIds,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      selectedOrder: clearSelected
          ? null
          : (selectedOrder ?? this.selectedOrder),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFromCache: isFromCache ?? this.isFromCache,
      pendingIds: pendingIds ?? this.pendingIds,
    );
  }

  @override
  List<Object?> get props => [
    status,
    orders,
    selectedOrder,
    errorMessage,
    isFromCache,
    pendingIds,
  ];
}

// ── ViewModel ─────────────────────────────────────────────────────────────────
final ordersViewModelProvider = NotifierProvider<OrdersViewModel, OrdersState>(
  OrdersViewModel.new,
);

class OrdersViewModel extends Notifier<OrdersState> {
  late final GetMyOrdersUsecase _getMyOrders;
  late final GetOrderByIdUsecase _getOrderById;
  late final PlaceOrderUsecase _placeOrder;
  late final CancelOrderUsecase _cancelOrder;
  late final INetworkInfo _networkInfo;

  @override
  OrdersState build() {
    _getMyOrders = ref.read(getMyOrdersUsecaseProvider);
    _getOrderById = ref.read(getOrderByIdUsecaseProvider);
    _placeOrder = ref.read(placeOrderUsecaseProvider);
    _cancelOrder = ref.read(cancelOrderUsecaseProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const OrdersState();
  }

  // ── loadOrders ────────────────────────────────────────────────────────────
  Future<void> loadOrders() async {
    state = state.copyWith(status: OrdersStatus.loading, clearError: true);
    final isOnline = await _networkInfo.isConnected;
    final result = await _getMyOrders();
    result.fold(
      (failure) => state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: failure.message,
      ),
      (orders) => state = state.copyWith(
        status: OrdersStatus.loaded,
        orders: orders,
        isFromCache: !isOnline,
      ),
    );
  }

  // ── loadOrderById ─────────────────────────────────────────────────────────
  Future<void> loadOrderById(String id) async {
    state = state.copyWith(
      status: OrdersStatus.loading,
      clearSelected: true,
      clearError: true,
    );
    final result = await _getOrderById(id);
    result.fold(
      (failure) => state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: failure.message,
      ),
      (order) => state = state.copyWith(
        status: OrdersStatus.loaded,
        selectedOrder: order,
      ),
    );
  }

  // ── placeOrder ────────────────────────────────────────────────────────────
  Future<OrderEntity?> placeOrder({
    required String paymentMethod,
    required Map<String, dynamic> deliveryDetails,
    String? notes,
  }) async {
    state = state.copyWith(status: OrdersStatus.loading, clearError: true);
    final result = await _placeOrder(
      PlaceOrderParams(
        paymentMethod: paymentMethod,
        deliveryDetails: deliveryDetails,
        notes: notes,
      ),
    );
    OrderEntity? placed;
    result.fold(
      (failure) => state = state.copyWith(
        status: OrdersStatus.error,
        errorMessage: failure.message,
      ),
      (order) {
        placed = order;
        state = state.copyWith(
          status: OrdersStatus.loaded,
          orders: [order, ...state.orders],
          selectedOrder: order,
          isFromCache: false,
          clearError: true,
        );
      },
    );
    return placed;
  }

  // ── cancelOrder ───────────────────────────────────────────────────────────
  Future<void> cancelOrder(String id, {String? reason}) async {
    state = state.copyWith(pendingIds: {...state.pendingIds, id});
    final result = await _cancelOrder(
      CancelOrderParams(id: id, reason: reason),
    );
    result.fold(
      (failure) => state = state.copyWith(
        pendingIds: state.pendingIds.difference({id}),
        errorMessage: failure.message,
      ),
      (order) {
        final updated = state.orders
            .map((o) => o.id == id ? order : o)
            .toList();
        state = state.copyWith(
          status: OrdersStatus.loaded,
          orders: updated,
          selectedOrder: state.selectedOrder?.id == id
              ? order
              : state.selectedOrder,
          pendingIds: state.pendingIds.difference({id}),
          clearError: true,
        );
      },
    );
  }
}
