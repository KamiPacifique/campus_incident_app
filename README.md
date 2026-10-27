# Campus Incident Reporting App (Flutter) — Frontend

Provider for state management, service interfaces for data. Currently runs on
in-memory mock services so the whole UI can be demoed before Firebase is added.

## Run
```
flutter create . --platforms=android,ios   # generates android/ and ios/ folders
flutter pub get
flutter run                                  # on an emulator or device
```

## Demo accounts (mock backend)
- Student: student@alustudent.com / Student123
- Staff:   staff@alueducation.com / Staff1234
- New registrations need an @alustudent.com or @alueducation.com address and
  land on the verify-email screen (the mock verifies when you tap the button).

## Photo permissions (image_picker)
- iOS: add to ios/Runner/Info.plist
  - NSCameraUsageDescription
  - NSPhotoLibraryUsageDescription
- Android: no extra setup for gallery; camera works via the system app.

## Structure
```
lib/
  main.dart                  wires services -> app (swap to Firebase here)
  app.dart                   providers, theme, AuthGate (role-based routing)
  models/                    AppUser, Incident, enums, stats
  services/                  AuthService / IncidentService (+ mock impls)
  providers/                 AuthProvider, IncidentProvider (ChangeNotifier)
  screens/auth|student|staff|shared
  widgets/                   reusable UI components
  theme/ utils/              colors, validators, formatters, constants
```
