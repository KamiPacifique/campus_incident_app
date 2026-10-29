import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service) {
    _user = _service.currentUser;
    _sub = _service.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  final AuthService _service;
  late final StreamSubscription<AppUser?> _sub;

  AppUser? _user;
  bool _isLoading = false;
  String? _error;

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isStaff => _user?.isStaff ?? false;

  Future<bool> signIn(String email, String password) =>
      _run(() => _service.signIn(email, password));

  Future<bool> register(String name, String email, String password) => _run(
        () => _service.register(name: name, email: email, password: password),
      );

  Future<bool> resendVerification() =>
      _run(() => _service.sendVerificationEmail());

  Future<bool> checkVerified() async {
    var verified = false;
    final ok = await _run(() async {
      verified = await _service.reloadUser();
    });
    return ok && verified;
  }

  Future<void> signOut() => _service.signOut();

  void clearError() {
    if (_error == null) return;
    _error = null;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (_) {
      _error = 'Something went wrong. Check your connection and try again.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}