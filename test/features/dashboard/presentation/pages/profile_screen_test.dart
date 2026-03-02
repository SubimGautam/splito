import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splito_project/features/dashboard/presentation/pages/profile_screen.dart';
import 'package:splito_project/features/dashboard/domain/model/user.dart';
import 'package:splito_project/features/dashboard/presentation/view_models/user_provider.dart';

void main() {
  testWidgets('shows error message when loading fails', (WidgetTester tester) async {
    final errorProvider = FutureProvider<User>((ref) async => throw Exception('Network error'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider.overrideWithProvider(errorProvider),
        ],
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Error loading profile: Exception: Network error'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });
}