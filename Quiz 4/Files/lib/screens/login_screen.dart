import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_4_supabase_auth/screens/register_screen.dart';
import 'package:quiz_4_supabase_auth/screens/home_screen.dart';
import 'package:quiz_4_supabase_auth/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  
  // Rate limiting for login attempts
  DateTime? _lastSignInAttempt;
  int _failedAttempts = 0;
  final Duration _rateLimitDuration = const Duration(seconds: 10);

  Future<void> _signIn() async {
    setState(() => _isLoading = true);
    try {
      // Check rate limit
      if (_lastSignInAttempt != null && _failedAttempts >= 3) {
        final timeSinceLastAttempt = DateTime.now().difference(_lastSignInAttempt!);
        if (timeSinceLastAttempt.inSeconds < _rateLimitDuration.inSeconds) {
          final remainingSeconds = _rateLimitDuration.inSeconds - timeSinceLastAttempt.inSeconds;
          throw Exception('Too many failed attempts. Wait ${remainingSeconds}s before trying again.');
        }
        _failedAttempts = 0;
      }

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      _failedAttempts = 0;
      
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen(user: response.user!)),
        );
      }
    } on AuthException catch (error) {
      _failedAttempts++;
      _lastSignInAttempt = DateTime.now();
      if (mounted) {
        final errorMessage = _getLoginErrorMessage(error.message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } catch (error) {
      _failedAttempts++;
      _lastSignInAttempt = DateTime.now();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getLoginErrorMessage(String error) {
    if (error.contains('Invalid login')) {
      return 'Invalid email or password.';
    } else if (error.contains('rate') || error.contains('too many')) {
      return 'Too many login attempts. Please try again later.';
    }
    return error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.slate200, width: 8),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Header
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.slate900,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.lock_person_rounded, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Welcome Back',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.slate900),
                ),
                const Text(
                  'Enter your credentials to continue',
                  style: TextStyle(color: AppTheme.slate500, fontSize: 13),
                ),
                const SizedBox(height: 40),
                
                // Form
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.slate900, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.slate900.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('EMAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(hintText: 'user@university.edu'),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 20),
                      const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.2)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _passwordController,
                        decoration: const InputDecoration(hintText: '••••••••'),
                        obscureText: true,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        child: _isLoading 
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                          : const Text('SIGN IN'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                  },
                  child: RichText(
                    text: const TextSpan(
                      text: "New user? ",
                      style: TextStyle(color: AppTheme.slate500, fontSize: 12),
                      children: [
                        TextSpan(
                          text: "Register Now",
                          style: TextStyle(color: AppTheme.emerald600, fontWeight: FontWeight.bold),
                        ),
                      ],
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
