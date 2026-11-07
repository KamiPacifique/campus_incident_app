# Campus Incident Reporting App

A Flutter mobile app for ALU students to report campus problems, such as broken facilities, water shortages, power outages, damaged furniture, sanitation problems and safety concerns, and to follow each report until it is fixed. Authorised campus staff review incoming reports and update their status.

Built with **Flutter**, **Provider** for state management, and **Firebase** (Authentication, Cloud Firestore, Storage).

---

## Features

### Students
- Register and sign in with an ALU email (`@alustudent.com` or `@alueducation.com`), with **email verification** required before entering the app
- Submit an incident report with a **category**, title, description, campus **location** and an optional **photo** (camera or gallery)
- **Quick report** shortcuts on the home screen that open the form with a category already selected
- Browse your own reports, **search** by text and **filter** by status or category
- View report details with a **status timeline** (Submitted → In Progress → Resolved)
- Withdraw a report while it is still *Submitted*

### Campus staff
- Staff dashboard showing **all** reports with live counts by status
- Search and filter every report, including who reported it and when
- **Update the status** of any report from its details screen

### General
- Role-based routing: signed out → login, unverified → verify email, then the student or staff area
- Form validation, loading indicators, error banners with retry, and empty states
- Consistent design system: a teal brand colour, coral for "create report" actions, and distinct colours for each status and category

---

## User roles and access control

| Role | How it is assigned | Can do |
|------|--------------------|--------|
| **Student** | Default for every new registration | Create reports, view and withdraw their own reports |
| **Staff** | Set manually in Firestore (`users/{uid}.role = "staff"`) | View all reports, update report status |

A user can never give themselves the staff role from the app: registration always writes `role: "student"`. The staff-only UI is shown only when the signed-in profile has `role == "staff"`. Firestore Security Rules should enforce the same restrictions on the backend (see [Firebase setup](#firebase-setup)).

---

## Architecture

```
UI (screens / widgets)
        │  context.watch / context.read
        ▼
Providers (ChangeNotifier)   ← state + business logic
  AuthProvider, IncidentProvider
        │
        ▼
Services (abstract interfaces)
  AuthService, IncidentService
        │
        ├── FirebaseAuthService   (Firebase Auth + Firestore users collection)
        └── MockIncidentService   (in-memory, being replaced by Firestore)
```

- **Screens** only render state and forward user actions.
- **Providers** hold app-wide state (current user, incident list, filters, loading and error flags) and notify every listening screen, so a status change appears on all screens at once.
- **Services** hide the backend behind an interface, so the UI never talks to Firebase directly and a mock can be swapped in for testing.
- `IncidentProvider` is a `ChangeNotifierProxyProvider` of `AuthProvider`, so it reloads data whenever the signed-in user changes.

### Project structure

```
lib/
  main.dart            Firebase init, chooses service implementations
  app.dart             Providers, theme, AuthGate (role-based routing)
  firebase_options.dart
  models/              AppUser, Incident, IncidentStatus, IncidentCategory, stats
  services/            AuthService / IncidentService interfaces + implementations
  providers/           AuthProvider, IncidentProvider
  screens/
    auth/              login, register, verify email
    student/           home, report form, my reports, bottom-nav shell
    staff/             dashboard, shell
    shared/            incident details, profile
  widgets/             reusable UI (incident card, status chip, timeline, filters, …)
  theme/               colours, gradients, shadows, ThemeData
  utils/               validators, formatters, constants (locations, email domains)
```

---

## Data model (Firestore)

```
users/{uid}
  name:       string
  email:      string
  role:       "student" | "staff"
  createdAt:  timestamp

incidents/{incidentId}
  title:        string
  description:  string
  category:     "facilities" | "water" | "electricity" | "safety" | "sanitation" | "furniture"
  location:     string
  status:       "submitted" | "inProgress" | "resolved"
  reporterId:   string   (uid)
  reporterName: string
  createdAt:    timestamp
  history:      [{ status, at }]   status timeline
  imageUrl:     string?            Firebase Storage download URL
```

Photos are stored in Firebase Storage under a path per incident, and only the download URL is saved in Firestore.

---

## Getting started

### Prerequisites
- Flutter SDK 3.27 or newer (Dart ≥ 3.3)
- Android Studio with an Android emulator, or Xcode with an iOS simulator
- A Firebase project (only needed if you want to use your own instead of the configured one)

### Run

```bash
git clone https://github.com/KamiPacifique/campus_incident_app.git
cd campus_incident_app
flutter pub get
flutter run          # with an emulator running or a device connected
```

> The app targets **Android and iOS**. It is not intended to be run in a browser.

### Firebase setup

The repository is already connected to a Firebase project (`firebase_options.dart`, `google-services.json`, `GoogleService-Info.plist`). To use your own project instead:

1. Create a Firebase project and enable **Authentication → Email/Password**, **Cloud Firestore** and **Storage**.
2. Install the FlutterFire CLI and run:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
3. Publish Security Rules that:
   - allow users to read and write only their own `users/{uid}` document, without being able to change `role`
   - allow verified users to create incidents where `reporterId == request.auth.uid`
   - allow only users whose profile has `role == "staff"` to change `status`
   - allow a reporter to delete their own incident only while it is `submitted`

### Creating a staff account
1. Register in the app with an ALU email you can access, then verify it from your inbox.
2. In the Firebase Console open **Firestore → users → (that user's uid)**.
3. Change `role` from `"student"` to `"staff"`.
4. Sign out and sign back in to open the staff dashboard.

### Photo permissions
- **iOS:** `ios/Runner/Info.plist` must contain `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`.
- **Android:** no extra setup; the camera opens through the system camera app.

---

## Testing

```bash
flutter analyze
flutter test
```

Because the services are interfaces, widget tests can run the full app against `MockAuthService` and `MockIncidentService` without a network connection.

---

## Tech stack

| Purpose | Package |
|---------|---------|
| State management | `provider` |
| Authentication | `firebase_auth` |
| Database | `cloud_firestore` |
| Photo storage | `firebase_storage` |
| Photo capture | `image_picker` |
| Date formatting | `intl` |

---

## Author

Kami Pacifique, African Leadership University
