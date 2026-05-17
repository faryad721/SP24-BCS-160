import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_4_supabase_auth/theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Rate limiting
  DateTime? _lastSignUpAttempt;
  final Duration _rateLimitDuration = const Duration(seconds: 30);

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 6) return 'Minimum 6 characters required';
    return null;
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match'), backgroundColor: Colors.red),
      );
      return;
    }

    // Rate limiting check
    if (_lastSignUpAttempt != null) {
      final timeSinceLastAttempt = DateTime.now().difference(_lastSignUpAttempt!);
      if (timeSinceLastAttempt.inSeconds < _rateLimitDuration.inSeconds) {
        final remainingSeconds = _rateLimitDuration.inSeconds - timeSinceLastAttempt.inSeconds;
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please wait ${remainingSeconds}s before trying again'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
    }

    _lastSignUpAttempt = DateTime.now();
    setState(() => _isLoading = true);
    try {
      await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Verify Your Email'),
            content: const Text('A verification link has been sent to your email. Please check your inbox and spam folder.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        ).then((_) => Navigator.pop(context));
      }
    } on AuthException catch (error) {
      if (mounted) {
        final errorMessage = _getErrorMessage(error.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration failed. Try again later.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getErrorMessage(String error) {
    if (error.contains('rate') || error.contains('too many')) {
      return 'Too many attempts. Please wait a few minutes before trying again.';
    } else if (error.contains('already registered')) {
      return 'This email is already registered.';
    } else if (error.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(border: Border.all(color: AppTheme.slate200, width: 8)),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Join Us', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
                  const Text('Create your account via Supabase', style: TextStyle(color: AppTheme.slate500, fontSize: 13)),
                  const SizedBox(height: 32),
                  
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.slate900, width: 4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        TextFormField(controller: _emailController, decoration: const InputDecoration(hintText: 'Enter email'), validator: _validateEmail),
                        const SizedBox(height: 16),
                        
                        const Text('PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        TextFormField(controller: _passwordController, decoration: const InputDecoration(hintText: 'Min 6 characters'), obscureText: true, validator: _validatePassword),
                        const SizedBox(height: 16),
                        
                        const Text('CONFIRM PASSWORD', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.0)),
                        const SizedBox(height: 4),
                        TextFormField(controller: _confirmPasswordController, decoration: const InputDecoration(hintText: 'Confirm password'), obscureText: true),
                        const SizedBox(height: 24),
                        
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.slate900),
                          onPressed: _isLoading ? null : _signUp,
                          child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('CREATE ACCOUNT'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login', style: TextStyle(color: AppTheme.slate500, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
