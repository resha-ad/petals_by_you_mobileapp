import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/favorites/domain/entities/favorite_entity.dart';
import 'package:sprint1_project/features/favorites/domain/repositories/favorites_repository.dart';
import 'package:sprint1_project/features/favorites/domain/usecases/remove_favorite_usecase.dart';

class MockFavoritesRepository extends Mock implements IFavoritesRepository {}

void main() {
  late RemoveFavoriteUsecase usecase;
  late MockFavoritesRepository mockRepo;

  const tEmptyFavorites = FavoritesEntity(userId: 'user_1', items: []);

  setUpAll(() {
    registerFallbackValue(tEmptyFavorites);
  });

  setUp(() {
    mockRepo = MockFavoritesRepository();
    usecase = RemoveFavoriteUsecase(mockRepo);
  });

  group('RemoveFavoriteUsecase', () {
    test('should return updated FavoritesEntity on success', () async {
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      final result = await usecase('ref_1');

      expect(result, const Right(tEmptyFavorites));
    });

    test('should pass correct refId to repository', () async {
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      await usecase('ref_abc');

      final captured =
          verify(() => mockRepo.removeFavorite(captureAny())).captured.first
              as String;
      expect(captured, 'ref_abc');
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      await usecase('ref_1');

      verify(() => mockRepo.removeFavorite('ref_1')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return empty items list after removal', () async {
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Right(tEmptyFavorites));

      final result = await usecase('ref_1');

      result.fold(
        (_) => fail('Should be Right'),
        (favs) => expect(favs.items, isEmpty),
      );
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to remove favourites.',
      );
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase('ref_1');

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect(f.message, contains('offline'));
      }, (_) => fail('Should be Left'));
    });

    test('should return ApiFailure when item not found', () async {
      const failure = ApiFailure(
        message: 'Favourite not found',
        statusCode: 404,
      );
      when(
        () => mockRepo.removeFavorite(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase('ref_999');

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 404);
      }, (_) => fail('Should be Left'));
    });
  });
}
