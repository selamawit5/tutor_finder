import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/auth/presentation/auth_provider.dart';

void main() {
  group('Authentication and role switching', () {
    test(
      'should allow Student login and switching to Parent and Tutor',
      () async {
        // Arrange: Create an isolated provider container.
        final container = ProviderContainer();
        addTearDown(container.dispose);

        // Get the existing demo users.
        final student = seedUsers.firstWhere(
          (user) => user.role == UserRole.student,
        );

        final parent = seedUsers.firstWhere(
          (user) => user.role == UserRole.parent,
        );

        final tutor = seedUsers.firstWhere(
          (user) => user.role == UserRole.tutor,
        );

        // Get the authentication notifier.
        final authNotifier = container.read(authProvider.notifier);

        // Act 1: Sign in as Student.
        await authNotifier.signIn(email: student.email, role: UserRole.student);

        // Assert 1: Verify Student login.
        expect(container.read(authProvider), equals(student));
        expect(container.read(authProvider)?.role, UserRole.student);

        // Act 2: Switch to Parent.
        await authNotifier.switchDemoUser(parent);

        // Assert 2: Verify Parent role.
        expect(container.read(authProvider), equals(parent));
        expect(container.read(authProvider)?.role, UserRole.parent);

        // Act 3: Switch to Tutor.
        await authNotifier.switchDemoUser(tutor);

        // Assert 3: Verify Tutor role.
        expect(container.read(authProvider), equals(tutor));
        expect(container.read(authProvider)?.role, UserRole.tutor);
      },
    );
  });
}
