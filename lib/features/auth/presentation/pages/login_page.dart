import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:splito_project/features/dashboard/presentation/pages/home_screen.dart';
import 'package:splito_project/features/auth/presentation/pages/signup_page.dart';
import 'package:splito_project/features/auth/data/datasource/local/local_auth_datasource.dart';
import 'package:splito_project/features/auth/data/datasource/remote/remote_auth_datasource.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _obscurePassword = true;
  final Color mustard = const Color(0xFFC79C00);
  
  bool _isLoading = false;

  final _localAuthDataSource = LocalAuthDataSourceImpl();
  final _remoteAuthDataSource = RemoteAuthDataSourceImpl();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    print('🎯 ===== LOGIN BUTTON PRESSED =====');
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Please enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🚀 Calling remoteAuthDataSource.signIn()...');
      final result = await _remoteAuthDataSource.signIn(email, password);
      
      print('✅ Remote login successful: $result');
      
      // ✅ ADD THIS: Debug token storage after login
      await _debugTokenStorage();
      
      if (_rememberMe) {
        await _localAuthDataSource.saveCredentials(email, password);
      }
      
      if (mounted) {
        _showSnackBar('Login successful!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      print('❌ Login error: $e');
      if (mounted) {
        _showSnackBar('Login failed: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper method for min function
  int min(int a, int b) => a < b ? a : b;

  Future<void> _debugTokenStorage() async {
    print("=" * 50);
    print("🔍 DEBUGGING TOKEN STORAGE");
    print("=" * 50);
    
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    
    print("📋 All SharedPreferences keys:");
    for (var key in keys) {
      final value = prefs.get(key);
      print("   • $key: $value");
    }
    
    // Check specifically for token
    final token = prefs.getString('auth_token');
    if (token == null) {
      print("❌❌❌ NO TOKEN FOUND!");
      print("The token is NOT being saved after login!");
      
      // Check for other possible token keys
      final token1 = prefs.getString('token');
      final token2 = prefs.getString('jwt_token');
      final token3 = prefs.getString('jwt');
      
      print("🔍 Checking other possible token keys:");
      print("   • 'token': ${token1 != null ? 'FOUND' : 'NOT FOUND'}");
      print("   • 'jwt_token': ${token2 != null ? 'FOUND' : 'NOT FOUND'}");
      print("   • 'jwt': ${token3 != null ? 'FOUND' : 'NOT FOUND'}");
    } else {
      print("✅ Token FOUND in SharedPreferences!");
      print("   Length: ${token.length}");
      print("   Preview: ${token.substring(0, min(30, token.length))}...");
    }
    
    print("=" * 50);
  }

  Future<void> _testBackendConnection() async {
    try {
      print('🧪 Testing backend connection...');
      
      final urls = [
        'http://localhost:5000/api/health',
        'http://127.0.0.1:5000/api/health',
        'http://10.0.2.2:5000/api/health',
      ];
      
      for (var url in urls) {
        try {
          final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
          print('✅ $url - Status: ${response.statusCode}');
          print('Response: ${response.body}');
        } catch (e) {
          print('❌ $url - Error: $e');
        }
      }
    } catch (e) {
      print('❌ Test failed: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Welcome back',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please enter your email & password to sign in.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: Icons.lock_outline,
                obscureText: _obscurePassword,
                isPassword: true,
                onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: mustard,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          onChanged: (val) => setState(() => _rememberMe = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('Remember me', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      // You can implement forgot password later
                    },
                    child: Text(
                      'Forgot password?',
                      style: TextStyle(color: mustard, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    },
                    child: Text(
                      'Sign up',
                      style: TextStyle(color: mustard, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mustard,
                      disabledBackgroundColor: mustard.withOpacity(0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign in',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _debugTokenStorage,
            child: const Icon(Icons.bug_report),
            backgroundColor: Colors.blue,
            tooltip: 'Debug Token Storage',
            heroTag: 'debug_token',
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            onPressed: _testBackendConnection,
            child: const Icon(Icons.wifi),
            backgroundColor: mustard,
            tooltip: 'Test Backend Connection',
            heroTag: 'test_backend',
          ),
        ],
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
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(16)),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          prefixIcon: Icon(icon, color: Colors.grey[600]),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[600]),
                  onPressed: onToggleVisibility,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}