import 'package:flutter/foundation.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

/// The search text and filters used on the Find Tutors screen.
@immutable
class TutorFilter {
  const TutorFilter({
    this.searchQuery = '',
    this.selectedSubjectId,
    this.selectedType,
    this.selectedGrade,
  });

  final String searchQuery;
  final String? selectedSubjectId;
  final SubjectType? selectedType;
  final String? selectedGrade;

  bool get hasFilters =>
      searchQuery.trim().isNotEmpty ||
      selectedSubjectId != null ||
      selectedType != null ||
      selectedGrade != null;

  bool get _hasSubjectFilters =>
      selectedSubjectId != null ||
      selectedType != null ||
      selectedGrade != null;

  /// `null` arguments keep the current value; use the `clear*` flags to unset.
  TutorFilter copyWith({
    String? searchQuery,
    String? selectedSubjectId,
    SubjectType? selectedType,
    String? selectedGrade,
    bool clearSubjectId = false,
    bool clearType = false,
    bool clearGrade = false,
  }) {
    return TutorFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedSubjectId: clearSubjectId
          ? null
          : (selectedSubjectId ?? this.selectedSubjectId),
      selectedType: clearType ? null : (selectedType ?? this.selectedType),
      selectedGrade: clearGrade ? null : (selectedGrade ?? this.selectedGrade),
    );
  }

  bool _subjectMatches(Subject subject) =>
      (selectedSubjectId == null || subject.id == selectedSubjectId) &&
      (selectedType == null || subject.type == selectedType) &&
      (selectedGrade == null || subject.gradeLevel == selectedGrade);
}

/// Pure search/filter function so it is easy to test without Riverpod.
///
/// A single subject has to satisfy every subject filter at once: a tutor who
/// teaches Physics (Grade 11-12) and English Speaking (skill) is not shown for
/// "Skills + Grade 11-12". Results are sorted by rating, best first.
List<TutorProfile> filterTutors({
  required Iterable<TutorProfile> tutors,
  required Iterable<Subject> subjects,
  required TutorFilter filter,
}) {
  final subjectsById = {for (final subject in subjects) subject.id: subject};
  final query = filter.searchQuery.trim().toLowerCase();

  bool matchesSubjectFilters(TutorProfile tutor) {
    if (!filter._hasSubjectFilters) {
      return true;
    }
    return tutor.subjectIds.any((id) {
      final subject = subjectsById[id];
      return subject != null && filter._subjectMatches(subject);
    });
  }

  bool matchesQuery(TutorProfile tutor) {
    if (query.isEmpty) {
      return true;
    }
    final subjectNames = tutor.subjectIds
        .map((id) => subjectsById[id]?.name ?? '')
        .join(' ');
    final haystack =
        '${tutor.name} ${tutor.bio} ${tutor.school} '
                '${tutor.fieldOfStudy} $subjectNames'
            .toLowerCase();
    return haystack.contains(query);
  }

  final matches =
      tutors
          .where((tutor) => matchesSubjectFilters(tutor) && matchesQuery(tutor))
          .toList()
        ..sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));

  return List<TutorProfile>.unmodifiable(matches);
}
