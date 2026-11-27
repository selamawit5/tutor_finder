import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/domain/app_user.dart';
import 'package:tutor_finder/features/auth/presentation/auth_provider.dart';
import 'package:tutor_finder/features/auth/presentation/sign_in_screen.dart';
import 'package:tutor_finder/features/bookings/presentation/book_session_screen.dart';
import 'package:tutor_finder/features/bookings/presentation/my_bookings_screen.dart';
import 'package:tutor_finder/features/reviews/presentation/leave_review_screen.dart';
import 'package:tutor_finder/features/tutors/presentation/edit_tutor_profile_screen.dart';
import 'package:tutor_finder/features/tutors/presentation/find_tutors_screen.dart';
import 'package:tutor_finder/features/tutors/presentation/tutor_profile_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (_, _) => const SignInScreen()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) {
          return _AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/tutors',
                builder: (_, _) => const FindTutorsScreen(),
                routes: [
                  GoRoute(
                    path: ':tutorId',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => TutorProfileScreen(
                      tutorId: state.pathParameters['tutorId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'book',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => BookSessionScreen(
                          tutorId: state.pathParameters['tutorId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, state) => EditTutorProfileScreen(
                          tutorId: state.pathParameters['tutorId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/bookings',
                builder: (_, _) => const MyBookingsScreen(),
                routes: [
                  GoRoute(
                    path: ':bookingId/review',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => LeaveReviewScreen(
                      bookingId: state.pathParameters['bookingId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile/edit',
                builder: (_, _) {
                  return Consumer(
                    builder: (_, ref, _) {
                      final user = ref.watch(authProvider);
                      final tutorId =
                          (user != null && user.role == UserRole.tutor)
                          ? user.id
                          : seedTutors.first.userId;
                      return EditTutorProfileScreen(tutorId: tutorId);
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Find Tutors',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'My Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Edit Profile',
          ),
        ],
      ),
    );
  }
}
