import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late RegisterUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = RegisterUsecase(authRepository: mockRepository);
  });

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(
        firstName: 'fallback',
        lastName: 'fallback',
        email: 'fallback@test.com',
        username: 'fallback',
      ),
    );
  });

  const tParams = RegisterParams(
    firstName: 'John',
    lastName: 'Doe',
    username: 'johndoe',
    email: 'john@example.com',
    password: 'password123',
    confirmPassword: 'password123',
  );

  group('RegisterUsecase', () {
    test('should return true when registration is successful', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.register(any())).called(1);
    });

    test('should return ApiFailure when email already exists', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email already exists');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.register(any())).called(1);
    });

    test('should return ApiFailure when there is no internet', () async {
      // Arrange
      const failure = ApiFailure(message: 'No internet connection');
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ApiFailure>()),
        (_) => fail('Should return failure'),
      );
    });

    test('should return ApiFailure when server returns 500', () async {
      // Arrange
      const failure = ApiFailure(
        message: 'Internal server error',
        statusCode: 500,
      );
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      result.fold((f) {
        expect(f, isA<ApiFailure>());
        expect((f as ApiFailure).statusCode, 500);
      }, (_) => fail('Should return failure'));
    });

    test('should pass correct entity fields to repository', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(tParams);

      // Assert
      final captured =
          verify(() => mockRepository.register(captureAny())).captured.first
              as AuthEntity;
      expect(captured.firstName, 'John');
      expect(captured.lastName, 'Doe');
      expect(captured.username, 'johndoe');
      expect(captured.email, 'john@example.com');
      expect(captured.password, 'password123');
    });

    test('should call repository exactly once', () async {
      // Arrange
      when(
        () => mockRepository.register(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(tParams);

      // Assert
      verify(() => mockRepository.register(any())).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test(
      'entity passed to repo should not include confirmPassword as field',
      () async {
        // Arrange
        when(
          () => mockRepository.register(any()),
        ).thenAnswer((_) async => const Right(true));

        // Act
        await usecase(tParams);

        // Assert — AuthEntity has no confirmPassword; only password is forwarded
        final captured =
            verify(() => mockRepository.register(captureAny())).captured.first
                as AuthEntity;
        // props length = [authId, firstName, lastName, email, username, phone,
        //                  imageUrl, role] — 8 fields, no confirmPassword
        expect(captured.props.length, 8);
      },
    );
  });

  group('RegisterParams', () {
    test('should have correct props', () {
      expect(tParams.props, [
        'John',
        'Doe',
        'johndoe',
        'john@example.com',
        'password123',
        'password123',
      ]);
    });

    test('two params with same values should be equal', () {
      const p1 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: 'john@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      const p2 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: 'john@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      expect(p1, p2);
    });

    test('two params with different email should not be equal', () {
      const p1 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: 'john@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      const p2 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: 'other@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      expect(p1, isNot(p2));
    });

    test('two params with different username should not be equal', () {
      const p1 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: 'john@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      const p2 = RegisterParams(
        firstName: 'John',
        lastName: 'Doe',
        username: 'janedoe',
        email: 'john@example.com',
        password: 'password123',
        confirmPassword: 'password123',
      );
      expect(p1, isNot(p2));
    });
  });
}
