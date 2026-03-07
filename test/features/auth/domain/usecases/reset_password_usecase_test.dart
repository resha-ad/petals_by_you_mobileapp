import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/repositories/auth_repository.dart';
import 'package:sprint1_project/features/auth/domain/usecases/reset_password_usecase.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late ResetPasswordUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = ResetPasswordUsecase(authRepository: mockRepository);
  });

  const tToken = 'reset_token_abc123';
  const tNewPassword = 'newPassword123';
  const tParams = ResetPasswordParams(token: tToken, newPassword: tNewPassword);

  group('ResetPasswordUsecase', () {
    test('should return true when password is reset successfully', () async {
      // Arrange
      when(
        () => mockRepository.resetPassword(tToken, tNewPassword),
      ).thenAnswer((_) async => const Right(true));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Right(true));
      verify(
        () => mockRepository.resetPassword(tToken, tNewPassword),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ApiFailure when token is invalid or expired', () async {
      // Arrange
      const failure = ApiFailure(message: 'Token is invalid or expired');
      when(
        () => mockRepository.resetPassword(tToken, tNewPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result, const Left(failure));
      verify(
        () => mockRepository.resetPassword(tToken, tNewPassword),
      ).called(1);
    });

    test('should return NetworkFailure when no internet', () async {
      // Arrange
      const failure = ApiFailure(message: 'No internet connection');
      when(
        () => mockRepository.resetPassword(tToken, tNewPassword),
      ).thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase(tParams);

      // Assert
      expect(result.isLeft(), true);
    });

    test('should pass correct token and new password to repository', () async {
      // Arrange
      when(
        () => mockRepository.resetPassword(any(), any()),
      ).thenAnswer((_) async => const Right(true));

      // Act
      await usecase(tParams);

      // Assert
      final captured = verify(
        () => mockRepository.resetPassword(captureAny(), captureAny()),
      ).captured;
      expect(captured[0], tToken);
      expect(captured[1], tNewPassword);
    });
  });

  group('ResetPasswordParams', () {
    test('should have correct props', () {
      expect(tParams.props, [tToken, tNewPassword]);
    });

    test('two params with same values should be equal', () {
      const p1 = ResetPasswordParams(token: tToken, newPassword: tNewPassword);
      const p2 = ResetPasswordParams(token: tToken, newPassword: tNewPassword);
      expect(p1, p2);
    });

    test('two params with different token should not be equal', () {
      const p1 = ResetPasswordParams(token: tToken, newPassword: tNewPassword);
      const p2 = ResetPasswordParams(
        token: 'other_token',
        newPassword: tNewPassword,
      );
      expect(p1, isNot(p2));
    });
  });
}
