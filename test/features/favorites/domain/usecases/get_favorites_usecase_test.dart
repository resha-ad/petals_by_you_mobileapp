import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/get_favorites_usecase.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late GetFavoritesUsecase usecase;
  late MockFavoritesRepository mockRepo;

  const tFavoriteItem = FavoriteEntity(type: 'product', refId: 'ref_1');
  const tFavorites = FavoritesEntity(userId: 'user_1', items: [tFavoriteItem]);
  const tEmptyFavorites = FavoritesEntity(userId: 'user_1', items: []);

  setUpAll(() {
    registerFallbackValue(tEmptyFavorites);
  });

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = GetFavoritesUsecase(mockRepo);
  });

  group('GetFavoritesUsecase', () {
    test('should return FavoritesEntity on success', () async {
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      final result = await usecase();

      expect(result, const Right(tFavorites));
      verify(() => mockRepo.getFavorites()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test(
      'should return empty FavoritesEntity when user has no favourites',
      () async {
        when(
          () => mockRepo.getFavorites(),
        ).thenAnswer((_) async => const Right(tEmptyFavorites));

        final result = await usecase();

        result.fold(
          (_) => fail('Should be Right'),
          (favs) => expect(favs.items, isEmpty),
        );
      },
    );

    test('should return ApiFailure when server fails', () async {
      const failure = ApiFailure(message: 'Failed to fetch favourites');
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      expect(result, const Left(failure));
    });

    test('should return ApiFailure when offline with no cache', () async {
      const failure = ApiFailure(message: 'Network error');
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase();

      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.getFavorites(),
      ).thenAnswer((_) async => const Right(tFavorites));

      await usecase();

      verify(() => mockRepo.getFavorites()).called(1);
    });
  });
}
