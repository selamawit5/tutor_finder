import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/auth/presentation/auth_provider.dart';

class SignInScreen extends ConsumerWidget {
  const SignInScreen({super.key});

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    SignInFormState form,
  ) async {
    final auth = ref.read(authProvider.notifier);
    final formNotifier = ref.read(signInFormProvider.notifier);

    formNotifier.setSubmitting(true);

    var succeeded = false;

    try {
      if (form.isSignUp) {
        await auth.signUp(name: form.name, email: form.email, role: form.role);
      } else {
        await auth.signIn(email: form.email, role: form.role);
      }

      succeeded = true;
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    } finally {
      if (context.mounted) {
        formNotifier.setSubmitting(false);
      }
    }

    if (succeeded && context.mounted) {
      context.go('/tutors');
    }
  }

  Future<void> _demoLogin(
    BuildContext context,
    WidgetRef ref,
    AppUser user,
  ) async {
    try {
      await ref.read(authProvider.notifier).switchDemoUser(user);

      if (!context.mounted) return;

      context.go('/tutors');
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error.toString())));
    }
  }

  String _roleLabel(UserRole role) {
    switch (role) {
      case UserRole.student:
        return 'Student';
      case UserRole.parent:
        return 'Parent';
      case UserRole.tutor:
        return 'Tutor';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signInFormProvider);
    final formNotifier = ref.read(signInFormProvider.notifier);
    final colorScheme = Theme.of(context).colorScheme;

    final demoUsers = seedUsers
        .where((user) => user.id == 'u1' || user.id == 'u2' || user.id == 't1')
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tutor Finder')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 42,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Find trusted tutors for school subjects & skills',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              form.isSignUp ? 'Create your account' : 'Welcome back',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 16),

            if (form.isSignUp) ...[
              TextFormField(
                initialValue: form.name,
                onChanged: formNotifier.setName,
                decoration: const InputDecoration(
                  labelText: 'Full name',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),

              const SizedBox(height: 16),
            ],

            TextFormField(
              initialValue: form.email,
              onChanged: formNotifier.setEmail,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              decoration: const InputDecoration(
                labelText: 'Email address',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Select your role',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: UserRole.values.map((role) {
                return ChoiceChip(
                  label: Text(_roleLabel(role)),
                  selected: form.role == role,
                  onSelected: form.isSubmitting
                      ? null
                      : (_) => formNotifier.setRole(role),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            FilledButton.icon(
              onPressed: form.isSubmitting
                  ? null
                  : () => _submit(context, ref, form),
              icon: form.isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      form.isSignUp ? Icons.person_add_outlined : Icons.login,
                    ),
              label: Text(
                form.isSubmitting
                    ? 'Please wait...'
                    : form.isSignUp
                    ? 'Create Account'
                    : 'Sign In',
              ),
            ),

            const SizedBox(height: 12),

            Center(
              child: TextButton(
                onPressed: form.isSubmitting ? null : formNotifier.toggleMode,
                child: Text(
                  form.isSignUp
                      ? 'Already have an account? Sign In'
                      : 'New to Tutor Finder? Create Account',
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 16),

            Text(
              'Quick Demo Login',
              style: Theme.of(context).textTheme.titleMedium,
            ),

            const SizedBox(height: 8),

            const Text('Choose a sample account to explore the application.'),

            const SizedBox(height: 16),

            ...demoUsers.map((user) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: form.isSubmitting
                        ? null
                        : () => _demoLogin(context, ref, user),
                    icon: const Icon(Icons.person_outline),
                    label: Text('${user.name} (${_roleLabel(user.role)})'),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
