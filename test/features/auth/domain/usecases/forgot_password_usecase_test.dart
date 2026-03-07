import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/usecases/forgot_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ForgotPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ForgotPasswordUsecase(authRepository: mockRepository);
  });

  const tEmail = 'john@example.com';
  const tParams = ForgotPasswordParams(email: tEmail);

  group('ForgotPasswordUsecase', () {
    test('should return true when email is sent successfully', () async {
      // Arrange
      when(
        () => mockRepository.forgotPassword(tEmail),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(() => mockRepository.forgotPassword(tEmail)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when email not found', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email not found');
      when(
        () => mockRepository.forgotPassword(tEmail),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.forgotPassword(tEmail)).called(1);
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      const failure = ApiFailure(message: 'No internet connection');
      when(
        () => mockRepository.forgotPassword(tEmail),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should pass correct email to repository', () async {
      // Arrange
      when(
        () => mockRepository.forgotPassword(any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(tParams);

      // Assert
      final captured =
          verify(
                () => mockRepository.forgotPassword(captureAny()),
              ).captured.first
              as String;
      expect(captured, tEmail);
    });
  });

  group('ForgotPasswordParams', () {
    test('should have correct props', () {
      expect(tParams.props, [tEmail]);
    });

    test('two params with same email should be equal', () {
      const p1 = ForgotPasswordParams(email: tEmail);
      const p2 = ForgotPasswordParams(email: tEmail);
      expect(p1, p2);
    });

    test('two params with different email should not be equal', () {
      const p1 = ForgotPasswordParams(email: tEmail);
      const p2 = ForgotPasswordParams(email: 'other@example.com');
      expect(p1, isNot(p2));
    });
  });
}
