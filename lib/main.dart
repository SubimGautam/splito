import 'package:flutter/material.dart';
import 'screens/signin_page.dart';

void main() {
  runApp(const SplitifyApp());
}

class SplitifyApp extends StatelessWidget {
  const SplitifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splitify',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
      ),
      home: const SignInScreen(),
    );
  }
}
