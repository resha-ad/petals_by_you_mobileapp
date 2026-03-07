import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/orders/domain/entities/orders_entity.dart';
import 'package:sprint1_project/features/orders/domain/repositories/orders_repository.dart';
import 'package:sprint1_project/features/orders/domain/usecases/place_order_usecase.dart';

class MockOrderRepository extends Mock implements IOrderRepository {}

void main() {
  late PlaceOrderUsecase usecase;
  late MockOrderRepository mockRepository;

  // ── Fixtures ────────────────────────────────────────────────────────────────
  final tOrder = OrderEntity(
    id: 'order_001',
    items: const [],
    totalAmount: 3000,
    status: OrderStatus.pending,
    paymentStatus: 'unpaid',
    paymentMethod: 'cash_on_delivery',
    createdAt: DateTime(2024, 1, 15),
    updatedAt: DateTime(2024, 1, 15),
  );

  const tDeliveryDetails = <String, dynamic>{
    'recipientName': 'John Doe',
    'address': <String, dynamic>{'street': '123 Main St', 'city': 'Kathmandu'},
  };

  const tParams = PlaceOrderParams(
    paymentMethod: 'cash_on_delivery',
    deliveryDetails: tDeliveryDetails,
    notes: 'Please deliver in the morning',
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    usecase = PlaceOrderUsecase(mockRepository);
  });

  // ── call ───────────────────────────────────────────────────────────────────
  group('PlaceOrderUsecase', () {
    test(
      'should delegate to repository.placeOrder with correct parameters',
      () async {
        // Arrange
        when(
          () => mockRepository.placeOrder(
            paymentMethod: any(named: 'paymentMethod'),
            deliveryDetails: any(named: 'deliveryDetails'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer((_) async => Right(tOrder));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, Right(tOrder));
        verify(
          () => mockRepository.placeOrder(
            paymentMethod: 'cash_on_delivery',
            deliveryDetails: tDeliveryDetails,
            notes: 'Please deliver in the morning',
          ),
        ).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test(
      'should pass notes as null when PlaceOrderParams has no notes',
      () async {
        // Arrange
        const paramsNoNotes = PlaceOrderParams(
          paymentMethod: 'cash_on_delivery',
          deliveryDetails: tDeliveryDetails,
          // notes omitted
        );
        when(
          () => mockRepository.placeOrder(
            paymentMethod: any(named: 'paymentMethod'),
            deliveryDetails: any(named: 'deliveryDetails'),
            notes: any(named: 'notes'),
          ),
        ).thenAnswer((_) async => Right(tOrder));

        // Act
        await usecase(paramsNoNotes);

        // Assert
        verify(
          () => mockRepository.placeOrder(
            paymentMethod: 'cash_on_delivery',
            deliveryDetails: any(named: 'deliveryDetails'),
            notes: null,
          ),
        ).called(1);
      },
    );

    test('should return Right(OrderEntity) on repository success', () async {
      // Arrange
      when(
        () => mockRepository.placeOrder(
          paymentMethod: any(named: 'paymentMethod'),
          deliveryDetails: any(named: 'deliveryDetails'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Right(tOrder));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((_) => fail('Should be Right'), (order) {
        expect(order.id, 'order_001');
        expect(order.status, OrderStatus.pending);
        expect(order.isCancellable, isTrue);
      });
    });

    test('should return Left(ApiFailure) when offline', () async {
      // Arrange
      const failure = ApiFailure(
        message: "You're offline. Connect to place an order.",
      );
      when(
        () => mockRepository.placeOrder(
          paymentMethod: any(named: 'paymentMethod'),
          deliveryDetails: any(named: 'deliveryDetails'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
    });

    test('should return Left(ApiFailure) on server error', () async {
      // Arrange
      const failure = ApiFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(
        () => mockRepository.placeOrder(
          paymentMethod: any(named: 'paymentMethod'),
          deliveryDetails: any(named: 'deliveryDetails'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 500);
      }, (_) => fail('Should be Left'));
    });

    test('should call repository exactly once per invocation', () async {
      // Arrange
      when(
        () => mockRepository.placeOrder(
          paymentMethod: any(named: 'paymentMethod'),
          deliveryDetails: any(named: 'deliveryDetails'),
          notes: any(named: 'notes'),
        ),
      ).thenAnswer((_) async => Right(tOrder));

      // Act
      await usecase(tParams);
      await usecase(tParams);

      // Assert
      verify(
        () => mockRepository.placeOrder(
          paymentMethod: any(named: 'paymentMethod'),
          deliveryDetails: any(named: 'deliveryDetails'),
          notes: any(named: 'notes'),
        ),
      ).called(2);
    });
  });

  // ── PlaceOrderParams ───────────────────────────────────────────────────────
  group('PlaceOrderParams', () {
    test('props should contain [paymentMethod, deliveryDetails]', () {
      // Assert — notes is NOT in props per source
      expect(tParams.props, [tParams.paymentMethod, tParams.deliveryDetails]);
    });

    test(
      'two params with same paymentMethod and deliveryDetails are equal',
      () {
        const p1 = PlaceOrderParams(
          paymentMethod: 'cash_on_delivery',
          deliveryDetails: {'street': '123 Main'},
        );
        const p2 = PlaceOrderParams(
          paymentMethod: 'cash_on_delivery',
          deliveryDetails: {'street': '123 Main'},
          notes:
              'Different notes', // notes not in props → should still be equal
        );
        expect(p1, equals(p2));
      },
    );

    test('params with different paymentMethod are not equal', () {
      const p1 = PlaceOrderParams(
        paymentMethod: 'cash_on_delivery',
        deliveryDetails: {'street': '123'},
      );
      const p2 = PlaceOrderParams(
        paymentMethod: 'online',
        deliveryDetails: {'street': '123'},
      );
      expect(p1, isNot(equals(p2)));
    });
  });
}
