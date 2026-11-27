import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/bookings/presentation/bookings_provider.dart';

class BookSessionScreen extends ConsumerWidget {
  const BookSessionScreen({required this.tutorId, super.key});

  final String tutorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = seedTutors.firstWhere(
      (t) => t.userId == tutorId,
      orElse: () => seedTutors.first,
    );
    final tutorSubjects = seedSubjects
        .where((s) => tutor.subjectIds.contains(s.id))
        .toList();
    final currentUser = seedUsers.first;

    final selection = ref.watch(bookSessionSelectionProvider);
    final selectedSubjectId =
        selection.subjectId ??
        (tutorSubjects.isNotEmpty ? tutorSubjects.first.id : null);
    final selectedTimeSlot =
        selection.timeSlot ??
        (tutor.availability.isNotEmpty ? tutor.availability.first : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Book a Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(tutor.name),
                subtitle: Text(
                  '${tutor.school} • ${tutor.pricePerHour.toStringAsFixed(0)} ETB/hr',
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '1. Choose Subject',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tutorSubjects.map((subject) {
                final isSelected = selectedSubjectId == subject.id;
                return ChoiceChip(
                  label: Text('${subject.name} (${subject.gradeLevel})'),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(bookSessionSelectionProvider.notifier)
                        .selectSubject(subject.id);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            const Text(
              '2. Choose Free Time',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tutor.availability.map((slot) {
                final isSelected = selectedTimeSlot == slot;
                return ChoiceChip(
                  label: Text(slot),
                  selected: isSelected,
                  onSelected: (_) {
                    ref
                        .read(bookSessionSelectionProvider.notifier)
                        .selectTimeSlot(slot);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              icon: const Icon(Icons.send),
              label: const Text('Send Booking Request'),
              onPressed: selectedSubjectId == null || selectedTimeSlot == null
                  ? null
                  : () async {
                      await ref
                          .read(bookingsProvider.notifier)
                          .createBooking(
                            requestedById: currentUser.id,
                            studentName: currentUser.name,
                            tutorId: tutor.userId,
                            subjectId: selectedSubjectId,
                            start: DateTime.now().add(const Duration(days: 1)),
                          );
                      ref.read(bookSessionSelectionProvider.notifier).reset();
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Request sent to ${tutor.name} for $selectedTimeSlot',
                          ),
                        ),
                      );
                      context.go('/bookings');
                    },
            ),
          ],
        ),
      ),
    );
  }
}
