import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'providers/patient_provider.dart';
import 'providers/appointment_provider.dart';
import 'providers/doctors_provider.dart';
import 'screens/setup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_shell.dart';
import 'screens/add_patient_screen.dart';
import 'screens/edit_patient_screen.dart';
import 'screens/patient_detail_screen.dart';
import 'theme/colors.dart';
import 'widgets/toast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─── SUPABASE CONFIGURATION ────────────────────────────────────────────────
  // Option A — Hardcode here (fastest for development):
  //   await SupabaseConfig.save(
  //     url: 'https://YOUR_PROJECT_ID.supabase.co',
  //     anonKey: 'YOUR_ANON_KEY',
  //   );
  //
  // Option B — Enter at runtime via the Setup screen (default behaviour).
  //   On first launch, the app will show the Setup screen where you can
  //   paste your Supabase URL and anon key.  Values are stored on-device.
  // ──────────────────────────────────────────────────────────────────────────

  final configured = await SupabaseConfig.isConfigured();
  if (configured) {
    await SupabaseConfig.initSupabase();
  }

  runApp(DoctorApp(supabaseConfigured: configured));
}

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key, required this.supabaseConfigured});

  final bool supabaseConfigured;

  @override
  Widget build(BuildContext context) {
    final baseTheme = ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          color: Colors.white,
        ),
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DoctorsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        scaffoldMessengerKey: AppToast.messengerKey,
        title: 'MediConnect',
        theme: baseTheme.copyWith(
          textTheme: GoogleFonts.interTextTheme(baseTheme.textTheme),
        ),
        home: supabaseConfigured ? const _AuthGate() : const SetupScreen(),
        routes: {
          '/setup': (_) => const SetupScreen(),
          '/login': (_) => const LoginScreen(),
          '/home':  (_) => const MainShell(),
          '/add-patient': (_) => const AddPatientScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/patient') {
            final id = settings.arguments as String;
            return MaterialPageRoute(
              builder: (_) => PatientDetailScreen(patientId: id),
            );
          }
          if (settings.name == '/edit-patient') {
            final id = settings.arguments as String;
            return MaterialPageRoute(
              fullscreenDialog: true,
              builder: (_) => EditPatientScreen(patientId: id),
            );
          }
          return null;
        },
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: SupabaseConfig.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data!.session;
          if (session != null) return const MainShell();
        }
        return const LoginScreen();
      },
    );
  }
}
