import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/auth/presentation/auth_provider.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/bookings/presentation/bookings_provider.dart';

class MyBookingsScreen extends ConsumerWidget {
  const MyBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final bookingsAsync = ref.watch(bookingsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Bookings'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Student / Parent'),
              Tab(text: 'Tutor Requests'),
            ],
          ),
        ),
        body: currentUser == null
            ? const Center(child: Text('Please sign in to view your bookings.'))
            : bookingsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
                data: (bookings) {
                  final studentBookings = bookings
                      .where((b) => b.requestedById == currentUser.id)
                      .toList();
                  final tutorBookings = bookings
                      .where((b) => b.tutorId == currentUser.id)
                      .toList();

                  return TabBarView(
                    children: [
                      _BookingList(
                        bookings: studentBookings,
                        isTutorView: false,
                        emptyMessage:
                            'No bookings requested by ${currentUser.name} yet.',
                      ),
                      _BookingList(
                        bookings: tutorBookings,
                        isTutorView: true,
                        emptyMessage:
                            'No booking requests for ${currentUser.name} yet.',
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _BookingList extends ConsumerWidget {
  const _BookingList({
    required this.bookings,
    required this.isTutorView,
    required this.emptyMessage,
  });

  final List<Booking> bookings;
  final bool isTutorView;
  final String emptyMessage;

  String _tutorName(String tutorId) {
    final match = seedTutors.where((t) => t.userId == tutorId);
    return match.isEmpty ? tutorId : match.first.name;
  }

  String _subjectName(String subjectId) {
    final match = seedSubjects.where((s) => s.id == subjectId);
    return match.isEmpty ? subjectId : match.first.name;
  }

  String _formatDateTime(DateTime dt) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[dt.weekday - 1];
    final month = dt.month.toString().padLeft(2, '0');
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$dayName $day/$month at $hour:$minute';
  }

  Color _statusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.blue;
      case BookingStatus.declined:
      case BookingStatus.cancelled:
        return Colors.red;
      case BookingStatus.completed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(emptyMessage, textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final booking = bookings[index];
        final tutorName = _tutorName(booking.tutorId);
        final subjectName = _subjectName(booking.subjectId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        isTutorView
                            ? 'Student: ${booking.studentName}'
                            : 'Tutor: $tutorName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Chip(
                      label: Text(
                        booking.status.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
                      ),
                      backgroundColor: _statusColor(booking.status),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Subject: $subjectName • ${booking.durationMinutes} min'),
                const SizedBox(height: 2),
                Text('Time: ${_formatDateTime(booking.start)}'),
                const SizedBox(height: 10),
                if (!isTutorView && booking.status == BookingStatus.completed)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.star_outline),
                    label: const Text('Leave a Review'),
                    onPressed: () {
                      context.push('/bookings/${booking.id}/review');
                    },
                  ),
                if (isTutorView && booking.status == BookingStatus.pending)
                  Row(
                    children: [
                      FilledButton(
                        onPressed: () {
                          ref
                              .read(bookingsProvider.notifier)
                              .updateStatus(
                                bookingId: booking.id,
                                status: BookingStatus.accepted,
                              );
                        },
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () {
                          ref
                              .read(bookingsProvider.notifier)
                              .updateStatus(
                                bookingId: booking.id,
                                status: BookingStatus.declined,
                              );
                        },
                        child: const Text('Decline'),
                      ),
                    ],
                  ),
                if (isTutorView && booking.status == BookingStatus.accepted)
                  FilledButton(
                    onPressed: () {
                      ref
                          .read(bookingsProvider.notifier)
                          .updateStatus(
                            bookingId: booking.id,
                            status: BookingStatus.completed,
                          );
                    },
                    child: const Text('Mark Completed'),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
