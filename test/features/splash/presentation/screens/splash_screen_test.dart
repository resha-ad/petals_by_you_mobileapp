import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/splash/presentation/screens/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows logo, title and button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Petals By You'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });
}
