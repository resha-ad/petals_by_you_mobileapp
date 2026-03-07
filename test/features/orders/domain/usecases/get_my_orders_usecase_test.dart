import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/usecases/get_my_orders_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late GetMyOrdersUsecase usecase;
  late MockOrderRepository mockRepository;

  // ── Fixtures ────────────────────────────────────────────────────────────────
  final tOrders = [
    OrderEntity(
      id: 'order_001',
      items: const [],
      totalAmount: 3000,
      status: OrderStatus.pending,
      paymentStatus: 'unpaid',
      paymentMethod: 'cash_on_delivery',
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
    ),
    OrderEntity(
      id: 'order_002',
      items: const [],
      totalAmount: 1500,
      status: OrderStatus.delivered,
      paymentStatus: 'paid',
      paymentMethod: 'cash_on_delivery',
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 1, 12),
    ),
  ];

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = GetMyOrdersUsecase(mockRepository);
  });

  // ── call ───────────────────────────────────────────────────────────────────
  group('GetMyOrdersUsecase', () {
    test('should always call repository with page=1 and limit=20', () async {
      // Arrange
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tOrders));

      // Act
      await usecase();

      // Assert
      verify(() => mockRepository.getMyOrders(page: 1, limit: 20)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return Right(list) when repository succeeds', () async {
      // Arrange
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tOrders));

      // Act
      final result = await usecase();

      // Assert
      expect(result, Right(tOrders));
    });

    test('should return list with correct count', () async {
      // Arrange
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tOrders));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (_) => fail('Should be Right'),
        (orders) => expect(orders.length, 2),
      );
    });

    test('should return Right([]) when user has no orders', () async {
      // Arrange
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final result = await usecase();

      // Assert
      result.fold(
        (_) => fail('Should be Right'),
        (orders) => expect(orders, isEmpty),
      );
    });

    test('should return Left(ApiFailure) when repository fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });

    test(
      'should propagate the exact failure message from repository',
      () async {
        // Arrange
        const failure = ApiFailure(
          message: 'Unauthorized — please log in again',
        );
        when(
          () => mockRepository.getMyOrders(
            page: any(named: 'page'),
            limit: any(named: 'limit'),
          ),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase();

        // Assert
        result.fold(
          (f) => expect(f.message, 'Unauthorized — please log in again'),
          (_) => fail('Should be Left'),
        );
      },
    );

    test('should call repository exactly once per invocation', () async {
      // Arrange
      when(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).thenAnswer((_) async => Right(tOrders));

      // Act
      await usecase();
      await usecase();

      // Assert
      verify(
        () => mockRepository.getMyOrders(
          page: any(named: 'page'),
          limit: any(named: 'limit'),
        ),
      ).called(2);
    });
  });
}
