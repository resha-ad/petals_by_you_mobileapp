import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/usecases/get_cart_usecase.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late GetCartUsecase usecase;
  late MockCartRepository mockRepo;

  const tCartItem = CartItemEntity(
    type: 'product',
    refId: 'ref_1',
    quantity: 2,
    unitPrice: 1500,
    subtotal: 3000,
  );
  const tCart = CartEntity(userId: 'user_1', items: [tCartItem], total: 3000);
  const tEmptyCart = CartEntity(userId: 'user_1', items: [], total: 0);

  setUpAll(() {
    registerFallbackValue(tEmptyCart);
  });

  setUp(() {
    mockRepo = MockCartRepository();
    usecase = GetCartUsecase(mockRepo);
  });

  group('GetCartUsecase', () {
    test('should return CartEntity on success', () async {
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => const Right(tCart));

      final result = await usecase();

      expect(result, const Right(tCart));
      verify(() => mockRepo.getCart()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return ApiFailure when server fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch cart');
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
    });

    test('should return empty cart when user has no items', () async {
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      final result = await usecase();

      result.fold((_) => fail('Should be Right'), (cart) {
        expect(cart.isEmpty, true);
        expect(cart.itemCount, 0);
      });
    });

    test('should return ApiFailure when offline with no cache', () async {
      const failure = ApiFailure(message: 'You\'re offline');
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.getCart(),
      ).thenAnswer((_) async => const Right(tCart));

      await usecase();

      verify(() => mockRepo.getCart()).called(1);
    });
  });
}
