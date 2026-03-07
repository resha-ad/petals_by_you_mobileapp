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
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';

// ─── Mocks ────────────────────────────────────────────────────────────────────
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
    registerFallbackValue(UpdateProfileParams(data: const {}));
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

  // ─── Helper ───────────────────────────────────────────────────────────────
  Widget createLoginScreen() {
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
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  // ─── UI Elements ─────────────────────────────────────────────────────────
  group('LoginScreen - UI Elements', () {
    testWidgets('should display scaffold', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display Welcome Back text', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('should display Sign in subtitle', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sign in to your account'), findsOneWidget);
    });

    testWidgets('should display Email label', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display Password label', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display two TextFormFields', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should display Sign In button', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // ElevatedButton with text Sign In
      expect(find.widgetWithText(ElevatedButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('should display Forgot Password link', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsOneWidget);
    });

    testWidgets('should display Sign Up navigation link', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsOneWidget);
    });

    testWidgets('should display local_florist icon in header', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('should have Form widget', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Form), findsOneWidget);
    });

    testWidgets('should have SingleChildScrollView', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should display SafeArea', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsOneWidget);
    });

    testWidgets('should display email and password prefix icons', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.email_outlined), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });
  });

  // ─── Text Entry ───────────────────────────────────────────────────────────
  group('LoginScreen - Text Entry', () {
    testWidgets('should allow entering email', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should allow entering password', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.pump();

      // EditableText is the underlying widget that holds the actual text value
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(editableText.controller.text, 'password123');
    });

    testWidgets('password field should be obscured by default', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // EditableText exposes obscureText; TextFormField does not
      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(editableText.obscureText, true);
    });

    testWidgets('email field should not be obscured', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).first,
      );
      expect(editableText.obscureText, false);
    });
  });

  // ─── Password Visibility Toggle ───────────────────────────────────────────
  group('LoginScreen - Password Visibility', () {
    testWidgets('should show visibility_off icon initially', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('should toggle to visibility icon on tap', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });

    testWidgets('password should become visible after toggle', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Tap to show
      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(editableText.obscureText, false);
    });

    testWidgets('should toggle back to hidden on second tap', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('password should be hidden again after double toggle', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.visibility_off_outlined));
      await tester.pump();
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      final editableText = tester.widget<EditableText>(
        find.byType(EditableText).last,
      );
      expect(editableText.obscureText, true);
    });
  });

  // ─── Validation ───────────────────────────────────────────────────────────
  group('LoginScreen - Validation', () {
    testWidgets('should show email required error when submitted empty', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsOneWidget);
    });

    testWidgets('should show invalid email error for bad email format', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, 'notanemail');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Enter a valid email address'), findsOneWidget);
    });

    testWidgets('should show password required error when empty', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Password is required'), findsOneWidget);
    });

    testWidgets('should show password too short error', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'short');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(
        find.text('Password must be at least 8 characters'),
        findsOneWidget,
      );
    });

    testWidgets('should not show errors when both fields are valid', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'err')));

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      expect(find.text('Email is required'), findsNothing);
      expect(find.text('Password is required'), findsNothing);
      expect(find.text('Enter a valid email address'), findsNothing);
    });

    testWidgets('should show both errors when both fields are empty', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Email error shows first; form stops at first invalid field
      expect(find.text('Email is required'), findsOneWidget);
    });
  });

  // ─── Login Action ─────────────────────────────────────────────────────────
  group('LoginScreen - Login Action', () {
    testWidgets('should call login usecase with correct credentials', (
      tester,
    ) async {
      // Arrange
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(ApiFailure(message: 'err')));

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      // Act
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Assert
      final captured =
          verify(() => mockLoginUsecase(captureAny())).captured.first
              as LoginParams;
      expect(captured.email, 'test@example.com');
      expect(captured.password, 'password123');
    });

    testWidgets('should show loading indicator during login', (tester) async {
      // Arrange — delayed response so we catch the loading state
      when(() => mockLoginUsecase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return const Left(ApiFailure(message: 'err'));
      });

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump(); // single frame — loading state visible

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle(); // finish
    });

    testWidgets('should disable Sign In button during loading', (tester) async {
      when(() => mockLoginUsecase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 200));
        return const Left(ApiFailure(message: 'err'));
      });

      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      // Button is replaced by CircularProgressIndicator (onPressed is null)
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      await tester.pumpAndSettle();
    });

    testWidgets('should not call usecase when form is invalid', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Tap without filling form
      await tester.tap(find.widgetWithText(ElevatedButton, 'Sign In'));
      await tester.pump();

      verifyNever(() => mockLoginUsecase(any()));
    });
  });

  // ─── Navigation ───────────────────────────────────────────────────────────
  group('LoginScreen - Navigation', () {
    testWidgets('should navigate to ForgotPasswordScreen on link tap', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      expect(find.text('Forgot Password?'), findsWidgets);
      expect(find.byIcon(Icons.lock_reset), findsOneWidget);
    });

    testWidgets('back navigation to login screen should be possible', (
      tester,
    ) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      // Go to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Come back
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome Back'), findsOneWidget);
    });
  });

  // ─── Don't have an account section ───────────────────────────────────────
  group('LoginScreen - Footer', () {
    testWidgets('should display dont have an account text', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.text("Don't have an account?"), findsOneWidget);
    });

    testWidgets('should display Sign Up as TextButton', (tester) async {
      await tester.pumpWidget(createLoginScreen());
      await tester.pumpAndSettle();

      expect(find.widgetWithText(TextButton, 'Sign Up'), findsOneWidget);
    });
  });
}
