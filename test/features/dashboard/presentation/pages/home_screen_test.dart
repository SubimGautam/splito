import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/dashboard/presentation/pages/profile_screen.dart';

void main() {
 testWidgets('shows total balance header and action buttons', (tester) async {
  await tester.pumpWidget(
    const MaterialApp(home: HomeScreen()),
  );

  // Wait for initial render
  await tester.pumpAndSettle();

  // Check for expected text
  expect(find.text('Total Balance'), findsOneWidget);
  expect(find.text('\$750.00'), findsOneWidget);
  expect(find.text('Add Money'), findsOneWidget);
  expect(find.text('Send'), findsOneWidget);
});

testWidgets('switches to Groups tab and shows placeholder', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

  await tester.tap(find.byIcon(Icons.group_outlined));
  await tester.pumpAndSettle();

  // Your HomeScreen shows "Groups coming soon" placeholder
  expect(find.text('Groups coming soon'), findsOneWidget);
});

testWidgets('shows ProfileScreen when Account tab is selected', (tester) async {
  await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
  
  // Wait for initial render
  await tester.pumpAndSettle();
  
  // Tap account icon (3rd tab index)
  await tester.tap(find.byIcon(Icons.account_circle_outlined));
  await tester.pumpAndSettle();
  
  // ProfileScreen should be loaded
  expect(find.byType(ProfileScreen), findsOneWidget);
});
}