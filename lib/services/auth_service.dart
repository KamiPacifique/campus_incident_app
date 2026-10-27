import 'dart:async';

import '../models/app_user.dart';
import '../utils/constants.dart';

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Contract the UI/providers depend on. Swap the implementation for
/// Firebase Authentication without touching any screen.
abstract class AuthService {
  AppUser? get currentUser;
  Stream<AppUser?> get authStateChanges;

  Future<void> signIn(String email, String password);
  Future<void> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> sendVerificationEmail();

  /// Re-fetches the user so `emailVerified` is up to date.
  Future<void> reloadUser();
  Future<void> signOut();
}

// ---------------------------------------------------------------------------
// In-memory implementation used while building the frontend.
// Demo accounts:
//   student@alustudent.com  / Student123
//   staff@alueducation.com  / Staff1234
// ---------------------------------------------------------------------------
class _Account {
  _Account(this.user, this.password);
  AppUser user;
  final String password;
}

class MockAuthService implements AuthService {
  MockAuthService() {
    _accounts['student@alustudent.com'] = _Account(
      const AppUser(
        uid: 'student-1',
        name: 'Amina Hassan',
        email: 'student@alustudent.com',
        role: UserRole.student,
        emailVerified: true,
      ),
      'Student123',
    );
    _accounts['staff@alueducation.com'] = _Account(
      const AppUser(
        uid: 'staff-1',
        name: 'Jean Mugisha',
        email: 'staff@alueducation.com',
        role: UserRole.staff,
        emailVerified: true,
      ),
      'Staff1234',
    );
  }

  final _controller = StreamController<AppUser?>.broadcast();
  final Map<String, _Account> _accounts = {};
  AppUser? _current;

  @override
  AppUser? get currentUser => _current;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  Future<void> _latency() => Future.delayed(const Duration(milliseconds: 800));

  void _setCurrent(AppUser? user) {
    _current = user;
    _controller.add(user);
  }

  @override
  Future<void> signIn(String email, String password) async {
    await _latency();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthException('Incorrect email or password.');
    }
    _setCurrent(account.user);
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _latency();
    final key = email.trim().toLowerCase();
    if (!allowedEmailDomains.contains(key.split('@').last)) {
      throw const AuthException('Only ALU email addresses can register.');
    }
    if (_accounts.containsKey(key)) {
      throw const AuthException('An account with this email already exists.');
    }
    // Everyone who self-registers is a student. Staff roles are assigned
    // by an administrator, never from the app.
    final account = _Account(
      AppUser(
        uid: 'student-${DateTime.now().millisecondsSinceEpoch}',
        name: name.trim(),
        email: key,
        role: UserRole.student,
        emailVerified: false,
      ),
      password,
    );
    _accounts[key] = account;
    _setCurrent(account.user);
  }

  @override
  Future<void> sendVerificationEmail() async {
    await _latency();
  }

  @override
  Future<void> reloadUser() async {
    await _latency();
    final user = _current;
    if (user == null) return;
    // The mock treats "checking" as the moment the user verified.
    final verified = user.copyWith(emailVerified: true);
    _accounts[user.email]?.user = verified;
    _setCurrent(verified);
  }

  @override
  Future<void> signOut() async {
    _setCurrent(null);
  }
}
