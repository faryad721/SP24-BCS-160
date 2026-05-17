import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quiz_4_supabase_auth/theme.dart';
import 'package:quiz_4_supabase_auth/screens/login_screen.dart';
import 'package:quiz_4_supabase_auth/screens/home_screen.dart';

// IMPORTANT: Replace with your actual Supabase URL and Anon Key
const String supabaseUrl = 'https://imivfqvuajvnevsnoetc.supabase.co';
const String supabaseAnonKey = 'sb_publishable_GxcR-e0CQldp6bP1_XsFuQ_Chc0T8Lp';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSC303 Quiz 4',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;
    
    if (session != null) {
      return HomeScreen(user: session.user);
    } else {
      return const LoginScreen();
    }
  }
}
