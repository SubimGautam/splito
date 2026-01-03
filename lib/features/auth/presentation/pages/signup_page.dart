import 'package:flutter/material.dart';
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agree = false;
  bool _obscurePassword = true;
  final Color mustard = const Color(0xFFC79C00);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding( 
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Text('Create account 🧑‍💻', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const Text('Please enter your email & password to sign up.', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildInputField(TextField(controller: _emailController, decoration: const InputDecoration(hintText: 'Email'))),
              const SizedBox(height: 16),
              _buildInputField(
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => setState(() => _agree = !_agree),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: mustard.withOpacity(0.9), width: 2),
                        color: _agree ? mustard : Colors.white,
                      ),
                      child: _agree ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text('I agree to Terms & Policy'),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _agree
                      ? () {
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mustard,
                    disabledBackgroundColor: mustard.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Sign up', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(height: bottomPadding + 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: child,
    );
  }
}  
