import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sprint1_project/features/bottom_screens/presentation/screens/home_screen.dart';

void main() {
  testWidgets('HomeScreen shows product sections', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('New Arrival'), findsOneWidget);
    expect(find.text('Our product'), findsOneWidget);
    expect(find.text('Full Roses'), findsOneWidget);
    expect(find.text('Pink Bouquet'), findsOneWidget);
  });
}
