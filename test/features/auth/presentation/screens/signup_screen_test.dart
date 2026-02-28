import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/features/auth/presentation/screens/signup_screen.dart';
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
      overrides: [authViewModelProvider.overrideWith(() => mockViewModel)],
      child: const MaterialApp(home: SignupScreen()),
    );
  }

  group('SignupScreen UI Elements', () {
    testWidgets('should display create account title', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('should display 4 text fields', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsNWidgets(4));
    });

    testWidgets('should display Sign Up button', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign Up'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}
