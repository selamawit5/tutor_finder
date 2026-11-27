import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/features/tutors/presentation/find_tutors_screen.dart';
import 'package:tutor_finder/features/tutors/presentation/tutor_profile_screen.dart';

void main() {
  testWidgets(
    'FindTutorsScreen shows tutors and opens TutorProfileScreen when tapped',
    (tester) async {
      tester.view.physicalSize = const Size(430, 932);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final router = GoRouter(
        initialLocation: '/tutors',
        routes: [
          GoRoute(
            path: '/tutors',
            builder: (_, _) => const FindTutorsScreen(),
            routes: [
              GoRoute(
                path: ':tutorId',
                builder: (_, state) => TutorProfileScreen(
                  tutorId: state.pathParameters['tutorId']!,
                ),
              ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();

      // Scroll down past the filters and AI box to the tutor list
      final listScrollable = find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first;

      await tester.scrollUntilVisible(
        find.text('Abebe Kebede'),
        250,
        scrollable: listScrollable,
      );
      await tester.pumpAndSettle();

      final tutorCard = find.text('Abebe Kebede').first;
      await tester.ensureVisible(tutorCard);
      expect(tutorCard, findsOneWidget);

      // Tap tutor card and verify TutorProfileScreen opens
      await tester.tap(tutorCard);
      await tester.pumpAndSettle();

      expect(find.byType(TutorProfileScreen), findsOneWidget);
      expect(find.text('Abebe Kebede'), findsAtLeastNWidgets(1));
    },
  );
}
