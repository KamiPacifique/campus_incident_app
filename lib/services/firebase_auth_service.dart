import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../models/app_user.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({fb.FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? fb.FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _db;

  // The real user (with role) always arrives through the stream.
  @override
  AppUser? get currentUser => null;

  @override
  Stream<AppUser?> get authStateChanges =>
      _auth.userChanges().asyncMap(_toAppUser);

  /// Builds our AppUser from the Firebase user plus the role stored in
  /// Firestore (users/{uid}). Defaults to student if the profile is missing.
  Future<AppUser?> _toAppUser(fb.User? user) async {
    if (user == null) return null;
    var role = UserRole.student;
    String? name;
    try {
      final snap = await _db.collection('users').doc(user.uid).get();
      final data = snap.data();
      if (data != null) {
        role = data['role'] == 'staff' ? UserRole.staff : UserRole.student;
        name = data['name'] as String?;
      }
    } catch (_) {
      // Fall back to student if the profile can't be read.
    }
    final email = user.email ?? '';
    return AppUser(
      uid: user.uid,
      name: name ??
          user.displayName ??
          (email.contains('@') ? email.split('@').first : 'Student'),
      email: email,
      role: role,
      emailVerified: user.emailVerified,
    );
  }

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (!allowedEmailDomains.contains(key.split('@').last)) {
      throw const AuthException('Only ALU email addresses can register.');
    }

    fb.User? created;
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: key,
        password: password,
      );
      created = cred.user!;

      await created.updateDisplayName(name.trim());
      await _db.collection('users').doc(created.uid).set({
        'name': name.trim(),
        'email': key,
        'role': 'student', // staff roles are assigned in the Console only
        'createdAt': FieldValue.serverTimestamp(),
      });
      await created.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e));
    } on FirebaseException catch (e) {
      // Profile write failed: remove the half-created account so the
      // student can try again cleanly.
      await created?.delete().catchError((_) {});
      throw AuthException('Could not save your profile (${e.code}). Try again.');
    }
  }

  @override
  Future<void> signIn(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      // Repair case: account exists but its profile document was never saved.
      final user = cred.user!;
      final ref = _db.collection('users').doc(user.uid);
      final snap = await ref.get();
      if (!snap.exists) {
        await ref.set({
          'name': user.displayName ?? user.email!.split('@').first,
          'email': user.email,
          'role': 'student',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e));
    } on FirebaseException catch (e) {
      throw AuthException('Could not load your profile (${e.code}).');
    }
  }

  @override
  Future<void> sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(_authMessage(e));
    }
  }

  @override
  Future<bool> reloadUser() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    await user.reload();
    // Refresh the token so Security Rules see email_verified = true.
    await _auth.currentUser?.getIdToken(true);
    return _auth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> signOut() => _auth.signOut();

  String _authMessage(fb.FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'That email address is not valid.';
      case 'weak-password':
        return 'Choose a stronger password (8+ characters).';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a moment and try again.';
      case 'network-request-failed':
        return 'No connection. Check your internet and try again.';
      default:
        return 'Authentication failed (${e.code}).';
    }
  }
}