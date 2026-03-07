import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late GetCurrentUserUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = GetCurrentUserUsecase(authRepository: mockRepository);
  });

  const tAuthEntity = AuthEntity(
    authId: 'user_1',
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com',
    username: 'johndoe',
    role: 'user',
  );

  group('GetCurrentUserUsecase', () {
    test('should return AuthEntity when user is authenticated', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when not authenticated', () async {
      // Arrange
      const failure = ApiFailure(message: 'Not authenticated');
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should return ApiFailure when session has expired', () async {
      // Arrange
      const failure = ApiFailure(
        message: 'Session expired. Please login again.',
      );
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f.message, contains('Session expired')),
        (_) => fail('Should return failure'),
      );
    });

    test(
      'should return LocalDatabaseFailure when offline and no cache',
      () async {
        // Arrange
        const failure = LocalDatabaseFailure(message: 'No internet connection');
        when(
          () => mockRepository.getCurrentUser(),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase();

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<LocalDatabaseFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test('should return correct user data fields', () async {
      // Arrange
      when(
        () => mockRepository.getCurrentUser(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase();

      // Assert
      result.fold((_) => fail('Should return user'), (user) {
        expect(user.authId, 'user_1');
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.email, 'john@example.com');
        expect(user.username, 'johndoe');
        expect(user.fullName, 'John Doe');
      });
    });
  });
}
