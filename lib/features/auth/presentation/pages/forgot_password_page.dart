import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_project/features/auth/presentation/providers/auth_provider.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  ForgotPasswordPage({super.key}); // No const constructor needed

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _emailSent = false;

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kDivider = Color(0xFF2A3344);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref.read(authViewModelProvider.notifier).forgotPassword(
        _emailController.text.trim(),
      );
      
      setState(() => _emailSent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
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
        title: const Text('Forgot Password', style: TextStyle(color: kTextPrimary)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessScreen() : _buildEmailForm(),
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('Reset Password', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimary)),
          const SizedBox(height: 8),
          const Text('Enter your email to receive reset instructions.', style: TextStyle(fontSize: 14, color: kTextSecondary)),
          const SizedBox(height: 40),
          Container(
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kDivider)),
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
                if (value == null || value.isEmpty) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return 'Please enter a valid email';
                return null;
              },
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetEmail,
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Reset Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
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
          Container(width: 120, height: 120, decoration: BoxDecoration(color: kPositive.withOpacity(0.2), shape: BoxShape.circle),
            child: const Icon(Icons.mark_email_read, size: 60, color: kPositive),
          ),
          const SizedBox(height: 24),
          const Text('Email Sent!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kTextPrimary)),
          const SizedBox(height: 12),
          Text('Reset instructions sent to\n${_emailController.text}', style: const TextStyle(color: kTextSecondary, fontSize: 16), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: kAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              child: const Text('Back to Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}