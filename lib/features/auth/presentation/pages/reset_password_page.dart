import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_project/features/auth/presentation/pages/login_page.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String resetToken;
  final String email;

  const ResetPasswordPage({
    super.key,
    required this.resetToken,
    required this.email,
  });

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _passwordReset = false;

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kDivider = Color(0xFF2A3344);

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authViewModelProvider.notifier).resetPassword(
        widget.resetToken,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      
      setState(() => _passwordReset = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reset password: $e'),
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
          'Reset Password',
          style: TextStyle(color: kTextPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _passwordReset 
              ? _buildSuccessScreen() 
              : _buildResetForm(),
        ),
      ),
    );
  }

  Widget _buildResetForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Create New Password',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set a new password for ${widget.email}',
            style: const TextStyle(fontSize: 14, color: kTextSecondary),
          ),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'New Password',
                hintStyle: const TextStyle(color: kTextSecondary),
                prefixIcon: const Icon(Icons.lock_outline, color: kTextSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: kTextSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                if (value.length < 6) {
                  return 'Password must be at least 6 characters';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: kDivider),
            ),
            child: TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              style: const TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle: const TextStyle(color: kTextSecondary),
                prefixIcon: const Icon(Icons.lock_outline, color: kTextSecondary),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    color: kTextSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please confirm your password';
                }
                if (value != _passwordController.text) {
                  return 'Passwords do not match';
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
              onPressed: _isLoading ? null : _resetPassword,
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
                      'Reset Password',
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
    );
  }

  Widget _buildSuccessScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: kPositive.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 60,
              color: kPositive,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Password Reset!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your password has been successfully reset.\nYou can now login with your new password.',
            style: TextStyle(color: kTextSecondary, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const SignInScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
              child: const Text(
                'Go to Login',
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
    );
  }
}