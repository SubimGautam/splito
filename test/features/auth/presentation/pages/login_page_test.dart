import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splito_project/features/auth/presentation/pages/signup_page.dart'; // for navigation check
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/auth/presentation/pages/login_page.dart'; // ← your file

// Mock navigator observer to verify pushes
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  late MockNavigatorObserver mockObserver;

  setUp(() {
    mockObserver = MockNavigatorObserver();
    registerFallbackValue(MaterialPageRoute(builder: (_) => const SizedBox()));
  });

  testWidgets('shows welcome texts and input fields', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Please enter your email & password to sign in.'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2)); // email + password
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
  });

  testWidgets('shows error snackbar when fields are empty', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please enter email and password'), findsOneWidget);
  });

  testWidgets('toggles password visibility', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SignInScreen()),
    );

    final visibilityOff = find.byIcon(Icons.visibility_off);
    expect(visibilityOff, findsOneWidget);

    await tester.tap(visibilityOff);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });

  testWidgets('navigates to SignUpScreen when tapping Sign up', (tester) async {
  // No need for MockNavigatorObserver for basic test
  await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

  // "Sign up" is likely a Text widget inside a GestureDetector
  final signUpFinder = find.text('Sign up');
  expect(signUpFinder, findsOneWidget);
  
  await tester.tap(signUpFinder);
  await tester.pumpAndSettle();

  // Should now show SignUpScreen
  expect(find.byType(SignUpScreen), findsOneWidget);
});
}