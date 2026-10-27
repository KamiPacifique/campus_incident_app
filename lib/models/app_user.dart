enum UserRole { student, staff }

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.emailVerified,
  });

  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final bool emailVerified;

  bool get isStaff => role == UserRole.staff;

  AppUser copyWith({bool? emailVerified}) => AppUser(
        uid: uid,
        name: name,
        email: email,
        role: role,
        emailVerified: emailVerified ?? this.emailVerified,
      );
}
