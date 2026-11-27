import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/features/auth/data/in_memory_auth_repository.dart';
import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return InMemoryAuthRepository();
});

final authProvider = NotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthNotifier extends Notifier<AppUser?> {
  late AuthRepository _repository;

  @override
  AppUser? build() {
    _repository = ref.watch(authRepositoryProvider);
    return _repository.getCurrentUser();
  }

  Future<void> signIn({required String email, required UserRole role}) async {
    state = await _repository.signIn(email: email, role: role);
  }

  Future<void> signUp({
    required String name,
    required String email,
    required UserRole role,
  }) async {
    state = await _repository.signUp(name: name, email: email, role: role);
  }

  Future<void> switchDemoUser(AppUser user) async {
    state = await _repository.signIn(email: user.email, role: user.role);
  }

  Future<void> signOut() async {
    await _repository.signOut();
    state = null;
  }
}

class SignInFormState {
  const SignInFormState({
    this.name = '',
    this.email = '',
    this.role = UserRole.student,
    this.isSignUp = false,
    this.isSubmitting = false,
  });

  final String name;
  final String email;
  final UserRole role;
  final bool isSignUp;
  final bool isSubmitting;

  SignInFormState copyWith({
    String? name,
    String? email,
    UserRole? role,
    bool? isSignUp,
    bool? isSubmitting,
  }) {
    return SignInFormState(
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      isSignUp: isSignUp ?? this.isSignUp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

final signInFormProvider =
    NotifierProvider<SignInFormNotifier, SignInFormState>(
      SignInFormNotifier.new,
    );

class SignInFormNotifier extends Notifier<SignInFormState> {
  @override
  SignInFormState build() => const SignInFormState();

  void setName(String value) {
    state = state.copyWith(name: value);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value);
  }

  void setRole(UserRole value) {
    state = state.copyWith(role: value);
  }

  void toggleMode() {
    state = state.copyWith(isSignUp: !state.isSignUp);
  }

  void setSubmitting(bool value) {
    state = state.copyWith(isSubmitting: value);
  }
}
