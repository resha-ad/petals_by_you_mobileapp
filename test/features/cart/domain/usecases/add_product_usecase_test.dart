import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/usecases/add_product_usecase.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late AddProductUsecase usecase;
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
    registerFallbackValue(const AddProductParams(itemId: 'fallback'));
  });

  setUp(() {
    mockRepo = MockCartRepository();
    usecase = AddProductUsecase(mockRepo);
  });

  group('AddProductUsecase', () {
    test('should return updated CartEntity on success', () async {
      when(
        () => mockRepo.addProduct(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      final result = await usecase(
        const AddProductParams(itemId: 'item_1', quantity: 2),
      );

      expect(result, const Right(tCart));
    });

    test('should pass correct itemId and quantity to repository', () async {
      when(
        () => mockRepo.addProduct(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      await usecase(const AddProductParams(itemId: 'item_abc', quantity: 3));

      verify(
        () => mockRepo.addProduct(itemId: 'item_abc', quantity: 3),
      ).called(1);
    });

    test('should use default quantity of 1 when not specified', () async {
      when(
        () => mockRepo.addProduct(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Right(tCart));

      await usecase(const AddProductParams(itemId: 'item_1'));

      final captured = verify(
        () => mockRepo.addProduct(
          itemId: captureAny(named: 'itemId'),
          quantity: captureAny(named: 'quantity'),
        ),
      ).captured;
      expect(captured[1], 1);
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to add items to cart.',
      );
      when(
        () => mockRepo.addProduct(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(const AddProductParams(itemId: 'item_1'));

      result.fold(
        (f) => expect(f.message, contains('offline')),
        (_) => fail('Should be Left'),
      );
    });

    test('should return ApiFailure when item not found', () async {
      const failure = ApiFailure(message: 'Item not found', statusCode: 404);
      when(
        () => mockRepo.addProduct(
          itemId: any(named: 'itemId'),
          quantity: any(named: 'quantity'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(const AddProductParams(itemId: 'bad_item'));

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 404);
      }, (_) => fail('Should be Left'));
    });
  });

  group('AddProductParams', () {
    test('should have correct props', () {
      const p = AddProductParams(itemId: 'abc', quantity: 2);
      expect(p.props, ['abc', 2]);
    });

    test('two params with same values should be equal', () {
      const p1 = AddProductParams(itemId: 'abc', quantity: 1);
      const p2 = AddProductParams(itemId: 'abc', quantity: 1);
      expect(p1, p2);
    });

    test('two params with different itemId should not be equal', () {
      const p1 = AddProductParams(itemId: 'abc');
      const p2 = AddProductParams(itemId: 'xyz');
      expect(p1, isNot(p2));
    });
  });
}
