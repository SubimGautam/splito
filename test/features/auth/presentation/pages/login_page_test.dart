import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/auth/presentation/pages/login_page.dart';
import 'package:splito_project/features/auth/presentation/pages/signup_page.dart';

void main() {
  testWidgets('renders all UI elements correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('Please enter your email & password to sign in.'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Sign in'), findsOneWidget);
    expect(find.text('Remember me'), findsOneWidget);
    expect(find.text('Sign up'), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNWidgets(2)); // debug buttons
  });

  testWidgets('toggles password visibility', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignInScreen()));

    final visibilityOff = find.byIcon(Icons.visibility_off);
    expect(visibilityOff, findsOneWidget);

    await tester.tap(visibilityOff);
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });

  testWidgets('navigates to SignUpScreen when tapping "Sign up"', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: '/',
        routes: {
          '/': (context) => const SignInScreen(),
          '/signup': (context) => const SignUpScreen(),
        },
      ),
    );

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
  });
}