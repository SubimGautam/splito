import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:splito_project/features/auth/presentation/pages/login_page.dart';
import 'package:splito_project/features/auth/presentation/pages/signup_page.dart';
import 'package:splito_project/features/auth/data/datasource/remote/remote_auth_datasource.dart';
import 'package:splito_project/features/auth/data/datasource/local/local_auth_datasource.dart';
import 'package:splito_project/features/auth/presentation/providers/auth_provider.dart';

// Generate mocks
@GenerateMocks([RemoteAuthDataSourceImpl, LocalAuthDataSourceImpl])
import 'login_page_test.mocks.dart';

void main() {
  late MockRemoteAuthDataSourceImpl mockRemoteAuth;
  late MockLocalAuthDataSourceImpl mockLocalAuth;
  late ProviderContainer container;

  setUp(() {
    mockRemoteAuth = MockRemoteAuthDataSourceImpl();
    mockLocalAuth = MockLocalAuthDataSourceImpl();

    container = ProviderContainer(
      overrides: [
        remoteAuthDataSourceProvider.overrideWithValue(mockRemoteAuth),
        localAuthDataSourceProvider.overrideWithValue(mockLocalAuth),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  Future<void> pumpLoginPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        parent: container,
        child: const MaterialApp(
          home: SignInScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('2. shows error when fields are empty', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Please enter email and password'), findsOneWidget);
  });

  testWidgets('3. toggles password visibility', (tester) async {
    await pumpLoginPage(tester);

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    expect(find.byIcon(Icons.visibility), findsNothing);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
    expect(find.byIcon(Icons.visibility_off), findsNothing);
  });

  testWidgets('4. checkbox toggles remember me', (tester) async {
    await pumpLoginPage(tester);

    final checkbox = find.byType(Checkbox);
    expect(checkbox, findsOneWidget);

    expect(tester.widget<Checkbox>(checkbox).value, false);

    await tester.tap(checkbox);
    await tester.pump();

    expect(tester.widget<Checkbox>(checkbox).value, true);
  });

  testWidgets('5. shows error when login fails', (tester) async {
    when(mockRemoteAuth.signIn(any, any)).thenThrow(Exception('Invalid credentials'));

    await pumpLoginPage(tester);

    await tester.enterText(find.byType(TextField).first, 'test@example.com');
    await tester.enterText(find.byType(TextField).last, 'wrongpass');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Sign in'));
    await tester.pump();

    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('Login failed'), findsOneWidget);
  });

  testWidgets('8. tapping "Sign up" navigates to SignUpScreen', (tester) async {
    await pumpLoginPage(tester);

    await tester.tap(find.text('Sign up'));
    await tester.pumpAndSettle();

    expect(find.byType(SignUpScreen), findsOneWidget);
  });

  testWidgets('9. email field has email keyboard type', (tester) async {
    await pumpLoginPage(tester);

    final emailField = find.byType(TextField).first;
    final textField = tester.widget<TextField>(emailField);
    expect(textField.keyboardType, TextInputType.emailAddress);
  });

  testWidgets('10. password field is obscured', (tester) async {
    await pumpLoginPage(tester);

    final passwordField = find.byType(TextField).last;
    final textField = tester.widget<TextField>(passwordField);
    expect(textField.obscureText, true);
  });
}