import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/usecases/cancel_order_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late CancelOrderUsecase usecase;
  late MockOrderRepository mockRepository;

  // ── Fixtures ────────────────────────────────────────────────────────────────
  const tOrderId = 'order_abc123';
  const tReason = 'Changed my mind';
  const tParams = CancelOrderParams(id: tOrderId, reason: tReason);

  final tCancelledOrder = OrderEntity(
    id: tOrderId,
    items: const [],
    totalAmount: 3000,
    status: OrderStatus.cancelled,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    cancelReason: tReason,
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 16),
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = CancelOrderUsecase(mockRepository);
  });

  // ── call ───────────────────────────────────────────────────────────────────
  group('CancelOrderUsecase', () {
    test(
      'should delegate to repository.cancelOrder with correct id and reason',
      () async {
        // Arrange
        when(
          () => mockRepository.cancelOrder(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => Right(tCancelledOrder));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, Right(tCancelledOrder));
        verify(
          () => mockRepository.cancelOrder(id: tOrderId, reason: tReason),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should pass null reason when CancelOrderParams has no reason',
      () async {
        // Arrange
        const paramsNoReason = CancelOrderParams(id: tOrderId);
        when(
          () => mockRepository.cancelOrder(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => Right(tCancelledOrder));

        // Act
        await usecase(paramsNoReason);

        // Assert
        verify(
          () => mockRepository.cancelOrder(id: tOrderId, reason: null),
        ).called(1);
      },
    );

    test('should return Right with cancelled status on success', () async {
      // Arrange
      when(
        () => mockRepository.cancelOrder(
          id: any(named: 'id'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => Right(tCancelledOrder));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((_) => fail('Should be Right'), (order) {
        expect(order.status, OrderStatus.cancelled);
        expect(order.isCancellable, isFalse);
        expect(order.cancelReason, tReason);
      });
    });

    test('should return Left(ApiFailure) when offline', () async {
      // Arrange
      const failure = ApiFailure(
        message: "You're offline. Connect to cancel an order.",
      );
      when(
        () => mockRepository.cancelOrder(
          id: any(named: 'id'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
    });

    test(
      'should return Left(ApiFailure) when order cannot be cancelled',
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Order cannot be cancelled');
        when(
          () => mockRepository.cancelOrder(
            id: any(named: 'id'),
            reason: any(named: 'reason'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tParams);

        // Assert
        result.fold(
          (f) => expect(f.message, 'Order cannot be cancelled'),
          (_) => fail('Should be Left'),
        );
      },
    );

    test('should call repository exactly once per invocation', () async {
      // Arrange
      when(
        () => mockRepository.cancelOrder(
          id: any(named: 'id'),
          reason: any(named: 'reason'),
        ),
      ).thenAnswer((_) async => Right(tCancelledOrder));

      // Act
      await usecase(tParams);

      // Assert
      verify(
        () => mockRepository.cancelOrder(
          id: any(named: 'id'),
          reason: any(named: 'reason'),
        ),
      ).called(1);
    });
  });

  // ── CancelOrderParams ──────────────────────────────────────────────────────
  group('CancelOrderParams', () {
    test('props should contain only [id] — reason is excluded', () {
      // Assert — per source: List<Object?> get props => [id]
      expect(tParams.props, [tOrderId]);
    });

    test('two params with same id are equal regardless of reason', () {
      const p1 = CancelOrderParams(id: tOrderId, reason: 'reason A');
      const p2 = CancelOrderParams(id: tOrderId, reason: 'reason B');
      // reason is not in props, so equatable ignores it
      expect(p1, equals(p2));
    });

    test('two params with same id and no reason are equal', () {
      const p1 = CancelOrderParams(id: tOrderId);
      const p2 = CancelOrderParams(id: tOrderId);
      expect(p1, equals(p2));
    });

    test('params with different ids are not equal', () {
      const p1 = CancelOrderParams(id: 'order_001');
      const p2 = CancelOrderParams(id: 'order_002');
      expect(p1, isNot(equals(p2)));
    });
  });
}
