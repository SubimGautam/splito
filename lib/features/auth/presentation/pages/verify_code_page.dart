import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splito_project/features/auth/presentation/providers/auth_provider.dart';
import 'package:splito_project/features/auth/presentation/pages/reset_password_page.dart';

class VerifyCodePage extends ConsumerStatefulWidget {
  final String email;

  const VerifyCodePage({super.key, required this.email});

  @override
  ConsumerState<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends ConsumerState<VerifyCodePage> {
  final List<TextEditingController> _codeControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _resendEnabled = true;
  int _countdown = 60;

  static const Color kBackground = Color(0xFF0F1217);
  static const Color kSurface = Color(0xFF171C24);
  static const Color kTextPrimary = Color(0xFFF8FAFC);
  static const Color kTextSecondary = Color(0xFF94A3B8);
  static const Color kAccent = Color(0xFF22D3EE);
  static const Color kPositive = Color(0xFF10B981);
  static const Color kDivider = Color(0xFF2A3344);

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  @override
  void dispose() {
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void startCountdown() {
    _resendEnabled = false;
    _countdown = 60;
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          if (_countdown > 0) {
            _countdown--;
            startCountdown();
          } else {
            _resendEnabled = true;
          }
        });
      }
    });
  }

  String getEnteredCode() {
    return _codeControllers.map((c) => c.text).join();
  }

  Future<void> _verifyCode() async {
    final code = getEnteredCode();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the 6-digit code'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ref.read(authViewModelProvider.notifier).verifyCode(
        widget.email,
        code,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(
          context,
          '/reset-password',
          arguments: {
            'resetToken': response['resetToken'],
            'email': widget.email,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invalid code: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authViewModelProvider.notifier).forgotPassword(widget.email);
      startCountdown();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New code sent!'),
            backgroundColor: Colors.green,
          ),
        );
        
        for (var controller in _codeControllers) {
          controller.clear();
        }
        FocusScope.of(context).requestFocus(_focusNodes[0]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend code: $e'),
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
          'Verify Code',
          style: TextStyle(color: kTextPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Enter Verification Code',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: kTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We\'ve sent a 6-digit code to ${widget.email}',
                style: const TextStyle(fontSize: 14, color: kTextSecondary),
              ),
              const SizedBox(height: 40),
              
              // 6-digit code input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 45,
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: const TextStyle(
                        color: kTextPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: kSurface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: kDivider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: kDivider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: kAccent, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                        }
                        
                        if (index == 5 && value.isNotEmpty && getEnteredCode().length == 6) {
                          _verifyCode();
                        }
                      },
                    ),
                  );
                }),
              ),
              
              const SizedBox(height: 30),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyCode,
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
                          'Verify Code',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive code? ",
                    style: TextStyle(color: kTextSecondary),
                  ),
                  GestureDetector(
                    onTap: _resendEnabled && !_isLoading ? _resendCode : null,
                    child: Text(
                      _resendEnabled ? 'Resend' : 'Resend in ${_countdown}s',
                      style: TextStyle(
                        color: _resendEnabled ? kAccent : kTextSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}