import 'package:flutter/foundation.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

/// What the AI suggests for a student's problem description.
@immutable
class AiSuggestionResult {
  const AiSuggestionResult({
    required this.subjectName,
    required this.suggestedTutors,
    required this.reason,
  });

  /// The matched subject, or `null` when nothing matched and
  /// [suggestedTutors] holds the top-rated tutors instead.
  final String? subjectName;
  final List<TutorProfile> suggestedTutors;
  final String reason;

  bool get hasMatch => subjectName != null;
}

/// Suggests a subject and tutors from a one-sentence problem description.
///
/// Milestone 1 ships a keyword-based fake; a real AI service can implement
/// this interface later.
abstract interface class AiSuggestionService {
  AiSuggestionResult suggest(
    String problem, {
    required List<TutorProfile> tutors,
    required List<Subject> subjects,
  });
}
