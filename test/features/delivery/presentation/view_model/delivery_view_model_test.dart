import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/core/services/connectivity/network_info.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/domain/usecases/delivery_usecase.dart';
import 'package:sprint1_project/features/delivery/presentation/view_model/delivery_view_model.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────────
class MockGetDeliveryByOrderIdUsecase extends Mock
    implements GetDeliveryByOrderIdUsecase {}

// networkInfoProvider is Provider<NetworkInfo> (concrete type)
class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late MockGetDeliveryByOrderIdUsecase mockGetDelivery;
  late MockNetworkInfo mockNetworkInfo;
  late ProviderContainer container;

  // ── Fixtures ───────────────────────────────────────────────────────────────
  const tOrderId = 'order_001';

  const tAddress = DeliveryAddressEntity(
    street: '123 Flower St',
    city: 'Kathmandu',
    country: 'Nepal',
  );

  final tDelivery = DeliveryEntity(
    id: 'delivery_abc',
    orderId: tOrderId,
    recipientName: 'Jane Doe',
    recipientPhone: '9800000000',
    address: tAddress,
    status: DeliveryStatus.inTransit,
    trackingUpdates: [
      TrackingUpdateEntity(
        message: 'Order picked up',
        timestamp: DateTime(2024, 1, 15, 10),
        updatedBy: 'driver_01',
      ),
    ],
    createdAt: DateTime(2024, 1, 14),
    updatedAt: DateTime(2024, 1, 15),
  );

  // Helper to read state for the test order id
  DeliveryState readState() =>
      container.read(deliveryViewModelProvider(tOrderId));

  // Helper to read the notifier for the test order id
  DeliveryViewModel readNotifier() =>
      container.read(deliveryViewModelProvider(tOrderId).notifier);

  setUp(() {
    mockGetDelivery = MockGetDeliveryByOrderIdUsecase();
    mockNetworkInfo = MockNetworkInfo();

    // Default: device is online
    when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);

    // deliveryViewModelProvider is a .family provider keyed by orderId.
    // We override the sub-providers it reads from so our mocks are injected.
    container = ProviderContainer(
      overrides: [
        getDeliveryByOrderIdUsecaseProvider.overrideWithValue(mockGetDelivery),
        networkInfoProvider.overrideWithValue(mockNetworkInfo),
      ],
    );
  });

  tearDown(() => container.dispose());

  // ── initial state ──────────────────────────────────────────────────────────
  group('initial state', () {
    test('should start with DeliveryFetchStatus.initial and no data', () {
      // Act
      final state = readState();

      // Assert
      expect(state.status, DeliveryFetchStatus.initial);
      expect(state.delivery, isNull);
      expect(state.errorMessage, isNull);
      expect(state.isFromCache, isFalse);
    });
  });

  // ── loadDelivery ───────────────────────────────────────────────────────────
  group('loadDelivery', () {
    test('should emit loading then loaded with delivery on success', () async {
      // Arrange
      when(
        () => mockGetDelivery(any()),
      ).thenAnswer((_) async => Right(tDelivery));

      final statuses = <DeliveryFetchStatus>[];
      container.listen(
        deliveryViewModelProvider(tOrderId).select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );

      // Act
      await readNotifier().loadDelivery();

      // Assert
      expect(statuses, [
        DeliveryFetchStatus.loading,
        DeliveryFetchStatus.loaded,
      ]);
      expect(readState().delivery, isNotNull);
      expect(readState().delivery!.id, 'delivery_abc');
      expect(readState().errorMessage, isNull);
    });

    test('should set isFromCache=false when device is online', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(
        () => mockGetDelivery(any()),
      ).thenAnswer((_) async => Right(tDelivery));

      // Act
      await readNotifier().loadDelivery();

      // Assert — isFromCache = !isOnline = !true = false
      expect(readState().isFromCache, isFalse);
    });

    test('should set isFromCache=true when device is offline', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(
        () => mockGetDelivery(any()),
      ).thenAnswer((_) async => Right(tDelivery));

      // Act
      await readNotifier().loadDelivery();

      // Assert — isFromCache = !isOnline = !false = true
      expect(readState().isFromCache, isTrue);
    });

    test(
      'should set status=noDelivery for "No delivery info available" failure',
      () async {
        // Arrange — this is a soft non-error: delivery not yet created for order
        const failure = ApiFailure(
          message: 'No delivery info available for this order yet.',
        );
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        await readNotifier().loadDelivery();

        // Assert — VM maps this specific message to noDelivery, not error
        expect(readState().status, DeliveryFetchStatus.noDelivery);
        expect(readState().errorMessage, isNull);
        expect(readState().delivery, isNull);
      },
    );

    test(
      'should set status=noDelivery for "not cached" offline failure',
      () async {
        // Arrange — offline + not in cache
        const failure = ApiFailure(
          message: "You're offline and delivery info is not cached.",
        );
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        await readNotifier().loadDelivery();

        // Assert — message contains 'not cached' → noDelivery status
        expect(readState().status, DeliveryFetchStatus.noDelivery);
        expect(readState().errorMessage, isNull);
      },
    );

    test(
      'should set status=error and errorMessage for other failures',
      () async {
        // Arrange — a genuine network/server error
        const failure = ApiFailure(message: 'Internal server error');
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        await readNotifier().loadDelivery();

        // Assert
        expect(readState().status, DeliveryFetchStatus.error);
        expect(readState().errorMessage, 'Internal server error');
        expect(readState().delivery, isNull);
      },
    );

    test('should clear previous delivery before loading new data', () async {
      // Arrange — first load succeeds
      when(
        () => mockGetDelivery(any()),
      ).thenAnswer((_) async => Right(tDelivery));
      await readNotifier().loadDelivery();
      expect(readState().delivery, isNotNull);

      // Second load returns a different delivery
      final tDelivery2 = DeliveryEntity(
        id: 'delivery_xyz',
        orderId: tOrderId,
        recipientName: 'John',
        recipientPhone: '9900000000',
        address: tAddress,
        status: DeliveryStatus.assigned,
        trackingUpdates: const [],
        createdAt: DateTime(2024, 1, 16),
        updatedAt: DateTime(2024, 1, 16),
      );
      when(
        () => mockGetDelivery(any()),
      ).thenAnswer((_) async => Right(tDelivery2));

      // Act
      await readNotifier().loadDelivery();

      // Assert — previous delivery was replaced
      expect(readState().delivery!.id, 'delivery_xyz');
    });

    test(
      'should clear previous errorMessage before a new load attempt',
      () async {
        // Arrange — first load fails
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => const Left(ApiFailure(message: 'Error')));
        await readNotifier().loadDelivery();
        expect(readState().errorMessage, isNotNull);

        // Second load succeeds
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => Right(tDelivery));

        // Act
        await readNotifier().loadDelivery();

        // Assert
        expect(readState().errorMessage, isNull);
        expect(readState().status, DeliveryFetchStatus.loaded);
      },
    );

    test(
      'should pass the orderId from the provider family key to the usecase',
      () async {
        // Arrange
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => Right(tDelivery));

        // Act
        await readNotifier().loadDelivery();

        // Assert — usecase was called with the family key value ('order_001')
        final captured =
            verify(() => mockGetDelivery(captureAny())).captured.first
                as String;
        expect(captured, tOrderId);
      },
    );

    test(
      'should call usecase exactly once per loadDelivery invocation',
      () async {
        // Arrange
        when(
          () => mockGetDelivery(any()),
        ).thenAnswer((_) async => Right(tDelivery));

        // Act — call twice
        await readNotifier().loadDelivery();
        await readNotifier().loadDelivery();

        // Assert
        verify(() => mockGetDelivery(any())).called(2);
      },
    );

    test(
      'two different orderId keys should produce independent state instances',
      () async {
        // Arrange — both succeed with different delivery ids
        final tDeliveryOther = DeliveryEntity(
          id: 'delivery_other',
          orderId: 'order_002',
          recipientName: 'Bob',
          recipientPhone: '9700000000',
          address: tAddress,
          status: DeliveryStatus.pending,
          trackingUpdates: const [],
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
        );

        when(
          () => mockGetDelivery('order_001'),
        ).thenAnswer((_) async => Right(tDelivery));
        when(
          () => mockGetDelivery('order_002'),
        ).thenAnswer((_) async => Right(tDeliveryOther));

        // Act — load for both order ids
        await container
            .read(deliveryViewModelProvider('order_001').notifier)
            .loadDelivery();
        await container
            .read(deliveryViewModelProvider('order_002').notifier)
            .loadDelivery();

        // Assert — each key has its own independent state
        expect(
          container.read(deliveryViewModelProvider('order_001')).delivery!.id,
          'delivery_abc',
        );
        expect(
          container.read(deliveryViewModelProvider('order_002')).delivery!.id,
          'delivery_other',
        );
      },
    );
  });

  // ── DeliveryState unit tests ───────────────────────────────────────────────
  group('DeliveryState', () {
    test('default constructor should have correct initial values', () {
      const s = DeliveryState();
      expect(s.status, DeliveryFetchStatus.initial);
      expect(s.delivery, isNull);
      expect(s.errorMessage, isNull);
      expect(s.isFromCache, isFalse);
    });

    test('copyWith should update only specified fields', () {
      const original = DeliveryState();
      final updated = original.copyWith(
        status: DeliveryFetchStatus.loaded,
        isFromCache: true,
      );
      expect(updated.status, DeliveryFetchStatus.loaded);
      expect(updated.isFromCache, isTrue);
      expect(updated.delivery, isNull); // unchanged
      expect(updated.errorMessage, isNull); // unchanged
    });

    test('copyWith clearDelivery=true should null out delivery', () {
      final s = DeliveryState(delivery: tDelivery);
      final cleared = s.copyWith(clearDelivery: true);
      expect(cleared.delivery, isNull);
    });

    test(
      'copyWith without clearDelivery should preserve existing delivery',
      () {
        final s = DeliveryState(delivery: tDelivery);
        final updated = s.copyWith(status: DeliveryFetchStatus.loaded);
        expect(updated.delivery, tDelivery);
      },
    );

    test('copyWith clearError=true should clear errorMessage', () {
      const s = DeliveryState(errorMessage: 'Some error');
      final cleared = s.copyWith(clearError: true);
      expect(cleared.errorMessage, isNull);
    });

    test(
      'copyWith without clearError should preserve existing errorMessage',
      () {
        const s = DeliveryState(errorMessage: 'Some error');
        final updated = s.copyWith(status: DeliveryFetchStatus.error);
        expect(updated.errorMessage, 'Some error');
      },
    );

    test('two states with same values should be equal', () {
      const s1 = DeliveryState(status: DeliveryFetchStatus.loading);
      const s2 = DeliveryState(status: DeliveryFetchStatus.loading);
      expect(s1, equals(s2));
    });

    test('states with different status should not be equal', () {
      const s1 = DeliveryState(status: DeliveryFetchStatus.loading);
      const s2 = DeliveryState(status: DeliveryFetchStatus.loaded);
      expect(s1, isNot(equals(s2)));
    });

    test(
      'props should include status, delivery, errorMessage, isFromCache',
      () {
        const s = DeliveryState(
          status: DeliveryFetchStatus.error,
          errorMessage: 'err',
          isFromCache: true,
        );
        expect(s.props, contains(DeliveryFetchStatus.error));
        expect(s.props, contains('err'));
        expect(s.props, contains(true));
      },
    );

    test('two default instances should be equal', () {
      const s1 = DeliveryState();
      const s2 = DeliveryState();
      expect(s1, equals(s2));
    });
  });

  // ── DeliveryFetchStatus ────────────────────────────────────────────────────
  group('DeliveryFetchStatus', () {
    test('should define exactly 5 values', () {
      expect(DeliveryFetchStatus.values, hasLength(5));
      expect(
        DeliveryFetchStatus.values,
        containsAll([
          DeliveryFetchStatus.initial,
          DeliveryFetchStatus.loading,
          DeliveryFetchStatus.loaded,
          DeliveryFetchStatus.noDelivery,
          DeliveryFetchStatus.error,
        ]),
      );
    });
  });
}
