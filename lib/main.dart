import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart'; 
import 'features/auth/presentation/pages/reset_password_page.dart';   
import 'features/dashboard/presentation/pages/main_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splito',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1DBA8A),
          brightness: Brightness.light,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const SignInScreen(),
        '/main': (context) => const MainScreen(),
        '/forgot-password': (context) => ForgotPasswordPage(), // Now recognized
        '/reset-password': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>?;
          
          // Handle case when args is null
          if (args == null) {
            return const SignInScreen(); // Fallback to login
          }
          
          return ResetPasswordPage(
            token: args['token'] ?? '',
            email: args['email'] ?? '',
          );
        },
      },
      // Handle unknown routes
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        );
      },
    );
  }
}