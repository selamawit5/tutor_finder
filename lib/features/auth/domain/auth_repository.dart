import 'package:tutor_finder/features/auth/domain/app_user.dart';

abstract interface class AuthRepository {
  AppUser? getCurrentUser();

  Future<AppUser> signIn({required String email, required UserRole role});

  Future<AppUser> signUp({
    required String name,
    required String email,
    required UserRole role,
  });

  Future<void> signOut();
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
