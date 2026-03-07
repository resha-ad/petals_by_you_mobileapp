import 'package:dartz/dartz.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/core/services/stock_override_service.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/usecases/cancel_order_usecase.dart';
import 'package:sprint1_project/features/orders/domain/usecases/get_my_orders_usecase.dart';
import 'package:sprint1_project/features/orders/domain/usecases/get_order_by_id_usecase.dart';
import 'package:sprint1_project/features/orders/domain/usecases/place_order_usecase.dart';
import 'package:sprint1_project/features/orders/presentation/view_model/orders_view_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockGetMyOrdersUsecase extends Mock implements GetMyOrdersUsecase {}

class MockGetOrderByIdUsecase extends Mock implements GetOrderByIdUsecase {}

class MockPlaceOrderUsecase extends Mock implements PlaceOrderUsecase {}

class MockCancelOrderUsecase extends Mock implements CancelOrderUsecase {}

// networkInfoProvider is typed as Provider<NetworkInfo> (the concrete class),
// so the mock must implement the concrete NetworkInfo — not INetworkInfo.
class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockStockOverrideService extends Mock implements StockOverrideService {}

void main() {
  // PushNotificationService.instance is `static final` and cannot be reassigned.
  // Instead we intercept the underlying flutter_local_notifications platform
  // channel so that showNotification() becomes a no-op in tests without any
  // source-code changes.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Silence all flutter_local_notifications method channel calls.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('dexterous.com/flutter/local_notifications'),
          (_) async => null,
        );

    registerFallbackValue(const CancelOrderParams(id: 'fallback_id'));
    registerFallbackValue(
      const PlaceOrderParams(
        paymentMethod: 'cash_on_delivery',
        deliveryDetails: <String, dynamic>{},
      ),
    );
  });

  late MockGetMyOrdersUsecase mockGetMyOrders;
  late MockGetOrderByIdUsecase mockGetOrderById;
  late MockPlaceOrderUsecase mockPlaceOrder;
  late MockCancelOrderUsecase mockCancelOrder;
  late MockNetworkInfo mockNetworkInfo;
  late MockStockOverrideService mockStockOverride;
  late ProviderContainer container;

  // ── Fixtures ───────────────────────────────────────────────────────────────
  final tOrderPending = OrderEntity(
    id: 'order_001',
    items: const [
      OrderItemEntity(
        type: 'product',
        refId: 'ref_001',
        name: 'Red Roses',
        unitPrice: 1500,
        quantity: 2,
        subtotal: 3000,
      ),
    ],
    totalAmount: 3000,
    status: OrderStatus.pending,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  final tOrderDelivered = OrderEntity(
    id: 'order_002',
    items: const [],
    totalAmount: 1500,
    status: OrderStatus.delivered,
    paymentStatus: 'paid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime(2024, 1, 10),
    updatedAt: DateTime(2024, 1, 12),
  );

  // Delivered order with wrong paymentStatus — VM should auto-fix to 'paid'
  final tDeliveredUnpaid = OrderEntity(
    id: 'order_003',
    items: const [],
    totalAmount: 1000,
    status: OrderStatus.delivered,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime(2024, 1, 5),
    updatedAt: DateTime(2024, 1, 8),
  );

  final tCancelledOrder = OrderEntity(
    id: 'order_001',
    items: const [],
    totalAmount: 3000,
    status: OrderStatus.cancelled,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    cancelReason: 'Changed my mind',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 16),
  );

  setUp(() {
    mockGetMyOrders = MockGetMyOrdersUsecase();
    mockGetOrderById = MockGetOrderByIdUsecase();
    mockPlaceOrder = MockPlaceOrderUsecase();
    mockCancelOrder = MockCancelOrderUsecase();
    mockNetworkInfo = MockNetworkInfo();
    mockStockOverride = MockStockOverrideService();

    // Default: device is online
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    // Default: stock deductions are silent no-ops
    when(
      () => mockStockOverride.recordDeduction(any(), any()),
    ).thenAnswer((_) async {});

    container = ProviderContainer(
      overrides: [
        getMyOrdersUsecaseProvider.overrideWithValue(mockGetMyOrders),
        getOrderByIdUsecaseProvider.overrideWithValue(mockGetOrderById),
        placeOrderUsecaseProvider.overrideWithValue(mockPlaceOrder),
        cancelOrderUsecaseProvider.overrideWithValue(mockCancelOrder),
        networkInfoProvider.overrideWithValue(mockNetworkInfo),
        stockOverrideServiceProvider.overrideWithValue(mockStockOverride),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── initial state ──────────────────────────────────────────────────────────
  group('initial state', () {
    test('should have correct default values', () {
      // Act
      final state = container.read(ordersViewModelProvider);

      // Assert
      expect(state.status, OrdersStatus.initial);
      expect(state.orders, isEmpty);
      expect(state.selectedOrder, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isFromCache, isFalse);
      expect(state.pendingIds, isEmpty);
    });
  });

  // ── loadOrders ─────────────────────────────────────────────────────────────
  group('loadOrders', () {
    test(
      'should emit loading then loaded with correct orders on success',
      () async {
        // Arrange
        when(
          () => mockGetMyOrders(),
        ).thenAnswer((_) async => Right([tOrderPending, tOrderDelivered]));

        final statuses = <OrdersStatus>[];
        container.listen(
          ordersViewModelProvider.select((s) => s.status),
          (_, next) => statuses.add(next),
          fireImmediately: false,
        );

        // Act
        await container.read(ordersViewModelProvider.notifier).loadOrders();

        // Assert
        expect(statuses, [OrdersStatus.loading, OrdersStatus.loaded]);
        expect(container.read(ordersViewModelProvider).orders.length, 2);
        expect(container.read(ordersViewModelProvider).errorMessage, isNull);
      },
    );

    test('should set error status and errorMessage on failure', () async {
      // Arrange
      const failure = ApiFailure(message: 'Failed to fetch orders');
      when(
        () => mockGetMyOrders(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      await container.read(ordersViewModelProvider.notifier).loadOrders();

      // Assert
      final state = container.read(ordersViewModelProvider);
      expect(state.status, OrdersStatus.error);
      expect(state.errorMessage, 'Failed to fetch orders');
    });

    test('should set isFromCache=true when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockGetMyOrders(),
      ).thenAnswer((_) async => Right([tOrderPending]));

      // Act
      await container.read(ordersViewModelProvider.notifier).loadOrders();

      // Assert
      expect(container.read(ordersViewModelProvider).isFromCache, isTrue);
    });

    test('should set isFromCache=false when device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockGetMyOrders(),
      ).thenAnswer((_) async => Right([tOrderPending]));

      // Act
      await container.read(ordersViewModelProvider.notifier).loadOrders();

      // Assert
      expect(container.read(ordersViewModelProvider).isFromCache, isFalse);
    });

    test(
      'should auto-fix paymentStatus from unpaid to paid for delivered orders',
      () async {
        // Arrange — tDeliveredUnpaid: status=delivered, paymentStatus='unpaid'
        when(
          () => mockGetMyOrders(),
        ).thenAnswer((_) async => Right([tDeliveredUnpaid]));

        // Act
        await container.read(ordersViewModelProvider.notifier).loadOrders();

        // Assert — VM's _applyPaymentFix corrects it to 'paid'
        expect(
          container.read(ordersViewModelProvider).orders.first.paymentStatus,
          'paid',
        );
      },
    );

    test('should NOT change paymentStatus for non-delivered orders', () async {
      // Arrange
      when(
        () => mockGetMyOrders(),
      ).thenAnswer((_) async => Right([tOrderPending]));

      // Act
      await container.read(ordersViewModelProvider.notifier).loadOrders();

      // Assert — pending order with 'unpaid' remains unchanged
      expect(
        container.read(ordersViewModelProvider).orders.first.paymentStatus,
        'unpaid',
      );
    });

    test(
      'should produce status=loaded and empty list when repository returns none',
      () async {
        // Arrange
        when(() => mockGetMyOrders()).thenAnswer((_) async => const Right([]));

        // Act
        await container.read(ordersViewModelProvider.notifier).loadOrders();

        // Assert
        final state = container.read(ordersViewModelProvider);
        expect(state.status, OrdersStatus.loaded);
        expect(state.orders, isEmpty);
      },
    );

    test(
      'should clear previous errorMessage before a new load attempt',
      () async {
        // Arrange — first call fails
        when(
          () => mockGetMyOrders(),
        ).thenAnswer((_) async => const Left(ApiFailure(message: 'Error')));
        await container.read(ordersViewModelProvider.notifier).loadOrders();
        expect(container.read(ordersViewModelProvider).errorMessage, isNotNull);

        // Second call succeeds
        when(
          () => mockGetMyOrders(),
        ).thenAnswer((_) async => Right([tOrderPending]));

        // Act
        await container.read(ordersViewModelProvider.notifier).loadOrders();

        // Assert
        expect(container.read(ordersViewModelProvider).errorMessage, isNull);
        expect(
          container.read(ordersViewModelProvider).status,
          OrdersStatus.loaded,
        );
      },
    );
  });

  // ── loadOrderById ──────────────────────────────────────────────────────────
  group('loadOrderById', () {
    test(
      'should emit loading then loaded and set selectedOrder on success',
      () async {
        // Arrange
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => Right(tOrderPending));

        final statuses = <OrdersStatus>[];
        container.listen(
          ordersViewModelProvider.select((s) => s.status),
          (_, next) => statuses.add(next),
          fireImmediately: false,
        );

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('order_001');

        // Assert
        expect(statuses, [OrdersStatus.loading, OrdersStatus.loaded]);
        final state = container.read(ordersViewModelProvider);
        expect(state.selectedOrder, isNotNull);
        expect(state.selectedOrder!.id, 'order_001');
      },
    );

    test(
      'should set error status and clear selectedOrder on failure',
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Order not found', statusCode: 404);
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('bad_id');

        // Assert
        final state = container.read(ordersViewModelProvider);
        expect(state.status, OrdersStatus.error);
        expect(state.errorMessage, 'Order not found');
        expect(state.selectedOrder, isNull);
      },
    );

    test(
      'should auto-fix paymentStatus for a delivered selectedOrder',
      () async {
        // Arrange
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => Right(tDeliveredUnpaid));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('order_003');

        // Assert
        expect(
          container.read(ordersViewModelProvider).selectedOrder!.paymentStatus,
          'paid',
        );
      },
    );

    test(
      'should replace selectedOrder when loading a different order',
      () async {
        // Arrange — first load
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => Right(tOrderPending));
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('order_001');

        // Second load returns a different order
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => Right(tOrderDelivered));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('order_002');

        // Assert
        expect(
          container.read(ordersViewModelProvider).selectedOrder!.id,
          'order_002',
        );
      },
    );
  });

  // ── placeOrder ─────────────────────────────────────────────────────────────
  group('placeOrder', () {
    test('should return null and set error state on failure', () async {
      // Arrange
      const failure = ApiFailure(message: "You're offline.");
      when(
        () => mockPlaceOrder(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await container
          .read(ordersViewModelProvider.notifier)
          .placeOrder(
            paymentMethod: 'cash_on_delivery',
            deliveryDetails: const {},
          );

      // Assert
      expect(result, isNull);
      final state = container.read(ordersViewModelProvider);
      expect(state.status, OrdersStatus.error);
      expect(state.errorMessage, "You're offline.");
    });

    test('should NOT call recordDeduction when placement fails', () async {
      // Arrange
      when(
        () => mockPlaceOrder(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'Error')));

      // Act
      await container
          .read(ordersViewModelProvider.notifier)
          .placeOrder(
            paymentMethod: 'cash_on_delivery',
            deliveryDetails: const {},
          );

      // Assert
      verifyNever(() => mockStockOverride.recordDeduction(any(), any()));
    });
  });

  // ── cancelOrder ────────────────────────────────────────────────────────────
  group('cancelOrder', () {
    test(
      'should add orderId to pendingIds immediately before async resolves',
      () async {
        // Arrange — delay so we can observe the interim state
        when(() => mockCancelOrder(any())).thenAnswer((_) async {
          await Future<void>.delayed(const Duration(milliseconds: 30));
          return Right(tCancelledOrder);
        });

        // Act — intentionally NOT awaiting
        final future = container
            .read(ordersViewModelProvider.notifier)
            .cancelOrder('order_001');

        // Assert synchronously — id should already be in pendingIds
        expect(
          container.read(ordersViewModelProvider).isPending('order_001'),
          isTrue,
        );

        await future;
      },
    );

    test(
      'should remove orderId from pendingIds after successful cancellation',
      () async {
        // Arrange
        when(
          () => mockCancelOrder(any()),
        ).thenAnswer((_) async => Right(tCancelledOrder));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .cancelOrder('order_001');

        // Assert
        expect(
          container.read(ordersViewModelProvider).isPending('order_001'),
          isFalse,
        );
      },
    );

    test(
      'should remove orderId from pendingIds even when cancellation fails',
      () async {
        // Arrange
        when(
          () => mockCancelOrder(any()),
        ).thenAnswer((_) async => const Left(ApiFailure(message: 'Error')));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .cancelOrder('order_001');

        // Assert
        expect(
          container.read(ordersViewModelProvider).isPending('order_001'),
          isFalse,
        );
      },
    );

    test(
      'should update matching order in orders list to cancelled status',
      () async {
        // Arrange — pre-load the order
        when(
          () => mockGetMyOrders(),
        ).thenAnswer((_) async => Right([tOrderPending]));
        await container.read(ordersViewModelProvider.notifier).loadOrders();

        when(
          () => mockCancelOrder(any()),
        ).thenAnswer((_) async => Right(tCancelledOrder));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .cancelOrder('order_001');

        // Assert
        expect(
          container.read(ordersViewModelProvider).orders.first.status,
          OrderStatus.cancelled,
        );
      },
    );

    test(
      'should update selectedOrder when its id matches the cancelled order',
      () async {
        // Arrange — selectedOrder is tOrderPending (id=order_001)
        when(
          () => mockGetOrderById(any()),
        ).thenAnswer((_) async => Right(tOrderPending));
        await container
            .read(ordersViewModelProvider.notifier)
            .loadOrderById('order_001');

        when(
          () => mockCancelOrder(any()),
        ).thenAnswer((_) async => Right(tCancelledOrder));

        // Act
        await container
            .read(ordersViewModelProvider.notifier)
            .cancelOrder('order_001');

        // Assert
        expect(
          container.read(ordersViewModelProvider).selectedOrder!.status,
          OrderStatus.cancelled,
        );
      },
    );

    test('should set errorMessage on failure', () async {
      // Arrange
      const failure = ApiFailure(message: "You're offline.");
      when(
        () => mockCancelOrder(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      await container
          .read(ordersViewModelProvider.notifier)
          .cancelOrder('order_001');

      // Assert
      expect(
        container.read(ordersViewModelProvider).errorMessage,
        "You're offline.",
      );
    });
  });

  // ── OrdersState ────────────────────────────────────────────────────────────
  group('OrdersState', () {
    test('default constructor should have correct initial values', () {
      const s = OrdersState();
      expect(s.status, OrdersStatus.initial);
      expect(s.orders, isEmpty);
      expect(s.selectedOrder, isNull);
      expect(s.errorMessage, isNull);
      expect(s.isFromCache, isFalse);
      expect(s.pendingIds, isEmpty);
    });

    test('copyWith should update only specified fields', () {
      const original = OrdersState();
      final updated = original.copyWith(
        status: OrdersStatus.loaded,
        isFromCache: true,
      );
      expect(updated.status, OrdersStatus.loaded);
      expect(updated.isFromCache, isTrue);
      expect(updated.orders, isEmpty); // unchanged
      expect(updated.errorMessage, isNull); // unchanged
    });

    test('copyWith clearSelected=true should null out selectedOrder', () {
      final s = OrdersState(selectedOrder: tOrderPending);
      final cleared = s.copyWith(clearSelected: true);
      expect(cleared.selectedOrder, isNull);
    });

    test('copyWith without clearSelected should preserve selectedOrder', () {
      final s = OrdersState(selectedOrder: tOrderPending);
      final updated = s.copyWith(status: OrdersStatus.loaded);
      expect(updated.selectedOrder, tOrderPending);
    });

    test('copyWith clearError=true should clear errorMessage', () {
      const s = OrdersState(errorMessage: 'Some error');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test('isPending returns true only for ids in pendingIds', () {
      const s = OrdersState(pendingIds: {'order_001', 'order_002'});
      expect(s.isPending('order_001'), isTrue);
      expect(s.isPending('order_002'), isTrue);
      expect(s.isPending('order_999'), isFalse);
    });

    test('isPending returns false when pendingIds is empty', () {
      const s = OrdersState();
      expect(s.isPending('anything'), isFalse);
    });

    test('two states with same values should be equal', () {
      const s1 = OrdersState(status: OrdersStatus.loading);
      const s2 = OrdersState(status: OrdersStatus.loading);
      expect(s1, equals(s2));
    });

    test('states with different status should not be equal', () {
      const s1 = OrdersState(status: OrdersStatus.loading);
      const s2 = OrdersState(status: OrdersStatus.loaded);
      expect(s1, isNot(equals(s2)));
    });

    test('props should include status, isFromCache, and errorMessage', () {
      const s = OrdersState(
        status: OrdersStatus.error,
        isFromCache: true,
        errorMessage: 'err',
      );
      expect(s.props, contains(OrdersStatus.error));
      expect(s.props, contains(true));
      expect(s.props, contains('err'));
    });

    test('two default instances should be equal', () {
      const s1 = OrdersState();
      const s2 = OrdersState();
      expect(s1, equals(s2));
    });
  });

  // ── OrdersStatus ───────────────────────────────────────────────────────────
  group('OrdersStatus', () {
    test('should define exactly 4 values', () {
      expect(OrdersStatus.values, hasLength(4));
      expect(
        OrdersStatus.values,
        containsAll([
          OrdersStatus.initial,
          OrdersStatus.loading,
          OrdersStatus.loaded,
          OrdersStatus.error,
        ]),
      );
    });
  });
}
