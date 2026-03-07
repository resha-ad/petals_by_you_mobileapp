import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/usecases/clear_cart_usecase.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late ClearCartUsecase usecase;
  late MockCartRepository mockRepo;

  const tEmptyCart = CartEntity(userId: 'user_1', items: [], total: 0);

  setUpAll(() {
    registerFallbackValue(tEmptyCart);
  });

  setUp(() {
    mockRepo = MockCartRepository();
    usecase = ClearCartUsecase(mockRepo);
  });

  group('ClearCartUsecase', () {
    test('should return empty CartEntity on success', () async {
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      final result = await usecase();

      expect(result, const Right(tEmptyCart));
      verify(() => mockRepo.clearCart()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test(
      'should return cleared cart with empty items and zero total',
      () async {
        when(
          () => mockRepo.clearCart(),
        ).thenAnswer((_) async => const Right(tEmptyCart));

        final result = await usecase();

        result.fold((_) => fail('Should be Right'), (cart) {
          expect(cart.isEmpty, true);
          expect(cart.items, isEmpty);
          expect(cart.total, 0);
        });
      },
    );

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to clear cart.',
      );
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect(f.message, contains('offline'));
      }, (_) => fail('Should be Left'));
    });

    test('should return ApiFailure on server error', () async {
      const failure = ApiFailure(message: 'Server error', statusCode: 500);
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 500);
      }, (_) => fail('Should be Left'));
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.clearCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await usecase();

      verify(() => mockRepo.clearCart()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
