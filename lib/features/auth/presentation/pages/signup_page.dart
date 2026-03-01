import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/auth/data/datasource/local/local_auth_datasource.dart';
import 'package:splito_project/features/auth/data/datasource/remote/remote_auth_datasource.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _agree = false;
  bool _obscurePassword = true;
  bool _isLoading = false;

  final Color mustard = const Color(0xFFC79C00);

  final _localAuthDataSource = LocalAuthDataSourceImpl();
  final _remoteAuthDataSource = RemoteAuthDataSourceImpl();

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kSurfaceElevated = Color(0xFF1F2630);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kAccentDark = Color(0xFF0891B2);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kNegative = Color(0xFFEF4444);
  static const Color kDivider = Color(0xFF2A3344);

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (username.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showSnackBar('Please fill in all fields');
      return;
    }

    if (password.length < 6) {
      _showSnackBar('Password must be at least 6 characters');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Passwords do not match');
      return;
    }

    if (!_agree) {
      _showSnackBar('Please agree to Terms & Policy');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _remoteAuthDataSource.signUp(
        username,
        email,
        password,
        confirmPassword,
      );

      await _localAuthDataSource.saveCredentials(email, password);

      if (mounted) {
        _showSnackBar('Account created successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Registration failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testDirectApiCall() async {
    try {
      final email = 'test_${DateTime.now().millisecondsSinceEpoch}@test.com';

      final response = await http.post(
        Uri.parse('http://192.168.1.115:5000/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "username": "testuser",
          "email": email,
          "password": "password123",
          "confirmPassword": "password123",
        }),
      );

      if (response.statusCode == 201) {
        _showSnackBar('Direct API test successful!');
      } else {
        _showSnackBar('Direct API failed: ${response.body}');
      }
    } catch (e) {
      _showSnackBar('Direct API error: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Create account 🧑‍💻',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextPrimary),
                ),
                const SizedBox(height: 40),

                _buildTextField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.person_outline,
                  key: const Key('username_field'), // Add this
                    ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  key: const Key('email_field'),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _passwordController,
                  hint: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  isPassword: true,
                  onToggleVisibility: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  key: const Key('password_field'),
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  controller: _confirmPasswordController,
                  hint: 'Confirm Password',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  isPassword: true,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  key: const Key('confirm_password_field'), // Add this
                    ),
                const SizedBox(height: 30),

                Row(
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: kAccent,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    const Text('I agree to Terms & Policy', style: TextStyle(color: kTextSecondary)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _testDirectApiCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Test Direct API',
                      style: TextStyle(color: Colors.white),
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

  Widget _buildTextField({
  required TextEditingController controller,
  required String hint,
  required IconData icon,
  TextInputType? keyboardType,
  bool obscureText = false,
  bool isPassword = false,
  VoidCallback? onToggleVisibility,
  Key? key,                      // ← ADD THIS (optional Key)
}) {
  return Container(
    decoration: BoxDecoration(
      color: kSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: kDivider),
    ),
    child: TextField(
      key: key,                    // ← PASS IT DOWN HERE
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kTextSecondary),
        prefixIcon: Icon(icon, color: kTextSecondary),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  color: kTextSecondary,
                ),
                onPressed: onToggleVisibility,
              )
            : null,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
      style: const TextStyle(color: kTextPrimary),
    ),
  );
}
}