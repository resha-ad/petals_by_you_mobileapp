import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/cart/domain/entities/cart_entity.dart';
import 'package:sprint1_project/features/cart/domain/repositories/cart_repository.dart';
import 'package:sprint1_project/features/cart/domain/usecases/remove_cart_item_usecase.dart';

class MockCartRepository extends Mock implements ICartRepository {}

void main() {
  late RemoveCartItemUsecase usecase;
  late MockCartRepository mockRepo;

  const tEmptyCart = CartEntity(userId: 'user_1', items: [], total: 0);

  setUpAll(() {
    registerFallbackValue(tEmptyCart);
  });

  setUp(() {
    mockRepo = MockCartRepository();
    usecase = RemoveCartItemUsecase(mockRepo);
  });

  group('RemoveCartItemUsecase', () {
    test('should return updated CartEntity on success', () async {
      when(
        () => mockRepo.removeItem(any()),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      final result = await usecase('ref_1');

      expect(result, const Right(tEmptyCart));
    });

    test('should pass correct refId to repository', () async {
      when(
        () => mockRepo.removeItem(any()),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await usecase('ref_abc');

      final captured =
          verify(() => mockRepo.removeItem(captureAny())).captured.first
              as String;
      expect(captured, 'ref_abc');
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.removeItem(any()),
      ).thenAnswer((_) async => const Right(tEmptyCart));

      await usecase('ref_1');

      verify(() => mockRepo.removeItem('ref_1')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return ApiFailure when removal fails', () async {
      const failure = ApiFailure(message: 'Item not found in cart');
      when(
        () => mockRepo.removeItem(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase('ref_1');

      result.fold(
        (f) => expect(f.message, 'Item not found in cart'),
        (_) => fail('Should be Left'),
      );
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to update cart.',
      );
      when(
        () => mockRepo.removeItem(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase('ref_1');

      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });
}
