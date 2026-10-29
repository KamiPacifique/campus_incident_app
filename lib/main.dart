import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'services/firebase_auth_service.dart';
import 'services/incident_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Auth is now real Firebase. Incidents are still the mock until step 5.
  final AuthService authService = FirebaseAuthService();
  final IncidentService incidentService = MockIncidentService();

  runApp(CampusIncidentApp(
    authService: authService,
    incidentService: incidentService,
  ));
}