
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/login_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/cafeteria_dashboard_screen.dart';
import 'screens/student_profile_screen.dart';
import 'screens/scholarship_calls_screen.dart';
import 'screens/upload_documents_screen.dart';
import 'screens/application_status_screen.dart';
import 'screens/scholarship_applicants_screen.dart';
import 'screens/applicant_details_screen.dart';
import 'screens/create_scholarship_call_screen.dart';
import 'screens/scholarship_history_screen.dart';
import 'screens/redeem_voucher_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

// Gestor de estado para el tema
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Configuración del enrutador
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const StudentDashboardScreen();
      },
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) {
            return const StudentProfileScreen();
          },
        ),
        GoRoute(
          path: 'scholarship-calls',
          builder: (BuildContext context, GoRouterState state) {
            return const ScholarshipCallsScreen();
          },
        ),
        GoRoute(
          path: 'upload-documents',
          builder: (BuildContext context, GoRouterState state) {
            return const UploadDocumentsScreen();
          },
        ),
        GoRoute(
          path: 'application-status',
          builder: (BuildContext context, GoRouterState state) {
            return const ApplicationStatusScreen();
          },
        ),
      ],
    ),
    GoRoute(
        path: '/admin-dashboard',
        builder: (BuildContext context, GoRouterState state) {
          return const AdminDashboardScreen();
        },
        routes: [
          GoRoute(
            path: 'scholarship-applicants',
            builder: (BuildContext context, GoRouterState state) {
              return const ScholarshipApplicantsScreen();
            },
            routes: [
              GoRoute(
                path: 'applicant-details',
                builder: (BuildContext context, GoRouterState state) {
                  return const ApplicantDetailsScreen();
                },
              ),
            ],
          ),
          GoRoute(
            path: 'create-scholarship-call',
            builder: (BuildContext context, GoRouterState state) {
              return const CreateScholarshipCallScreen();
            },
          ),
          GoRoute(
            path: 'scholarship-history',
            builder: (BuildContext context, GoRouterState state) {
              return const ScholarshipHistoryScreen();
            },
          ),
        ]),
    GoRoute(
      path: '/cafeteria-dashboard',
      builder: (BuildContext context, GoRouterState state) {
        return const CafeteriaDashboardScreen();
      },
      routes: [
        GoRoute(
          path: 'redeem-voucher',
          builder: (BuildContext context, GoRouterState state) {
            return const RedeemVoucherScreen();
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor primarySeedColor = Colors.indigo;

    final TextTheme appTextTheme = TextTheme(
      displayLarge: GoogleFonts.montserrat(fontSize: 57, fontWeight: FontWeight.bold),
      headlineMedium: GoogleFonts.montserrat(fontSize: 28, fontWeight: FontWeight.w600),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyMedium: GoogleFonts.openSans(fontSize: 14),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500),
    );

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.light,
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: primarySeedColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primarySeedColor,
        brightness: Brightness.dark,
        background: Colors.grey[900],
      ),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey.shade800,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        filled: true,
        fillColor: Colors.black26,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: primarySeedColor.shade200,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'AMOBECAL',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
