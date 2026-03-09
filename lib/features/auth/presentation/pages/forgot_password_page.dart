import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_project/features/auth/presentation/pages/verify_code_page.dart'; // ADD THIS IMPORT

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kDivider = Color(0xFF2A3344);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authViewModelProvider.notifier).forgotPassword(
        _emailController.text.trim(),
      );
      
      // Navigate to code verification page
      if (mounted) {
        Navigator.pushNamed(
          context,
          '/verify-code',
          arguments: {'email': _emailController.text.trim()},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        backgroundColor: kBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(color: kTextPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter your email address and we\'ll send you a 6-digit code to reset your password.',
                  style: TextStyle(fontSize: 14, color: kTextSecondary),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kDivider),
                  ),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: kTextPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: kTextSecondary),
                      prefixIcon: Icon(Icons.email_outlined, color: kTextSecondary),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      disabledBackgroundColor: kAccent.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Send Reset Code',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}