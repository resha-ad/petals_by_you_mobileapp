import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/core/error/failures.dart';
import 'package:sprint1_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sprint1_project/features/auth/presentation/screens/forgot_password_screen.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockLogoutUsecase extends Mock implements LogoutUsecase {}

class MockGetCurrentUserUsecase extends Mock implements GetCurrentUserUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

class MockForgotPasswordUsecase extends Mock implements ForgotPasswordUsecase {}

class MockResetPasswordUsecase extends Mock implements ResetPasswordUsecase {}

void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;
  late MockLogoutUsecase mockLogoutUsecase;
  late MockGetCurrentUserUsecase mockGetCurrentUserUsecase;
  late MockUpdateProfileUsecase mockUpdateProfileUsecase;
  late MockForgotPasswordUsecase mockForgotPasswordUsecase;
  late MockResetPasswordUsecase mockResetPasswordUsecase;

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
    registerFallbackValue(UpdateProfileParams(data: {}));
  });

  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();
    mockLogoutUsecase = MockLogoutUsecase();
    mockGetCurrentUserUsecase = MockGetCurrentUserUsecase();
    mockUpdateProfileUsecase = MockUpdateProfileUsecase();
    mockForgotPasswordUsecase = MockForgotPasswordUsecase();
    mockResetPasswordUsecase = MockResetPasswordUsecase();
  });

  Widget createForgotPasswordScreen() {
    return ProviderScope(
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
      child: const MaterialApp(home: ForgotPasswordScreen()),
    );
  }

  // ─── UI Elements ─────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - UI Elements', () {
    testWidgets('should display scaffold', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display Forgot Password title', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should display instruction description text', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.textContaining("Enter the email associated"), findsOneWidget);
    });

    testWidgets('should display Email label', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display one TextFormField', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should display Send Reset Link button', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.text('Send Reset Link'), findsOneWidget);
    });

    testWidgets('should display lock_reset icon', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('should display back arrow in app bar', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
    });
  });

  // ─── Text Entry ───────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - Text Entry', () {
    testWidgets('should allow entering email', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });
  });

  // ─── Validation ───────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - Validation', () {
    testWidgets('should show email required error when submitted empty', (
      tester,
    ) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show invalid email error for bad format', (
      tester,
    ) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'notanemail');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
    });

    testWidgets('should not show error when email is valid', (tester) async {
      // Arrange
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'err')));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Enter a valid email'), findsNothing);
    });
  });

  // ─── Submit Action ────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - Submit Action', () {
    testWidgets('should call forgotPassword usecase with correct email', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'err')));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      final captured =
          verify(() => mockForgotPasswordUsecase(captureAny())).captured.first
              as ForgotPasswordParams;
      expect(captured.email, 'test@example.com');
    });

    testWidgets('should not call usecase when form is invalid', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      verifyNever(() => mockForgotPasswordUsecase(any()));
    });

    testWidgets('should show loading indicator during request', (tester) async {
      when(() => mockForgotPasswordUsecase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return const Left(ApiFailure(message: 'err'));
      });

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });

  // ─── Success State ────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - Success State', () {
    testWidgets('should show success view after email is sent', (tester) async {
      // Arrange
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Assert — success view is shown
      expect(find.text('Check Your Email'), findsOneWidget);
      expect(find.byIcon(Icons.mark_email_read_outlined), findsOneWidget);
    });

    testWidgets('should show Back to Sign In button on success', (
      tester,
    ) async {
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.text('Back to Sign In'), findsOneWidget);
    });

    testWidgets('should show sent email in success message', (tester) async {
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      expect(find.textContaining('test@example.com'), findsOneWidget);
    });

    testWidgets('should hide email form on success', (tester) async {
      when(
        () => mockForgotPasswordUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField), 'test@example.com');
      await tester.tap(find.text('Send Reset Link'));
      await tester.pumpAndSettle();

      // Form is gone, no TextFormField visible
      expect(find.byType(TextFormField), findsNothing);
      expect(find.text('Send Reset Link'), findsNothing);
    });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────
  group('ForgotPasswordScreen - Navigation', () {
    testWidgets('back arrow button should be tappable', (tester) async {
      await tester.pumpWidget(createForgotPasswordScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Should pop without error — no crash
    });
  });
}
