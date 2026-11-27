
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/utils/initials.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';
import 'package:tutor_finder/features/reviews/presentation/reviews_provider.dart';
class TutorProfileScreen extends ConsumerWidget {
  const TutorProfileScreen({
    super.key,
    required this.tutorId,
  });

  final String tutorId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tutor = ref.watch(tutorByIdProvider(tutorId));
    final reviewsAsync = ref.watch(reviewsProvider(tutorId));
    final subjects = ref.watch(subjectsProvider);
    final colors = Theme.of(context).colorScheme;

    if (tutor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tutor Profile')),
        body: const Center(
          child: Text('Tutor not found.'),
        ),
      );
    }

    final tutorSubjects = subjects
        .where((subject) => tutor.subjectIds.contains(subject.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutor Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundImage: tutor.photoUrl != null
                  ? NetworkImage(tutor.photoUrl!)
                  : null,
              child: tutor.photoUrl == null
                  ? Text(
                      initialsOf(tutor.name),
                      style: const TextStyle(fontSize: 26),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          Center(
            child: Text(
              tutor.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 6),

          Center(
            child: Text(
              tutor.fieldOfStudy,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _InfoItem(
                    icon: Icons.star,
                    title: tutor.ratingAverage.toStringAsFixed(1),
                    subtitle: '${tutor.ratingCount} reviews',
                  ),
                  _InfoItem(
                    icon: Icons.school,
                    title: tutor.educationStatus.name,
                    subtitle: 'Education',
                  ),
                  _InfoItem(
                    icon: Icons.payments,
                    title: 'ETB ${tutor.pricePerHour.toStringAsFixed(0)}',
                    subtitle: 'Per hour',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'About the tutor',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(tutor.bio),

          const SizedBox(height: 20),

          Text(
            'Education',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text('School: ${tutor.school}'),
          Text('Field of study: ${tutor.fieldOfStudy}'),

          const SizedBox(height: 20),

          Text(
            'Subjects taught',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          if (tutorSubjects.isEmpty)
            const Text('No subjects listed.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: tutorSubjects
                  .map(
                    (subject) => Chip(
                      label: Text(subject.name),
                    ),
                  )
                  .toList(),
            ),

          const SizedBox(height: 20),

          Text(
            'Availability',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),

          if (tutor.availability.isEmpty)
            const Text('Availability not provided.')
          else
            Wrap(
              spacing: 8,
              children: tutor.availability
                  .map((day) => Chip(label: Text(day)))
                  .toList(),
            ),

          const SizedBox(height: 24),

          Text(
            'Student Reviews',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          reviewsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => const Text(
              'Could not load reviews.',
            ),
            data: (reviews) {
              if (reviews.isEmpty) {
                return const Text('No reviews yet.');
              }

              return Column(
                children: reviews.map((review) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(initialsOf(review.reviewerName)),
                      ),
                      title: Text(review.reviewerName),
                      subtitle: Text(review.comment),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 18,
                          ),
                          Text(review.rating.toString()),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          FilledButton.icon(
            onPressed: () {
              context.push('/bookings/new/$tutorId');
            },
            icon: const Icon(Icons.calendar_month),
            label: const Text('Book this tutor'),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
