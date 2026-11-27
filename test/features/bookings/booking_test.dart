import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/presentation/auth_provider.dart';
import 'package:tutor_finder/features/bookings/data/in_memory_booking_repository.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/bookings/presentation/book_session_screen.dart';
import 'package:tutor_finder/features/bookings/presentation/bookings_provider.dart';
import 'package:tutor_finder/features/bookings/presentation/my_bookings_screen.dart';

void main() {
  group('Booking repository and provider tests', () {
    test(
      'InMemoryBookingRepository creates and updates booking statuses',
      () async {
        final repo = InMemoryBookingRepository();

        final initialBookings = await repo.getBookings();
        expect(initialBookings.length, seedBookings.length);

        final created = await repo.createBooking(
          requestedById: 'u1',
          studentName: 'Semhal Dawit',
          tutorId: 't1',
          subjectId: 's1',
          start: DateTime(2026, 12, 1, 16, 0),
          durationMinutes: 60,
        );

        expect(created.status, BookingStatus.pending);
        expect(created.tutorId, 't1');

        final afterCreate = await repo.getBookings();
        expect(afterCreate.length, seedBookings.length + 1);
        expect(afterCreate.first.id, created.id);

        final accepted = await repo.updateStatus(
          bookingId: created.id,
          status: BookingStatus.accepted,
        );
        expect(accepted.status, BookingStatus.accepted);

        final completed = await repo.updateStatus(
          bookingId: created.id,
          status: BookingStatus.completed,
        );
        expect(completed.status, BookingStatus.completed);
      },
    );

    test(
      'InMemoryBookingRepository throws StateError for unknown booking id',
      () async {
        final repo = InMemoryBookingRepository();

        await expectLater(
          repo.updateStatus(
            bookingId: 'missing-id',
            status: BookingStatus.declined,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'bookingsProvider creates and updates bookings in Riverpod state',
      () async {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        final initial = await container.read(bookingsProvider.future);
        expect(initial.length, seedBookings.length);

        await container
            .read(bookingsProvider.notifier)
            .createBooking(
              requestedById: 'u1',
              studentName: 'Semhal Dawit',
              tutorId: 't2',
              subjectId: 's2',
              start: DateTime(2026, 12, 2, 17, 0),
            );

        final afterCreate = await container.read(bookingsProvider.future);
        expect(afterCreate.length, seedBookings.length + 1);
        expect(afterCreate.first.tutorId, 't2');
        expect(afterCreate.first.status, BookingStatus.pending);

        await container
            .read(bookingsProvider.notifier)
            .updateStatus(
              bookingId: afterCreate.first.id,
              status: BookingStatus.declined,
            );

        final afterDecline = await container.read(bookingsProvider.future);
        expect(afterDecline.first.status, BookingStatus.declined);
      },
    );
  });

  group('Booking screen widget tests', () {
    testWidgets(
      'BookSessionScreen saves selected subject and time slot and navigates',
      (tester) async {
        final router = GoRouter(
          initialLocation: '/tutors/t1/book',
          routes: [
            GoRoute(
              path: '/tutors/:tutorId/book',
              builder: (_, state) =>
                  BookSessionScreen(tutorId: state.pathParameters['tutorId']!),
            ),
            GoRoute(
              path: '/bookings',
              builder: (_, _) =>
                  const Scaffold(body: Center(child: Text('My Bookings Page'))),
            ),
          ],
        );
        addTearDown(router.dispose);

        await tester.pumpWidget(
          ProviderScope(child: MaterialApp.router(routerConfig: router)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Book a Session'), findsOneWidget);
        expect(find.text('Abebe Kebede'), findsOneWidget);
        expect(find.text('Physics (Grade 11-12)'), findsOneWidget);
        expect(find.text('Mathematics (Grade 9-12)'), findsOneWidget);
        expect(find.text('Wed 16:00'), findsOneWidget);

        await tester.tap(find.text('Mathematics (Grade 9-12)'));
        await tester.pump();
        await tester.tap(find.text('Wed 16:00'));
        await tester.pump();

        final sendButton = find.text('Send Booking Request');
        await tester.ensureVisible(sendButton);
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        expect(
          find.text('Request sent to Abebe Kebede for Wed 16:00'),
          findsOneWidget,
        );
        expect(find.text('My Bookings Page'), findsOneWidget);

        final container = ProviderScope.containerOf(
          tester.element(find.text('My Bookings Page')),
        );
        final bookings = await container.read(bookingsProvider.future);
        expect(bookings.length, seedBookings.length + 1);
        expect(bookings.first.subjectId, 's3');
        expect(bookings.first.start.weekday, DateTime.wednesday);
        expect(bookings.first.start.hour, 16);
        expect(bookings.first.start.minute, 0);
      },
    );

    testWidgets(
      'MyBookingsScreen filters by user and lets tutor accept and complete request',
      (tester) async {
        await tester.pumpWidget(
          const ProviderScope(child: MaterialApp(home: MyBookingsScreen())),
        );
        await tester.pumpAndSettle();

        // Signed in as Semhal Dawit (student u1) by default
        expect(find.text('Tutor: Abebe Kebede'), findsOneWidget);
        expect(find.text('Tutor: Hanna Mekonnen'), findsOneWidget);
        expect(find.text('Leave a Review'), findsOneWidget);

        // Switch to tutor Abebe Kebede (t1)
        final container = ProviderScope.containerOf(
          tester.element(find.byType(MyBookingsScreen)),
        );
        await container
            .read(authProvider.notifier)
            .switchDemoUser(seedUsers[2]);
        await tester.pumpAndSettle();

        // Open Tutor Requests tab and test Accept -> Mark Completed
        await tester.tap(find.text('Tutor Requests'));
        await tester.pumpAndSettle();

        expect(find.text('Student: Semhal Dawit'), findsOneWidget);
        expect(find.text('PENDING'), findsOneWidget);

        await tester.tap(find.text('Accept'));
        await tester.pumpAndSettle();

        expect(find.text('ACCEPTED'), findsOneWidget);
        expect(find.text('Mark Completed'), findsOneWidget);

        await tester.tap(find.text('Mark Completed'));
        await tester.pumpAndSettle();

        expect(find.text('COMPLETED'), findsOneWidget);
      },
    );
  });
}
