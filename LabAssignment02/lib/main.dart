import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: Consumer<GameProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Smart Guess Pro',

            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode:
                provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,

            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}