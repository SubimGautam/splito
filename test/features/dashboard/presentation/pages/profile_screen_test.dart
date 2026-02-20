import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Mock SharedPreferences before running tests
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('shows loading state initially', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen()), // Remove const here
    );

    // Initially shows loading
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading profile...'), findsOneWidget);
  });

  testWidgets('shows user info after loading', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: ProfileScreen()), // Remove const here
    );
    
    // Wait for loading to complete
    await tester.pumpAndSettle();
    
    // Shows default/placeholder user info
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });
}