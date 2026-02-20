import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/auth/presentation/pages/signup_page.dart'; // ← adjust path if needed
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';

void main() {
  testWidgets('shows title and all input fields', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    expect(find.text('Create account 🧑‍💻'), findsOneWidget);

    expect(find.byKey(const Key('username_field')), findsOneWidget);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
    expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);

    expect(find.text('I agree to Terms & Policy'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.text('Test Direct API'), findsOneWidget);
  });

  testWidgets('shows error when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please fill in all fields'), findsOneWidget);
  });

  testWidgets('shows password too short error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    await tester.enterText(find.byKey(const Key('username_field')), 'testuser');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123');
    await tester.enterText(find.byKey(const Key('confirm_password_field')), '123');
    await tester.tap(find.byType(Checkbox).first); // agree
    await tester.pump();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });

  testWidgets('shows passwords do not match error', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    await tester.enterText(find.byKey(const Key('username_field')), 'testuser');
    await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
    await tester.enterText(find.byKey(const Key('password_field')), 'password123');
    await tester.enterText(find.byKey(const Key('confirm_password_field')), 'wrongpass');
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  testWidgets('toggles password visibility icon', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpScreen()));

    expect(find.byIcon(Icons.visibility_off), findsWidgets); // both fields

    await tester.tap(find.byIcon(Icons.visibility_off).first);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsWidgets);
  });
}