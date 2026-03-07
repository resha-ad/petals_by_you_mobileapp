import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/entities/custom_bouquet_entity.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/repositories/custom_bouquet_repository.dart';
import 'package:sprint1_project/features/custom_bouquet/domain/usecases/create_custom_bouquet_usecase.dart';

class MockCustomBouquetRepository extends Mock
    implements ICustomBouquetRepository {}

void main() {
  late CreateCustomBouquetUsecase usecase;
  late MockCustomBouquetRepository mockRepo;

  const tRose = BouquetFlower(
    flowerId: 'rose',
    name: 'Rose',
    count: 5,
    pricePerStem: 120,
  );
  const tWrapping = BouquetWrapping(
    id: 'kraft',
    name: 'Kraft Paper',
    price: 50,
    color: '#EFE',
    darkColor: '#5D4',
  );
  const tBouquet = CustomBouquetEntity(
    flowers: [tRose],
    wrapping: tWrapping,
    note: 'With love',
    recipientName: 'Alice',
  );
  const tEmptyBouquet = CustomBouquetEntity();

  setUpAll(() {
    // CustomBouquetEntity is passed to any() — must be registered
    registerFallbackValue(tEmptyBouquet);
  });

  setUp(() {
    mockRepo = MockCustomBouquetRepository();
    usecase = CreateCustomBouquetUsecase(mockRepo);
  });

  group('CreateCustomBouquetUsecase', () {
    test('should return bouquet id String on success', () async {
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Right('bouquet_id_123'));

      final result = await usecase(tBouquet);

      expect(result, const Right('bouquet_id_123'));
    });

    test('should pass the bouquet entity to repository unchanged', () async {
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Right('id_abc'));

      await usecase(tBouquet);

      final captured =
          verify(() => mockRepo.createAndAddToCart(captureAny())).captured.first
              as CustomBouquetEntity;
      expect(captured.flowers.length, 1);
      expect(captured.flowers.first.flowerId, 'rose');
      expect(captured.wrapping?.id, 'kraft');
      expect(captured.note, 'With love');
      expect(captured.recipientName, 'Alice');
    });

    test('should call repository exactly once', () async {
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Right('id_abc'));

      await usecase(tBouquet);

      verify(() => mockRepo.createAndAddToCart(any())).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('should return ApiFailure when offline', () async {
      const failure = ApiFailure(
        message: 'You\'re offline. Connect to build a bouquet.',
      );
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(tBouquet);

      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect(f.message, contains('offline'));
      }, (_) => fail('Should be Left'));
    });

    test('should return ApiFailure when server error occurs', () async {
      const failure = ApiFailure(message: 'Failed to create bouquet');
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Left(failure));

      final result = await usecase(tEmptyBouquet);

      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should be Left'),
      );
    });

    test('should work with minimal (empty) bouquet', () async {
      when(
        () => mockRepo.createAndAddToCart(any()),
      ).thenAnswer((_) async => const Right('minimal_id'));

      final result = await usecase(tEmptyBouquet);

      expect(result.isRight(), true);
    });
  });
}
