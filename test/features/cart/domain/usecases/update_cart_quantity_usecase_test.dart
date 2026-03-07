import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/usecases/update_cart_quantity_usecase.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late UpdateCartQuantityUsecase usecase;
  late MockCartRepository mockRepo;

  const tCartItem = CartItemEntity(
    type: 'product',
    refId: 'ref_1',
    quantity: 3,
    unitPrice: 1500,
    subtotal: 4500,
  );
  const tCart = CartEntity(userId: 'user_1', items: [tCartItem], total: 4500);
  const tEmptyCart = CartEntity(userId: 'user_1', items: [], total: 0);

  setUpAll(() {
    registerFallbackValue(tEmptyCart);
    registerFallbackValue(
      const UpdateQuantityParams(refId: 'fallback', quantity: 1),
    );
  });

  setUp(() {
    mockRepo = MockCartRepository();
    usecase = UpdateCartQuantityUsecase(mockRepo);
  });

  group('UpdateCartQuantityUsecase', () {
    test('should return updated CartEntity on success', () async {
      when(
        () => mockRepo.updateQuantity(
          refId: any(named: 'refId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      final result = await usecase(
        const UpdateQuantityParams(refId: 'ref_1', quantity: 3),
      );

      expect(result, const Right(tCart));
    });

    test('should pass correct refId and quantity to repository', () async {
      when(
        () => mockRepo.updateQuantity(
          refId: any(named: 'refId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      await usecase(const UpdateQuantityParams(refId: 'ref_xyz', quantity: 5));

      verify(
        () => mockRepo.updateQuantity(refId: 'ref_xyz', quantity: 5),
      ).called(1);
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.updateQuantity(
          refId: any(named: 'refId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      await usecase(const UpdateQuantityParams(refId: 'ref_1', quantity: 2));

      verify(
        () => mockRepo.updateQuantity(refId: 'ref_1', quantity: 2),
      ).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to update cart.',
      );
      when(
        () => mockRepo.updateQuantity(
          refId: any(named: 'refId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const UpdateQuantityParams(refId: 'ref_1', quantity: 2),
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should return ApiFailure when quantity is invalid', () async {
      const failure = ApiFailure(message: 'Quantity must be at least 1');
      when(
        () => mockRepo.updateQuantity(
          refId: any(named: 'refId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const UpdateQuantityParams(refId: 'ref_1', quantity: 0),
      );

      result.fold(
        (f) => expect(f.message, 'Quantity must be at least 1'),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('UpdateQuantityParams', () {
    test('should have correct props', () {
      const p = UpdateQuantityParams(refId: 'ref_1', quantity: 3);
      expect(p.props, ['ref_1', 3]);
    });

    test('two params with same values should be equal', () {
      const p1 = UpdateQuantityParams(refId: 'ref_1', quantity: 2);
      const p2 = UpdateQuantityParams(refId: 'ref_1', quantity: 2);
      expect(p1, p2);
    });

    test('two params with different quantity should not be equal', () {
      const p1 = UpdateQuantityParams(refId: 'ref_1', quantity: 1);
      const p2 = UpdateQuantityParams(refId: 'ref_1', quantity: 2);
      expect(p1, isNot(p2));
    });
  });
}
