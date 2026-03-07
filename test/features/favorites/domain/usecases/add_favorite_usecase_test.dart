import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/add_favorite_usecase.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late AddFavoriteUsecase usecase;
  late MockFavoritesRepository mockRepo;

  const tFavoriteItem = FavoriteEntity(type: 'product', refId: 'ref_1');
  const tFavorites = FavoritesEntity(userId: 'user_1', items: [tFavoriteItem]);
  const tEmptyFavorites = FavoritesEntity(userId: 'user_1', items: []);

  setUpAll(() {
    registerFallbackValue(tEmptyFavorites);
    registerFallbackValue(
      const AddFavoriteParams(type: 'product', refId: 'fallback'),
    );
  });

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = AddFavoriteUsecase(mockRepo);
  });

  group('AddFavoriteUsecase', () {
    test('should return updated FavoritesEntity on success', () async {
      when(
        () => mockRepo.addFavorite(
          type: any(named: 'type'),
          refId: any(named: 'refId'),
        ),
      ).thenAnswer((_) async => const Right(tFavorites));

      final result = await usecase(
        const AddFavoriteParams(type: 'product', refId: 'ref_1'),
      );

      expect(result, const Right(tFavorites));
    });

    test('should pass correct type and refId to repository', () async {
      when(
        () => mockRepo.addFavorite(
          type: any(named: 'type'),
          refId: any(named: 'refId'),
        ),
      ).thenAnswer((_) async => const Right(tFavorites));

      await usecase(
        const AddFavoriteParams(type: 'product', refId: 'item_abc'),
      );

      verify(
        () => mockRepo.addFavorite(type: 'product', refId: 'item_abc'),
      ).called(1);
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.addFavorite(
          type: any(named: 'type'),
          refId: any(named: 'refId'),
        ),
      ).thenAnswer((_) async => const Right(tFavorites));

      await usecase(const AddFavoriteParams(type: 'product', refId: 'ref_1'));

      verify(
        () => mockRepo.addFavorite(type: 'product', refId: 'ref_1'),
      ).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to add favourites.',
      );
      when(
        () => mockRepo.addFavorite(
          type: any(named: 'type'),
          refId: any(named: 'refId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const AddFavoriteParams(type: 'product', refId: 'ref_1'),
      );

      result.fold(
        (f) => expect(f.message, contains('offline')),
        (_) => fail('Should be Left'),
      );
    });

    test('should return ApiFailure when server error occurs', () async {
      const failure = ApiFailure(message: 'Failed to add favourite');
      when(
        () => mockRepo.addFavorite(
          type: any(named: 'type'),
          refId: any(named: 'refId'),
        ),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(
        const AddFavoriteParams(type: 'product', refId: 'ref_1'),
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });
  });

  group('AddFavoriteParams', () {
    test('should have correct props', () {
      const p = AddFavoriteParams(type: 'product', refId: 'ref_1');
      expect(p.props, ['product', 'ref_1']);
    });

    test('two params with same values should be equal', () {
      const p1 = AddFavoriteParams(type: 'product', refId: 'ref_1');
      const p2 = AddFavoriteParams(type: 'product', refId: 'ref_1');
      expect(p1, p2);
    });

    test('two params with different refId should not be equal', () {
      const p1 = AddFavoriteParams(type: 'product', refId: 'ref_1');
      const p2 = AddFavoriteParams(type: 'product', refId: 'ref_2');
      expect(p1, isNot(p2));
    });

    test('two params with different type should not be equal', () {
      const p1 = AddFavoriteParams(type: 'product', refId: 'ref_1');
      const p2 = AddFavoriteParams(type: 'custom', refId: 'ref_1');
      expect(p1, isNot(p2));
    });
  });
}
