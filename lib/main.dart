import 'package:flutter/material.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'services/incident_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // STEP 2 (backend): replace these two lines with FirebaseAuthService()
  // and FirestoreIncidentService(). Nothing else in the app has to change.
  final AuthService authService = MockAuthService();
  final IncidentService incidentService = MockIncidentService();

  runApp(CampusIncidentApp(
    authService: authService,
    incidentService: incidentService,
  ));
}
