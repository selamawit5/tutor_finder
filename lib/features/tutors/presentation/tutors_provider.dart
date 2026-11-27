import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/features/tutors/data/fake_ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/data/in_memory_tutor_repository.dart';
import 'package:tutor_finder/features/tutors/domain/ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_filter.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_repository.dart';

final tutorRepositoryProvider = Provider<TutorRepository>(
  (ref) => InMemoryTutorRepository(),
);

final aiSuggestionServiceProvider = Provider<AiSuggestionService>(
  (ref) => const FakeAiSuggestionService(),
);

// ---------------------------------------------------------------------------
// Tutors
// ---------------------------------------------------------------------------

class TutorsNotifier extends AsyncNotifier<List<TutorProfile>> {
  TutorRepository get _repository => ref.read(tutorRepositoryProvider);

  @override
  Future<List<TutorProfile>> build() =>
      ref.watch(tutorRepositoryProvider).getTutors();

  /// Saves [profile] (used by Edit Tutor Profile) and refreshes the list.
  Future<void> updateProfile(TutorProfile profile) async {
    await _repository.updateTutorProfile(profile);
    final tutors = await _repository.getTutors();
    if (ref.mounted) {
      state = AsyncData(tutors);
    }
  }

  /// Folds a new 1–5 star review into the tutor's average and count.
  Future<void> recordRating(String tutorId, int rating) async {
    final tutor = await _repository.getTutorById(tutorId);
    if (tutor == null) {
      return;
    }
    final count = tutor.ratingCount + 1;
    final average = (tutor.ratingAverage * tutor.ratingCount + rating) / count;
    await updateProfile(
      tutor.copyWith(ratingAverage: average, ratingCount: count),
    );
  }
}

final tutorsProvider =
    AsyncNotifierProvider<TutorsNotifier, List<TutorProfile>>(
      TutorsNotifier.new,
    );

/// A single tutor, or `null` while loading or if the id is unknown.
final tutorByIdProvider = Provider.family<TutorProfile?, String>((ref, id) {
  final tutors = ref.watch(tutorsProvider).value ?? const <TutorProfile>[];
  for (final tutor in tutors) {
    if (tutor.userId == id) {
      return tutor;
    }
  }
  return null;
});

// ---------------------------------------------------------------------------
// Subjects
// ---------------------------------------------------------------------------

final subjectsProvider = Provider<List<Subject>>(
  (ref) => ref.watch(tutorRepositoryProvider).getSubjects(),
);

final subjectByIdProvider = Provider.family<Subject?, String>((ref, id) {
  for (final subject in ref.watch(subjectsProvider)) {
    if (subject.id == id) {
      return subject;
    }
  }
  return null;
});

// ---------------------------------------------------------------------------
// Search & filters
// ---------------------------------------------------------------------------

class TutorFilterNotifier extends Notifier<TutorFilter> {
  @override
  TutorFilter build() => const TutorFilter();

  void setSearchQuery(String query) =>
      state = state.copyWith(searchQuery: query);

  void setSubject(String? subjectId) => state = subjectId == null
      ? state.copyWith(clearSubjectId: true)
      : state.copyWith(selectedSubjectId: subjectId);

  void setType(SubjectType? type) => state = type == null
      ? state.copyWith(clearType: true)
      : state.copyWith(selectedType: type);

  void setGrade(String? grade) => state = grade == null
      ? state.copyWith(clearGrade: true)
      : state.copyWith(selectedGrade: grade);

  void clear() => state = const TutorFilter();
}

final tutorFilterProvider = NotifierProvider<TutorFilterNotifier, TutorFilter>(
  TutorFilterNotifier.new,
);

final filteredTutorsProvider = Provider<List<TutorProfile>>((ref) {
  return filterTutors(
    tutors: ref.watch(tutorsProvider).value ?? const [],
    subjects: ref.watch(subjectsProvider),
    filter: ref.watch(tutorFilterProvider),
  );
});

// ---------------------------------------------------------------------------
// AI suggestion
// ---------------------------------------------------------------------------

class AiSuggestionNotifier extends Notifier<AiSuggestionResult?> {
  @override
  AiSuggestionResult? build() => null;

  Future<void> suggest(String problem) async {
    if (problem.trim().isEmpty) {
      state = null;
      return;
    }
    final tutors = await ref.read(tutorsProvider.future);
    if (!ref.mounted) {
      return;
    }
    state = ref
        .read(aiSuggestionServiceProvider)
        .suggest(problem, tutors: tutors, subjects: ref.read(subjectsProvider));
  }

  void clear() => state = null;
}

final aiSuggestionProvider =
    NotifierProvider<AiSuggestionNotifier, AiSuggestionResult?>(
      AiSuggestionNotifier.new,
    );
