import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/delivery/domain/entities/delivery_entity.dart';
import 'package:sprint1_project/features/delivery/domain/repositories/delivery_repository.dart';
import 'package:sprint1_project/features/delivery/domain/usecases/delivery_usecase.dart';

class MockDeliveryRepository extends Mock implements IDeliveryRepository {}

void main() {
  late GetDeliveryByOrderIdUsecase usecase;
  late MockDeliveryRepository mockRepository;

  // ── Fixtures ────────────────────────────────────────────────────────────────
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

  setUp(() {
    mockRepository = MockDeliveryRepository();
    usecase = GetDeliveryByOrderIdUsecase(mockRepository);
  });

  // ── call ───────────────────────────────────────────────────────────────────
  group('GetDeliveryByOrderIdUsecase', () {
    test(
      'should delegate to repository.getDeliveryByOrderId with correct orderId',
      () async {
        // Arrange
        when(
          () => mockRepository.getDeliveryByOrderId(any()),
        ).thenAnswer((_) async => Right(tDelivery));

        // Act
        final result = await usecase(tOrderId);

        // Assert
        expect(result, Right(tDelivery));
        verify(() => mockRepository.getDeliveryByOrderId(tOrderId)).called(1);
        verifyNoMoreInteractions(mockRepository);
      },
    );

    test('should pass the exact orderId string to repository', () async {
      // Arrange
      when(
        () => mockRepository.getDeliveryByOrderId(any()),
      ).thenAnswer((_) async => Right(tDelivery));

      // Act
      await usecase(tOrderId);

      // Assert
      final captured =
          verify(
                () => mockRepository.getDeliveryByOrderId(captureAny()),
              ).captured.first
              as String;
      expect(captured, tOrderId);
    });

    test(
      'should return Right(DeliveryEntity) with correct fields on success',
      () async {
        // Arrange
        when(
          () => mockRepository.getDeliveryByOrderId(any()),
        ).thenAnswer((_) async => Right(tDelivery));

        // Act
        final result = await usecase(tOrderId);

        // Assert
        result.fold((_) => fail('Should be Right'), (delivery) {
          expect(delivery.id, 'delivery_abc');
          expect(delivery.orderId, tOrderId);
          expect(delivery.status, DeliveryStatus.inTransit);
          expect(delivery.trackingUpdates.length, 1);
          expect(delivery.trackingUpdates.first.message, 'Order picked up');
          expect(delivery.isActive, isTrue);
        });
      },
    );

    test('should return Left(ApiFailure) with "No delivery info available" '
        'when repository has no delivery record for the order', () async {
      // Arrange
      const failure = ApiFailure(
        message: 'No delivery info available for this order yet.',
      );
      when(
        () => mockRepository.getDeliveryByOrderId(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tOrderId);

      // Assert
      expect(result.isLeft(), isTrue);
      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect(f.message, contains('No delivery info available'));
      }, (_) => fail('Should be Left'));
    });

    test('should return Left(ApiFailure) with "not cached" '
        'when device is offline and delivery is not cached', () async {
      // Arrange
      const failure = ApiFailure(
        message: "You're offline and delivery info is not cached.",
      );
      when(
        () => mockRepository.getDeliveryByOrderId(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tOrderId);

      // Assert
      result.fold(
        (f) => expect(f.message, contains('not cached')),
        (_) => fail('Should be Left'),
      );
    });

    test('should return Left(ApiFailure) on generic network error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockRepository.getDeliveryByOrderId(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tOrderId);

      // Assert
      expect(result, const Left(failure));
    });

    test('should call repository exactly once per invocation', () async {
      // Arrange
      when(
        () => mockRepository.getDeliveryByOrderId(any()),
      ).thenAnswer((_) async => Right(tDelivery));

      // Act
      await usecase(tOrderId);
      await usecase(tOrderId);

      // Assert
      verify(() => mockRepository.getDeliveryByOrderId(tOrderId)).called(2);
    });
  });
}
