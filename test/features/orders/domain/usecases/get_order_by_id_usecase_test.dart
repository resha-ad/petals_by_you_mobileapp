import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/usecases/get_order_by_id_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late GetOrderByIdUsecase usecase;
  late MockOrderRepository mockRepository;

  // ── Fixtures ────────────────────────────────────────────────────────────────
  const tOrderId = 'order_abc123';

  final tOrder = OrderEntity(
    id: tOrderId,
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
    status: OrderStatus.confirmed,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = GetOrderByIdUsecase(mockRepository);
  });

  // ── call ───────────────────────────────────────────────────────────────────
  group('GetOrderByIdUsecase', () {
    test(
      'should delegate to repository.getOrderById with the correct id',
      () async {
        // Arrange
        when(
          () => mockRepository.getOrderById(any()),
        ).thenAnswer((_) async => Right(tOrder));

        // Act
        final result = await usecase(tOrderId);

        // Assert
        expect(result, Right(tOrder));
        verify(() => mockRepository.getOrderById(tOrderId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should pass the exact id string to repository', () async {
      // Arrange
      when(
        () => mockRepository.getOrderById(any()),
      ).thenAnswer((_) async => Right(tOrder));

      // Act
      await usecase(tOrderId);

      // Assert
      final captured =
          verify(() => mockRepository.getOrderById(captureAny())).captured.first
              as String;
      expect(captured, tOrderId);
    });

    test('should return Right(OrderEntity) on success', () async {
      // Arrange
      when(
        () => mockRepository.getOrderById(any()),
      ).thenAnswer((_) async => Right(tOrder));

      // Act
      final result = await usecase(tOrderId);

      // Assert
      result.fold((_) => fail('Should be Right'), (order) {
        expect(order.id, tOrderId);
        expect(order.status, OrderStatus.confirmed);
        expect(order.totalAmount, 3000.0);
        expect(order.items.length, 1);
        expect(order.items.first.name, 'Red Roses');
        // confirmed is not cancellable
        expect(order.isCancellable, isFalse);
      });
    });

    test(
      'should return Left(ApiFailure) with 404 when order is not found',
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Order not found', statusCode: 404);
        when(
          () => mockRepository.getOrderById(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tOrderId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold((f) {
          expect(f, isA<ApiFailure>());
          expect((f as ApiFailure).statusCode, 404);
          expect(f.message, 'Order not found');
        }, (_) => fail('Should be Left'));
      },
    );

    test(
      'should return Left(ApiFailure) when offline and order not cached',
      () async {
        // Arrange
        const failure = ApiFailure(
          message: "You're offline and this order isn't cached.",
        );
        when(
          () => mockRepository.getOrderById(any()),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tOrderId);

        // Assert
        expect(result.isLeft(), isTrue);
        result.fold(
          (f) => expect(f.message, contains('offline')),
          (_) => fail('Should be Left'),
        );
      },
    );

    test('should call repository exactly once per invocation', () async {
      // Arrange
      when(
        () => mockRepository.getOrderById(any()),
      ).thenAnswer((_) async => Right(tOrder));

      // Act
      await usecase(tOrderId);
      await usecase(tOrderId);

      // Assert
      verify(() => mockRepository.getOrderById(tOrderId)).called(2);
    });
  });
}
