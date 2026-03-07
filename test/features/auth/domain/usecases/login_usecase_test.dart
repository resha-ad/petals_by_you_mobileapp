import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tParams = LoginParams(email: tEmail, password: tPassword);

  const tAuthEntity = AuthEntity(
    authId: 'user_1',
    firstName: 'John',
    lastName: 'Doe',
    email: tEmail,
    username: 'johndoe',
    role: 'user',
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      // Arrange
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(tAuthEntity));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'should return ApiFailure when login fails with wrong credentials',
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Invalid email or password');
        when(
          () => mockRepository.login(tEmail, tPassword),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result, const Left(failure));
        verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      },
    );

    test(
      'should return LocalDatabaseFailure when offline and no cached user',
      () async {
        // Arrange
        const failure = LocalDatabaseFailure(message: 'No internet connection');
        when(
          () => mockRepository.login(tEmail, tPassword),
        ).thenAnswer((_) async => const Left(failure));

        // Act
        final result = await usecase(tParams);

        // Assert
        expect(result.isLeft(), true);
        result.fold(
          (f) => expect(f, isA<LocalDatabaseFailure>()),
          (_) => fail('Should return failure'),
        );
      },
    );

    test('should return ApiFailure when server returns error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Server error', statusCode: 500);
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold((f) {
        expect(f, isA<ApiFailure>());
        final apiF = f as ApiFailure;
        expect(apiF.statusCode, 500);
      }, (_) => fail('Should return failure'));
    });

    test('should pass correct email and password to repository', () async {
      // Arrange
      when(
        () => mockRepository.login(any(), any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      await usecase(tParams);

      // Assert
      final captured = verify(
        () => mockRepository.login(captureAny(), captureAny()),
      ).captured;
      expect(captured[0], tEmail);
      expect(captured[1], tPassword);
    });

    test('should return correct user data on successful login', () async {
      // Arrange
      when(
        () => mockRepository.login(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((_) => fail('Should return user'), (user) {
        expect(user.authId, 'user_1');
        expect(user.firstName, 'John');
        expect(user.lastName, 'Doe');
        expect(user.email, tEmail);
        expect(user.username, 'johndoe');
        expect(user.fullName, 'John Doe');
      });
    });
  });

  group('LoginParams', () {
    test('should have correct props', () {
      expect(tParams.props, [tEmail, tPassword]);
    });

    test('two params with same values should be equal', () {
      const p1 = LoginParams(email: tEmail, password: tPassword);
      const p2 = LoginParams(email: tEmail, password: tPassword);
      expect(p1, p2);
    });

    test('two params with different email should not be equal', () {
      const p1 = LoginParams(email: tEmail, password: tPassword);
      const p2 = LoginParams(email: 'other@test.com', password: tPassword);
      expect(p1, isNot(p2));
    });

    test('two params with different password should not be equal', () {
      const p1 = LoginParams(email: tEmail, password: tPassword);
      const p2 = LoginParams(email: tEmail, password: 'different');
      expect(p1, isNot(p2));
    });
  });
}
