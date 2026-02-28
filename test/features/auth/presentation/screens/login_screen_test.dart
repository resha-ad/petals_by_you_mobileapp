import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/features/auth/presentation/screens/login_screen.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        // Correct Riverpod 3.x syntax: no ref parameter
        authViewModelProvider.overrideWith(() => mockViewModel),
      ],
      child: const MaterialApp(home: LoginScreen()),
    );
  }

  group('LoginScreen UI Elements', () {
    testWidgets('should display welcome text and sign in prompt', (
      tester,
    ) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Sign in to continue'), findsOneWidget);
    });

    testWidgets('should display email and password fields', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display Login button', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      when(
        () => mockViewModel.state,
      ).thenReturn(const AuthState(status: AuthStatus.loading));
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('LoginScreen Form Submission', () {
    testWidgets('should call login when form is valid', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());

      await tester.pumpWidget(createTestWidget());

      await tester.enterText(
        find.byType(TextFormField).first,
        'test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).last, 'password123');

      await tester.tap(find.text('Login'));
      await tester.pump();

      verify(
        () => mockViewModel.login(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);
    });
  });
}
