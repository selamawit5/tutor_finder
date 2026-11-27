import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/auth/domain/auth_repository.dart';

class InMemoryAuthRepository implements AuthRepository {
  final List<AppUser> _users = List<AppUser>.from(seedUsers);

  AppUser? _currentUser = seedUsers.first;

  @override
  AppUser? getCurrentUser() => _currentUser;

  @override
  Future<AppUser> signIn({
    required String email,
    required UserRole role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedEmail.isEmpty) {
      throw const AuthException('Enter your email address.');
    }

    final matchingUsers = _users.where(
      (user) =>
          user.email.toLowerCase() == normalizedEmail && user.role == role,
    );

    if (matchingUsers.isEmpty) {
      throw const AuthException(
        'No account found for this email and selected role.',
      );
    }

    _currentUser = matchingUsers.first;
    return _currentUser!;
  }

  @override
  Future<AppUser> signUp({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    final normalizedName = name.trim();
    final normalizedEmail = email.trim().toLowerCase();

    if (normalizedName.isEmpty) {
      throw const AuthException('Enter your name.');
    }

    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AuthException('Enter a valid email address.');
    }

    final emailAlreadyExists = _users.any(
      (user) => user.email.toLowerCase() == normalizedEmail,
    );

    if (emailAlreadyExists) {
      throw const AuthException('An account with this email already exists.');
    }

    final newUser = AppUser(
      id: 'user-${DateTime.now().microsecondsSinceEpoch}',
      name: normalizedName,
      email: normalizedEmail,
      role: role,
    );

    _users.add(newUser);
    _currentUser = newUser;

    return newUser;
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
  }
}
