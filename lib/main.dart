import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/initialize_content.dart';
import 'screens/login_screen.dart';
import 'screens/student_dashboard_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'screens/cafeteria_dashboard_screen.dart';
import 'screens/cafeteria_scholar_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/application_status_screen.dart';
import 'screens/scholarship_application_screen.dart';
import 'screens/scholarship_info_screen.dart';
import 'screens/scholarship_applicants_screen.dart';
import 'screens/applicant_details_screen.dart';
import 'screens/create_scholarship_call_screen.dart';
import 'screens/accepted_list_screen.dart';
import 'screens/accepted_students_per_call_screen.dart';
import 'screens/accepted_student_details_screen.dart';
import 'screens/admin_settings_screen.dart';
import 'screens/scholarship_calls_list_screen.dart';
import 'screens/admin_scholarship_calls_screen.dart';
import 'screens/manage_active_scholarships_screen.dart';
import 'screens/manage_past_calls_screen.dart';
import 'screens/cancel_scholarship_screen.dart';
import 'screens/edit_scholarship_call_screen.dart';
import 'screens/edit_content_screen.dart';
import 'screens/publish_results_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);
  await initializeContent();
  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    notifyListeners();
  }
}

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/login',
  routes: <RouteBase>[
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/student-dashboard',
      builder: (BuildContext context, GoRouterState state) => const StudentDashboardScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'profile',
          builder: (BuildContext context, GoRouterState state) => const ProfileScreen(),
        ),
        GoRoute(
          path: 'application-status',
          builder: (BuildContext context, GoRouterState state) => const ApplicationStatusScreen(),
        ),
         GoRoute(
          path: 'scholarship-calls',
          builder: (BuildContext context, GoRouterState state) => const ScholarshipCallsListScreen(),
        ),
        GoRoute(
          path: 'scholarship-application/:callId',
          builder: (BuildContext context, GoRouterState state) {
            final callId = state.pathParameters['callId']!;
            return ScholarshipApplicationScreen(callId: callId);
          },
        ),
        GoRoute(
          path: 'scholarship-info',
          builder: (BuildContext context, GoRouterState state) => const ScholarshipInfoScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/admin-dashboard',
      builder: (BuildContext context, GoRouterState state) => const AdminDashboardScreen(),
      routes: [
         GoRoute(
          path: 'admin-scholarship-calls',
          builder: (BuildContext context, GoRouterState state) => const AdminScholarshipCallsScreen(),
        ),
        GoRoute(
          path: 'scholarship-applicants/:callId',
          builder: (BuildContext context, GoRouterState state) {
            final callId = state.pathParameters['callId']!;
            return ScholarshipApplicantsScreen(callId: callId);
          },
          routes: [
            GoRoute(
              path: 'applicant-details/:applicantId',
              builder: (context, state) {
                final callId = state.pathParameters['callId']!;
                final applicantId = state.pathParameters['applicantId']!;
                return ApplicantDetailsScreen(
                  callId: callId,
                  applicantId: applicantId,
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'create-scholarship-call',
          builder: (BuildContext context, GoRouterState state) => const CreateScholarshipCallScreen(),
        ),
        GoRoute(
          path: 'accepted-list',
          builder: (BuildContext context, GoRouterState state) => const AcceptedListScreen(),
          routes: [
            GoRoute(
              path: ':callId',
              builder: (context, state) {
                final callId = state.pathParameters['callId']!;
                return AcceptedStudentsPerCallScreen(callId: callId);
              },
              routes: [
                 GoRoute(
                  path: ':applicantId',
                  builder: (context, state) {
                    final callId = state.pathParameters['callId']!;
                    final applicantId = state.pathParameters['applicantId']!;
                    return AcceptedStudentDetailsScreen(
                      callId: callId,
                      applicantId: applicantId,
                    );
                  },
                ),
              ]
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          builder: (BuildContext context, GoRouterState state) => const AdminSettingsScreen(),
          routes: [
             GoRoute(
              path: 'publish-results',
              builder: (context, state) => const PublishResultsScreen(),
            ),
            GoRoute(
              path: 'edit-content',
              builder: (context, state) => const EditContentScreen(),
            ),
            GoRoute(
              path: 'manage-active-scholarships',
              builder: (context, state) => const ManageActiveScholarshipsScreen(),
              routes: [
                GoRoute(
                  path: 'edit/:callId',
                  builder: (context, state) {
                    final callId = state.pathParameters['callId']!;
                    return EditScholarshipCallScreen(callId: callId);
                  },
                ),
              ]
            ),
             GoRoute(
              path: 'manage-past-scholarships',
              builder: (context, state) => const ManagePastCallsScreen(),
            ),
             GoRoute(
              path: 'cancel-scholarship',
              builder: (context, state) => const CancelScholarshipScreen(),
            ),
          ],
        ),
      ],
    ),
     GoRoute(
      path: '/cafeteria-dashboard',
      builder: (BuildContext context, GoRouterState state) => const CafeteriaDashboardScreen(),
      routes: [
         GoRoute(
          path: 'scholar-list/:callId',
           builder: (context, state) {
            final callId = state.pathParameters['callId']!;
            return CafeteriaScholarListScreen(callId: callId);
          },
        ),
      ]
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
      colorScheme: ColorScheme.fromSeed(seedColor: primarySeedColor, brightness: Brightness.light),
      textTheme: appTextTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: primarySeedColor,
        foregroundColor: Colors.white,
        titleTextStyle: GoogleFonts.montserrat(fontSize: 22, fontWeight: FontWeight.bold),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
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

     final darkColorScheme = ColorScheme.fromSeed(
      seedColor: primarySeedColor,
      brightness: Brightness.dark,
      background: const Color(0xFF121212),
      surface: const Color(0xFF1E1E1E),
      onSurface: Colors.white,
      onBackground: Colors.white,
      primary: primarySeedColor.shade300,
      onPrimary: Colors.black,
    );

    final darkTextTheme = appTextTheme.apply(
      bodyColor: darkColorScheme.onSurface,
      displayColor: darkColorScheme.onSurface,
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: darkColorScheme,
      textTheme: darkTextTheme,
      scaffoldBackgroundColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
        titleTextStyle: GoogleFonts.montserrat(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: darkColorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(color: const Color(0xFF2A2A2A), elevation: 2),
      listTileTheme: ListTileThemeData(
        iconColor: darkColorScheme.primary,
        textColor: darkColorScheme.onSurface,
        tileColor: const Color(0xFF2A2A2A),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
        filled: true,
        fillColor: Colors.black26,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          foregroundColor: darkColorScheme.onPrimary,
          backgroundColor: darkColorScheme.primary,
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
