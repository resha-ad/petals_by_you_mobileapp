import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/notifications/push_notification_service.dart';
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

  /// Tracks the last-known status per order ID so we can detect transitions.
  final Map<String, String> _knownStatuses = {};

  @override
  OrdersState build() {
    _getMyOrders = ref.read(getMyOrdersUsecaseProvider);
    _getOrderById = ref.read(getOrderByIdUsecaseProvider);
    _placeOrder = ref.read(placeOrderUsecaseProvider);
    _cancelOrder = ref.read(cancelOrderUsecaseProvider);
    _networkInfo = ref.read(networkInfoProvider);
    return const OrdersState();
  }

  // ── Auto-fix: delivered orders are always shown as "paid" ─────────────────
  List<OrderEntity> _applyPaymentFix(List<OrderEntity> orders) {
    return orders.map((order) {
      if (order.status == OrderStatus.delivered &&
          order.paymentStatus != 'paid') {
        return order.copyWithPaymentStatus('paid');
      }
      return order;
    }).toList();
  }

  OrderEntity _applyPaymentFixSingle(OrderEntity order) {
    if (order.status == OrderStatus.delivered &&
        order.paymentStatus != 'paid') {
      return order.copyWithPaymentStatus('paid');
    }
    return order;
  }

  // ── Detect status transitions and fire push notifications ─────────────────
  void _checkStatusTransitions(List<OrderEntity> freshOrders) {
    for (final order in freshOrders) {
      final shortId =
          '#${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}';
      final previous = _knownStatuses[order.id];
      final current = order.status.name;

      if (previous != null && previous != current) {
        String title = '';
        String body = '';

        switch (order.status) {
          case OrderStatus.confirmed:
            title = '✅ Order Confirmed!';
            body =
                'Your order $shortId has been confirmed and is being prepared.';
            break;
          case OrderStatus.preparing:
            title = '🌸 Your Bouquet is Being Made';
            body =
                'Our florists are handcrafting your order $shortId with love!';
            break;
          case OrderStatus.outForDelivery:
            title = '🚚 Out for Delivery!';
            body =
                'Your order $shortId is on its way. Please be available to receive it.';
            break;
          case OrderStatus.delivered:
            title = '🎉 Order Delivered!';
            body =
                'Your order $shortId has been delivered. We hope you love it! 💐';
            break;
          case OrderStatus.cancelled:
            title = '❌ Order Cancelled';
            body = 'Your order $shortId has been cancelled.';
            break;
          default:
            break;
        }

        if (title.isNotEmpty) {
          PushNotificationService.instance.showNotification(
            id: order.id.hashCode.abs() % 100000,
            title: title,
            body: body,
          );
        }
      }

      _knownStatuses[order.id] = current;
    }
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
      (orders) {
        final fixed = _applyPaymentFix(orders);
        _checkStatusTransitions(fixed);
        state = state.copyWith(
          status: OrdersStatus.loaded,
          orders: fixed,
          isFromCache: !isOnline,
        );
      },
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
      (order) {
        final fixed = _applyPaymentFixSingle(order);
        state = state.copyWith(
          status: OrdersStatus.loaded,
          selectedOrder: fixed,
        );
      },
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
        // Seed the known status so we don't double-notify on next load
        _knownStatuses[order.id] = order.status.name;

        state = state.copyWith(
          status: OrdersStatus.loaded,
          orders: [order, ...state.orders],
          selectedOrder: order,
          isFromCache: false,
          clearError: true,
        );

        // 🌸 "Order placed" notification
        final shortId =
            '#${order.id.substring(order.id.length > 6 ? order.id.length - 6 : 0)}';
        PushNotificationService.instance.showNotification(
          id: order.id.hashCode.abs() % 100000,
          title: '🌸 Order Placed Successfully!',
          body:
              'Your order $shortId has been received. We\'ll start preparing it soon!',
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
