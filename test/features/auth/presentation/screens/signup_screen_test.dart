import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/features/auth/domain/usecases/forgot_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/login_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/logout_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/register_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/reset_password_usecase.dart';
import 'package:sprint1_project/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:sprint1_project/features/auth/presentation/screens/signup_screen.dart';

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

  Widget createSignupScreen() {
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
      child: const MaterialApp(home: SignupScreen()),
    );
  }

  // ─── UI Elements ─────────────────────────────────────────────────────────
  group('SignupScreen - UI Elements', () {
    testWidgets('should display scaffold', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should display Join Petals By You subtitle', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Join Petals By You today'), findsOneWidget);
    });

    testWidgets('should display First Name label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('First Name'), findsOneWidget);
    });

    testWidgets('should display Last Name label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Last Name'), findsOneWidget);
    });

    testWidgets('should display Username label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Username'), findsOneWidget);
    });

    testWidgets('should display Email label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('should display Password label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display Confirm Password label', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Confirm Password'), findsOneWidget);
    });

    testWidgets('should display 6 TextFormFields', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      // firstName, lastName, username, email, password, confirmPassword
      expect(find.byType(TextFormField), findsNWidgets(6));
    });

    testWidgets('should display Create Account button', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsWidgets);
    });

    testWidgets('should display Already have an account text', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Already have an account?'), findsOneWidget);
    });

    testWidgets('should display Sign In link', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.text('Sign In'), findsOneWidget);
    });

    testWidgets('should display local_florist icon', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.local_florist), findsOneWidget);
    });

    testWidgets('should have two password visibility icons', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.visibility_off_outlined), findsNWidgets(2));
    });
  });

  // ─── Text Entry ───────────────────────────────────────────────────────────
  group('SignupScreen - Text Entry', () {
    testWidgets('should allow entering first name', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John');
      await tester.pump();

      expect(find.text('John'), findsOneWidget);
    });

    testWidgets('should allow entering username', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(2), 'johndoe');
      await tester.pump();

      expect(find.text('johndoe'), findsOneWidget);
    });

    testWidgets('should allow entering email', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.pump();

      expect(find.text('john@example.com'), findsOneWidget);
    });
  });

  // ─── Password Visibility ─────────────────────────────────────────────────
  group('SignupScreen - Password Visibility', () {
    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      // Tap first visibility toggle (password field)
      await tester.tap(find.byIcon(Icons.visibility_off_outlined).first);
      await tester.pump();

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
    });
  });

  // ─── Register Action ─────────────────────────────────────────────────────
  group('SignupScreen - Register Action', () {
    Future<void> fillValidForm(WidgetTester tester) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'John');
      await tester.enterText(fields.at(1), 'Doe');
      await tester.enterText(fields.at(2), 'johndoe');
      await tester.enterText(fields.at(3), 'john@example.com');
      await tester.enterText(fields.at(4), 'password123');
      await tester.enterText(fields.at(5), 'password123');
    }

    testWidgets('should not call usecase when form is invalid', (tester) async {
      await tester.pumpWidget(createSignupScreen());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Account').last);
      await tester.pump();

      verifyNever(() => mockRegisterUsecase(any()));
    });
  });
}
