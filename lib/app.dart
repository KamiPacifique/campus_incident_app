import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/app_user.dart';
import 'providers/auth_provider.dart';
import 'providers/incident_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/verify_email_screen.dart';
import 'screens/staff/staff_shell.dart';
import 'screens/student/student_shell.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';
import 'theme/app_theme.dart';

class CampusIncidentApp extends StatelessWidget {
  const CampusIncidentApp({
    super.key,
    required this.authService,
    required this.incidentService,
  });

  final AuthService authService;
  final IncidentService incidentService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProxyProvider<AuthProvider, IncidentProvider>(
          create: (_) => IncidentProvider(incidentService),
          update: (_, auth, previous) => previous!..updateUser(auth.user),
        ),
      ],
      child: MaterialApp(
        title: 'Campus Incidents',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const AuthGate(),
      ),
    );
  }
}

/// Decides which part of the app to show based on the auth state:
/// signed out -> login, unverified -> verify email, then role-based shell.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    if (user == null) return const LoginScreen();
    if (!user.emailVerified) return const VerifyEmailScreen();
    return user.role == UserRole.staff
        ? const StaffShell()
        : const StudentShell();
  }
}
