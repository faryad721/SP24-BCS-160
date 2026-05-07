import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // REPLACE with your actual Supabase URL and Anon Key provided by your instructor
  await Supabase.initialize(
    url: 'https://earrmsugdyzuoougyfhh.supabase.co',
    anonKey: 'sb_publishable_5M6FcEnS9Vz10DmxjMvbmA_hSaEJguK',
  );

  runApp(const QuizApp());
}

class QuizApp extends StatelessWidget {
  const QuizApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CSC303 Quiz 3',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF0EA5E9), // Sky Blue
        scaffoldBackgroundColor: const Color(0xFF020617), // Slate 950
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF0EA5E9),
          surface: const Color(0xFF0F172A), // Slate 900
          background: const Color(0xFF020617),
          onSurface: const Color(0xFFE2E8F0), // Slate 200
          outline: const Color(0xFF1E293B), // Slate 800
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
