import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_4_supabase_auth/theme.dart';
import 'package:quiz_4_supabase_auth/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  final User user;
  const HomeScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(border: Border.all(color: AppTheme.slate200, width: 8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.indigo.shade50,
                    radius: 20,
                    child: Text(
                      user.email!.substring(0, 2).toUpperCase(),
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (context.mounted) {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                      }
                    },
                    child: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Account Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.slate900)),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.slate200),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfo(label: 'EMAIL', value: user.email!),
                    const Divider(height: 30, color: AppTheme.slate100),
                    _buildInfo(label: 'USER ID', value: user.id),
                    const Divider(height: 30, color: AppTheme.slate100),
                    _buildInfo(label: 'AUTH PROVIDER', value: 'supabase_email', isSuccess: true),
                  ],
                ),
              ),
              
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.emerald50,
                  border: Border.all(color: AppTheme.emerald100),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Successfully authenticated via Supabase GoTrue client. Your session is active.',
                  style: TextStyle(color: Color(0xFF065F46), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfo({required String label, required String value, bool isSuccess = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.slate400, letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Row(
          children: [
            if (isSuccess) ...[
              Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppTheme.emerald500, shape: BoxShape.circle)),
              const SizedBox(width: 8),
            ],
            Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.slate800, fontFamily: label == 'USER ID' ? 'monospace' : null))),
          ],
        ),
      ],
    );
  }
}
