import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task/models/sound_preference.dart';
import 'package:task/screens/home_screen.dart';

class TaskFlowApp extends StatefulWidget {
  const TaskFlowApp({super.key});

  @override
  State<TaskFlowApp> createState() => _TaskFlowAppState();
}

class _TaskFlowAppState extends State<TaskFlowApp> {
  ThemeMode _themeMode = ThemeMode.light;
  SoundPreference _soundPreference = SoundPreference.defaultSound;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final theme = prefs.getString('theme_mode') ?? 'light';
    final sound = prefs.getString('sound_pref') ?? 'default';
    setState(() {
      _themeMode = theme == 'dark' ? ThemeMode.dark : ThemeMode.light;
      if (sound == 'silent') {
        _soundPreference = SoundPreference.silent;
      } else if (sound == 'chime') {
        _soundPreference = SoundPreference.chime;
      } else {
        _soundPreference = SoundPreference.defaultSound;
      }
    });
  }

  Future<void> _updateTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    setState(() => _themeMode = mode);
  }

  Future<void> _updateSound(SoundPreference preference) async {
    final prefs = await SharedPreferences.getInstance();
    final value = switch (preference) {
      SoundPreference.defaultSound => 'default',
      SoundPreference.chime => 'chime',
      SoundPreference.silent => 'silent',
    };
    await prefs.setString('sound_pref', value);
    setState(() => _soundPreference = preference);
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0B3A53),
        secondary: Color(0xFF24B47E),
        surface: Color(0xFFF6F7FB),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Color(0xFF1B2028),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
    );

    final darkTheme = ThemeData(
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF9BD4F4),
        secondary: Color(0xFF30C18C),
        surface: Color(0xFF10161A),
        onPrimary: Color(0xFF0B1B22),
        onSecondary: Color(0xFF0A1B12),
        onSurface: Color(0xFFEAF1F7),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFF0E1317),
    );

    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: baseTheme.copyWith(
        textTheme: GoogleFonts.dmSansTextTheme(baseTheme.textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: GoogleFonts.dmSansTextTheme(darkTheme.textTheme),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent),
        cardTheme: const CardThemeData(
          elevation: 0,
          margin: EdgeInsets.zero,
        ),
      ),
      home: HomeScreen(
        themeMode: _themeMode,
        soundPreference: _soundPreference,
        onThemeChanged: _updateTheme,
        onSoundChanged: _updateSound,
      ),
    );
  }
}
