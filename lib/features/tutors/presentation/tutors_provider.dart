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

  /// Saves [profile] (used by Edit Tutor Profile) and updates the list.
  ///
  /// Nothing that can fail runs after the write, so a caller that sees an
  /// error knows the profile was not saved and can safely retry.
  Future<void> updateProfile(TutorProfile profile) async {
    final saved = await _repository.updateTutorProfile(profile);
    if (!ref.mounted) {
      return;
    }
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
      return;
    }
    state = AsyncData([
      for (final tutor in current) tutor.userId == saved.userId ? saved : tutor,
    ]);
  }

  /// Folds a new 1–5 star review into the tutor's average and count.
  ///
  /// Throws an [ArgumentError] if [rating] is outside 1–5 and a [StateError]
  /// if no tutor has [tutorId]. If this throws, the rating was not applied.
  Future<void> recordRating(String tutorId, int rating) async {
    if (rating < 1 || rating > 5) {
      throw ArgumentError.value(rating, 'rating', 'must be between 1 and 5');
    }
    final tutor = await _repository.getTutorById(tutorId);
    if (tutor == null) {
      throw StateError('No tutor with id $tutorId');
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

/// The latest AI suggestion as an [AsyncValue]:
/// - `AsyncData(null)`: nothing asked yet (or cleared)
/// - `AsyncLoading`: a suggestion is being generated
/// - `AsyncData(result)`: the suggestion to show
/// - `AsyncError`: generating failed; [retry] asks again
class AiSuggestionNotifier extends Notifier<AsyncValue<AiSuggestionResult?>> {
  /// Bumped on every request and clear, so a slow, older request can never
  /// overwrite a newer result or a clear.
  int _requestId = 0;
  String _lastProblem = '';

  @override
  AsyncValue<AiSuggestionResult?> build() => const AsyncData(null);

  Future<void> suggest(String problem) async {
    final requestId = ++_requestId;
    if (problem.trim().isEmpty) {
      state = const AsyncData(null);
      return;
    }
    _lastProblem = problem;
    state = const AsyncLoading();

    final result = await AsyncValue.guard(() async {
      final tutors = await ref.read(tutorsProvider.future);
      return ref
          .read(aiSuggestionServiceProvider)
          .suggest(
            problem,
            tutors: tutors,
            subjects: ref.read(subjectsProvider),
          );
    });

    if (ref.mounted && requestId == _requestId) {
      state = result;
    }
  }

  /// Asks again with the last problem, e.g. after an error.
  Future<void> retry() => suggest(_lastProblem);

  void clear() {
    _requestId++;
    state = const AsyncData(null);
  }
}

final aiSuggestionProvider =
    NotifierProvider<AiSuggestionNotifier, AsyncValue<AiSuggestionResult?>>(
      AiSuggestionNotifier.new,
    );
