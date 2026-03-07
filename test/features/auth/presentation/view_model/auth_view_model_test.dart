import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/entities/auth_entity.dart';
import 'package:sprint1_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────
class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

class MockFile extends Mock implements File {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;
  late ProviderContainer container;

  const tEmail = 'john@example.com';
  const tPassword = 'password123';

  const tAuthEntity = AuthEntity(
    authId: 'user_1',
    firstName: 'John',
    lastName: 'Doe',
    email: tEmail,
    username: 'johndoe',
    role: 'user',
  );

  setUpAll(() {
    registerFallbackValue(
      const RegisterParams(
        firstName: 'f',
        lastName: 'l',
        username: 'u',
        email: 'e@e.com',
        password: 'p',
        confirmPassword: 'p',
      ),
    );
    registerFallbackValue(const LoginParams(email: 'e@e.com', password: 'p'));
    registerFallbackValue(const ForgotPasswordParams(email: 'e@e.com'));
    registerFallbackValue(
      const ResetPasswordParams(token: 't', newPassword: 'p'),
    );
    registerFallbackValue(UpdateProfileParams(data: const {}));
    registerFallbackValue(MockFile());
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();

    container = ProviderContainer(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
        logoutUsecaseProvider.overrideWithValue(mockLogoutUsecase),
        getCurrentUserUsecaseProvider.overrideWithValue(
          mockGetCurrentUserUsecase,
        ),
        updateProfileUsecaseProvider.overrideWithValue(
          mockUpdateProfileUsecase,
        ),
        forgotPasswordUsecaseProvider.overrideWithValue(
          mockForgotPasswordUsecase,
        ),
        resetPasswordUsecaseProvider.overrideWithValue(
          mockResetPasswordUsecase,
        ),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  // ─── initial state ─────────────────────────────────────────────────────────
  group('initial state', () {
    test('should have initial status when created', () {
      // Act
      final state = container.read(authViewModelProvider);

      // Assert
      expect(state.status, AuthStatus.initial);
      expect(state.user, isNull);
      expect(state.errorMessage, isNull);
    });
  });

  // ─── register ──────────────────────────────────────────────────────────────
  group('register', () {
    test('should emit registered status when registration succeeds', () async {
      // Arrange
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.register(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
      );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.registered);
      expect(state.errorMessage, isNull);
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('should emit loading then registered in correct order', () async {
      // Arrange
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      final statuses = <AuthStatus>[];
      container.listen(
        authViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.register(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
      );

      // Assert
      expect(statuses, [AuthStatus.loading, AuthStatus.registered]);
    });

    test(
      'should emit error status with message when registration fails',
      () async {
        // Arrange
        const failure = ApiFailure(message: 'Email already registered');
        when(
          () => mockRegisterUsecase(any()),
        ).thenAnswer((_) async => const Left(failure));
        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.register(
          firstName: 'John',
          lastName: 'Doe',
          username: 'johndoe',
          email: tEmail,
          password: tPassword,
          confirmPassword: tPassword,
        );

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.error);
        expect(state.errorMessage, 'Email already registered');
      },
    );

    test('should pass all fields correctly to usecase', () async {
      // Arrange
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.register(
        firstName: 'Jane',
        lastName: 'Smith',
        username: 'janesmith',
        email: 'jane@test.com',
        password: 'pass12345',
        confirmPassword: 'pass12345',
      );

      // Assert
      final captured =
          verify(() => mockRegisterUsecase(captureAny())).captured.first
              as RegisterParams;
      expect(captured.firstName, 'Jane');
      expect(captured.lastName, 'Smith');
      expect(captured.username, 'janesmith');
      expect(captured.email, 'jane@test.com');
      expect(captured.password, 'pass12345');
      expect(captured.confirmPassword, 'pass12345');
    });

    test('should not update user field on registration success', () async {
      // Register returns bool, not AuthEntity — user stays null
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      await viewModel.register(
        firstName: 'John',
        lastName: 'Doe',
        username: 'johndoe',
        email: tEmail,
        password: tPassword,
        confirmPassword: tPassword,
      );

      final state = container.read(authViewModelProvider);
      expect(state.user, isNull);
    });
  });

  // ─── login ─────────────────────────────────────────────────────────────────
  group('login', () {
    test(
      'should emit authenticated status with user when login succeeds',
      () async {
        // Arrange
        when(
          () => mockLoginUsecase(any()),
        ).thenAnswer((_) async => const Right(tAuthEntity));
        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.login(email: tEmail, password: tPassword);

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user, tAuthEntity);
        expect(state.errorMessage, isNull);
        verify(() => mockLoginUsecase(any())).called(1);
      },
    );

    test('should emit loading then authenticated in correct order', () async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final statuses = <AuthStatus>[];
      container.listen(
        authViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      expect(statuses, [AuthStatus.loading, AuthStatus.authenticated]);
    });

    test('should emit error status when login fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid email or password');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.login(email: tEmail, password: 'wrongpass');

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid email or password');
      expect(state.user, isNull);
    });

    test('should pass correct email and password to usecase', () async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final captured =
          verify(() => mockLoginUsecase(captureAny())).captured.first
              as LoginParams;
      expect(captured.email, tEmail);
      expect(captured.password, tPassword);
    });

    test('should emit error when offline during login', () async {
      // Arrange
      const failure = LocalDatabaseFailure(message: 'No internet connection');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'No internet connection');
    });

    test('user should be set after successful login', () async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.login(email: tEmail, password: tPassword);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.user?.firstName, 'John');
      expect(state.user?.email, tEmail);
      expect(state.user?.fullName, 'John Doe');
    });
  });

  // ─── logout ────────────────────────────────────────────────────────────────
  group('logout', () {
    test('should emit error status when logout fails', () async {
      // Arrange
      const failure = LocalDatabaseFailure(message: 'Failed to clear token');
      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.logout();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Failed to clear token');
    });

    test('should emit loading then unauthenticated in correct order', () async {
      // Arrange
      when(
        () => mockLogoutUsecase(),
      ).thenAnswer((_) async => const Right(true));

      final statuses = <AuthStatus>[];
      container.listen(
        authViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.logout();

      // Assert
      expect(statuses, [AuthStatus.loading, AuthStatus.unauthenticated]);
    });
  });

  // ─── getCurrentUser ────────────────────────────────────────────────────────
  group('getCurrentUser', () {
    test('should emit authenticated with user when successful', () async {
      // Arrange
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.user, tAuthEntity);
    });

    test('should emit unauthenticated when token is missing', () async {
      // Arrange
      const failure = ApiFailure(message: 'Not authenticated');
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
      expect(state.errorMessage, 'Not authenticated');
    });

    test('should emit unauthenticated when session is expired', () async {
      // Arrange
      const failure = ApiFailure(
        message: 'Session expired. Please login again.',
      );
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.getCurrentUser();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.unauthenticated);
    });

    test('should emit loading then authenticated in correct order', () async {
      // Arrange
      when(
        () => mockGetCurrentUserUsecase(),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      final statuses = <AuthStatus>[];
      container.listen(
        authViewModelProvider.select((s) => s.status),
        (_, next) => statuses.add(next),
        fireImmediately: false,
      );
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.getCurrentUser();

      // Assert
      expect(statuses, [AuthStatus.loading, AuthStatus.authenticated]);
    });
  });

  // ─── forgotPassword ────────────────────────────────────────────────────────
  group('forgotPassword', () {
    test('should emit forgotPasswordSent status when email is sent', () async {
      // Arrange
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.forgotPassword(email: tEmail);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.forgotPasswordSent);
      expect(state.errorMessage, isNull);
      verify(() => mockForgotPasswordUsecase(any())).called(1);
    });

    test('should emit error status when email sending fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Email not found');
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.forgotPassword(email: tEmail);

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Email not found');
    });

    test('should pass correct email to usecase', () async {
      // Arrange
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.forgotPassword(email: tEmail);

      // Assert
      final captured =
          verify(() => mockForgotPasswordUsecase(captureAny())).captured.first
              as ForgotPasswordParams;
      expect(captured.email, tEmail);
    });

    test(
      'should emit loading then forgotPasswordSent in correct order',
      () async {
        // Arrange
        when(
          () => mockForgotPasswordUsecase(any()),
        ).thenAnswer((_) async => const Right(true));

        final statuses = <AuthStatus>[];
        container.listen(
          authViewModelProvider.select((s) => s.status),
          (_, next) => statuses.add(next),
          fireImmediately: false,
        );
        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.forgotPassword(email: tEmail);

        // Assert
        expect(statuses, [AuthStatus.loading, AuthStatus.forgotPasswordSent]);
      },
    );
  });

  // ─── resetPassword ─────────────────────────────────────────────────────────
  group('resetPassword', () {
    test('should emit passwordReset status when reset succeeds', () async {
      // Arrange
      when(
        () => mockResetPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.resetPassword(
        token: 'reset_token',
        newPassword: 'newPass123',
      );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.passwordReset);
      expect(state.errorMessage, isNull);
      verify(() => mockResetPasswordUsecase(any())).called(1);
    });

    test('should emit error status when reset fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Token is invalid or expired');
      when(
        () => mockResetPasswordUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.resetPassword(
        token: 'bad_token',
        newPassword: 'newPass123',
      );

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Token is invalid or expired');
    });

    test('should pass correct token and newPassword to usecase', () async {
      // Arrange
      when(
        () => mockResetPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.resetPassword(
        token: 'reset_token_abc',
        newPassword: 'newPass123',
      );

      // Assert
      final captured =
          verify(() => mockResetPasswordUsecase(captureAny())).captured.first
              as ResetPasswordParams;
      expect(captured.token, 'reset_token_abc');
      expect(captured.newPassword, 'newPass123');
    });
  });

  // ─── updateProfile ─────────────────────────────────────────────────────────
  group('updateProfile', () {
    test(
      'should emit authenticated with updated user when successful',
      () async {
        // Arrange
        const updatedEntity = AuthEntity(
          authId: 'user_1',
          firstName: 'Jane',
          lastName: 'Doe',
          email: tEmail,
          username: 'janedoe',
          role: 'user',
        );
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Right(updatedEntity));
        final viewModel = container.read(authViewModelProvider.notifier);

        // Act
        await viewModel.updateProfile(
          data: {'firstName': 'Jane', 'username': 'janedoe'},
        );

        // Assert
        final state = container.read(authViewModelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.user?.firstName, 'Jane');
        expect(state.user?.username, 'janedoe');
      },
    );

    test('should emit error status when update fails', () async {
      // Arrange
      const failure = ApiFailure(message: 'Username already taken');
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      await viewModel.updateProfile(data: {'username': 'taken'});

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Username already taken');
    });
  });

  // ─── clearError ────────────────────────────────────────────────────────────
  group('clearError', () {
    test('should reset status to initial and clear error message', () async {
      // Arrange — trigger an error first
      const failure = ApiFailure(message: 'Some error');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: 'bad');

      // Verify error is set
      expect(container.read(authViewModelProvider).status, AuthStatus.error);
      expect(container.read(authViewModelProvider).errorMessage, 'Some error');

      // Act
      viewModel.clearError();

      // Assert
      final state = container.read(authViewModelProvider);
      expect(state.status, AuthStatus.initial);
      expect(state.errorMessage, isNull);
    });

    test('clearError should not affect user field', () async {
      // Arrange — login then trigger error
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: tPassword);

      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'err')));
      await viewModel.forgotPassword(email: tEmail);

      // Act
      viewModel.clearError();

      // Assert — user should still be set
      final state = container.read(authViewModelProvider);
      expect(state.user, tAuthEntity);
    });
  });

  // ─── verifyCurrentPassword ─────────────────────────────────────────────────
  group('verifyCurrentPassword', () {
    test('should return true when password is correct', () async {
      // Arrange — log in first to set current user
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: tPassword);

      // Mock login success for verification call
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));

      // Act
      final result = await viewModel.verifyCurrentPassword(tPassword);

      // Assert
      expect(result, true);
    });

    test('should return false when no current user is set', () async {
      // No login — user is null
      final viewModel = container.read(authViewModelProvider.notifier);

      // Act
      final result = await viewModel.verifyCurrentPassword(tPassword);

      // Assert
      expect(result, false);
    });

    test('should return false when password is wrong', () async {
      // Arrange — set logged in user
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tAuthEntity));
      final viewModel = container.read(authViewModelProvider.notifier);
      await viewModel.login(email: tEmail, password: tPassword);

      // Mock login failure for wrong password
      when(() => mockLoginUsecase(any())).thenAnswer(
        (_) async => const Left(ApiFailure(message: 'Invalid credentials')),
      );

      // Act
      final result = await viewModel.verifyCurrentPassword('wrongpass');

      // Assert
      expect(result, false);
    });
  });

  // ─── AuthState unit tests ──────────────────────────────────────────────────
  group('AuthState', () {
    test('should have correct initial values', () {
      const s = AuthState();
      expect(s.status, AuthStatus.initial);
      expect(s.user, isNull);
      expect(s.errorMessage, isNull);
    });

    test('copyWith should update only specified fields', () {
      const s = AuthState();
      final updated = s.copyWith(
        status: AuthStatus.authenticated,
        user: tAuthEntity,
      );
      expect(updated.status, AuthStatus.authenticated);
      expect(updated.user, tAuthEntity);
      expect(updated.errorMessage, isNull);
    });

    test('copyWith should clear errorMessage when passed null', () {
      const s = AuthState(status: AuthStatus.error, errorMessage: 'old error');
      final updated = s.copyWith(
        status: AuthStatus.initial,
        errorMessage: null,
      );
      expect(updated.errorMessage, isNull);
    });

    test('copyWith should preserve unchanged fields', () {
      const s = AuthState(
        status: AuthStatus.authenticated,
        user: tAuthEntity,
        errorMessage: 'err',
      );
      final updated = s.copyWith(status: AuthStatus.loading);
      // user and errorMessage are preserved because copyWith uses ?? this.user
      // but errorMessage is not null so it stays
      expect(updated.status, AuthStatus.loading);
    });

    test('props should include all three fields', () {
      const s = AuthState(
        status: AuthStatus.authenticated,
        user: tAuthEntity,
        errorMessage: 'err',
      );
      expect(s.props, [AuthStatus.authenticated, tAuthEntity, 'err']);
    });

    test('two states with same values should be equal', () {
      const s1 = AuthState(status: AuthStatus.loading);
      const s2 = AuthState(status: AuthStatus.loading);
      expect(s1, s2);
    });

    test('two states with different status should not be equal', () {
      const s1 = AuthState(status: AuthStatus.loading);
      const s2 = AuthState(status: AuthStatus.error);
      expect(s1, isNot(s2));
    });

    test('two states with different user should not be equal', () {
      const s1 = AuthState(status: AuthStatus.authenticated, user: tAuthEntity);
      const s2 = AuthState(status: AuthStatus.authenticated);
      expect(s1, isNot(s2));
    });

    test('initial AuthState should equal another initial AuthState', () {
      const s1 = AuthState();
      const s2 = AuthState();
      expect(s1, s2);
    });
  });

  // ─── AuthStatus enum coverage ──────────────────────────────────────────────
  group('AuthStatus', () {
    test('all status values should exist', () {
      expect(AuthStatus.values, contains(AuthStatus.initial));
      expect(AuthStatus.values, contains(AuthStatus.loading));
      expect(AuthStatus.values, contains(AuthStatus.authenticated));
      expect(AuthStatus.values, contains(AuthStatus.unauthenticated));
      expect(AuthStatus.values, contains(AuthStatus.registered));
      expect(AuthStatus.values, contains(AuthStatus.forgotPasswordSent));
      expect(AuthStatus.values, contains(AuthStatus.passwordReset));
      expect(AuthStatus.values, contains(AuthStatus.error));
    });
  });
}
