import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sprint1_project/features/auth/presentation/state/auth_state.dart';
import 'package:sprint1_project/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/profile_screen.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

void main() {
  late MockAuthViewModel mockViewModel;

  setUp(() {
    mockViewModel = MockAuthViewModel();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [authViewModelProvider.overrideWith(() => mockViewModel)],
      child: const MaterialApp(home: ProfileScreen()),
    );
  }

  group('ProfileScreen UI Elements', () {
    testWidgets('should display My Profile title', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('My Profile'), findsOneWidget);
    });

    testWidgets('should show loading indicator when loading', (tester) async {
      when(
        () => mockViewModel.state,
      ).thenReturn(const AuthState(status: AuthStatus.loading));
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display Save Changes button', (tester) async {
      when(() => mockViewModel.state).thenReturn(const AuthState());
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Save Changes'), findsOneWidget);
    });
  });
}
