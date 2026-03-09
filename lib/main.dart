import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_project/features/dashboard/presentation/pages/main_screen.dart';
import 'features/splash/presentation/pages/splash_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/forgot_password_page.dart';
import 'features/auth/presentation/pages/verify_code_page.dart';
import 'features/auth/presentation/pages/reset_password_page.dart';
import 'package:splito_project/features/auth/presentation/pages/verify_code_page.dart';

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
        '/forgot-password': (context) => const ForgotPasswordPage(),
      },
      onGenerateRoute: (settings) {
        // Handle routes with arguments
        if (settings.name == '/verify-code') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && args.containsKey('email')) {
            return MaterialPageRoute(
              builder: (context) => VerifyCodePage(
                email: args['email'] as String,
              ),
            );
          }
        }
        
        if (settings.name == '/reset-password') {
          final args = settings.arguments as Map<String, dynamic>?;
          if (args != null && 
              args.containsKey('resetToken') && 
              args.containsKey('email')) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordPage(
                resetToken: args['resetToken'] as String,
                email: args['email'] as String,
              ),
            );
          }
        }
        
        // Fallback to login if route not found
        return MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        );
      },
    );
  }
}