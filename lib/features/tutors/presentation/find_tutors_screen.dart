import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/utils/initials.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/presentation/ai_suggestion_box.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

class FindTutorsScreen extends ConsumerStatefulWidget {
  const FindTutorsScreen({super.key});

  @override
  ConsumerState<FindTutorsScreen> createState() =>
      _FindTutorsScreenState();
}

class _FindTutorsScreenState extends ConsumerState<FindTutorsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    ref.read(tutorFilterProvider.notifier).setSearchQuery('');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tutorsAsync = ref.watch(tutorsProvider);
    final tutors = ref.watch(filteredTutorsProvider);
    final subjects = ref.watch(subjectsProvider);
    final filter = ref.watch(tutorFilterProvider);
    final colors = Theme.of(context).colorScheme;

    final grades =
        subjects.map((subject) => subject.gradeLevel).toSet().toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('Find Tutors'), centerTitle: false),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Find the right tutor for you',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 6),
          Text(
            'Search for tutors by name, subject, or school.',
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 16),

          // Search
          TextField(
  controller: _searchController,
  onChanged: (value) {
    ref.read(tutorFilterProvider.notifier).setSearchQuery(value);
  },
            decoration: const InputDecoration(
              hintText: 'Search tutors or subjects...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),

          // AI suggestion
          const AiSuggestionBox(),
          const SizedBox(height: 20),

          // Subject filter
          Text(
            'Filter by subject',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: filter.selectedSubjectId,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
            hint: const Text('All subjects'),
            items: subjects.map((subject) {
              return DropdownMenuItem(
                value: subject.id,
                child: Text(subject.name),
              );
            }).toList(),
            onChanged: (value) {
              ref.read(tutorFilterProvider.notifier).setSubject(value);
            },
          ),
          const SizedBox(height: 16),

          // Tutor type filter
          Text('Tutor type', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('All'),
                selected: filter.selectedType == null,
                onSelected: (_) {
                  ref.read(tutorFilterProvider.notifier).setType(null);
                },
              ),
              FilterChip(
                label: const Text('School subjects'),
                selected: filter.selectedType == SubjectType.schoolSubject,
                onSelected: (selected) {
                  ref
                      .read(tutorFilterProvider.notifier)
                      .setType(selected ? SubjectType.schoolSubject : null);
                },
              ),
              FilterChip(
                label: const Text('Skills'),
                selected: filter.selectedType == SubjectType.skill,
                onSelected: (selected) {
                  ref
                      .read(tutorFilterProvider.notifier)
                      .setType(selected ? SubjectType.skill : null);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grade filter
          Text('Grade level', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('All grades'),
                selected: filter.selectedGrade == null,
                onSelected: (_) {
                  ref.read(tutorFilterProvider.notifier).setGrade(null);
                },
              ),
              for (final grade in grades)
                ChoiceChip(
                  label: Text(grade),
                  selected: filter.selectedGrade == grade,
                  onSelected: (selected) {
                    ref
                        .read(tutorFilterProvider.notifier)
                        .setGrade(selected ? grade : null);
                  },
                ),
            ],
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Available tutors',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Text(
                '${tutors.length} found',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filter.hasFilters)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
  _searchController.clear();
  ref.read(tutorFilterProvider.notifier).clear();
},
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear filters'),
              ),
            ),

          // Loading state
          if (tutorsAsync.isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          // Error state
          else if (tutorsAsync.hasError)
            Column(
              children: [
                const Icon(Icons.error_outline, size: 40),
                const SizedBox(height: 8),
                const Text('Could not load tutors.'),
                TextButton(
                  onPressed: () => ref.invalidate(tutorsProvider),
                  child: const Text('Try again'),
                ),
              ],
            )
          // Empty state
          else if (tutors.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 40),
                  SizedBox(height: 8),
                  Text('No tutors found.'),
                  Text('Try changing your search or filters.'),
                ],
              ),
            )
          // Tutor list
          else
            for (final tutor in tutors)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(14),
                  leading: CircleAvatar(
                    radius: 26,
                    child: Text(initialsOf(tutor.name)),
                  ),
                  title: Text(
                    tutor.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tutor.fieldOfStudy),
                        Text(tutor.school),
                        const SizedBox(height: 6),
                        Text(
                          '★ ${tutor.ratingAverage.toStringAsFixed(1)} '
                          '(${tutor.ratingCount} reviews)',
                        ),
                        Text(
                          'ETB ${tutor.pricePerHour.toStringAsFixed(0)} / hour',
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push('/tutors/${tutor.userId}');
                  },
                ),
              ),
        ],
      ),
    );
  }
}
