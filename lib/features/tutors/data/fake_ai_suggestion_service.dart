import 'package:tutor_finder/features/tutors/domain/ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

/// Keyword-based stand-in for a real AI. No network call is made.
///
/// Each subject is scored by how many of its keywords appear as whole words
/// in the problem; the highest score wins and ties keep the earlier subject.
class FakeAiSuggestionService implements AiSuggestionService {
  const FakeAiSuggestionService();

  /// Extra words that point at a subject, on top of the words in its name.
  /// Keyed by the lower-case subject name.
  static const Map<String, List<String>> _extraKeywords = {
    'physics': ['newton', 'force', 'motion', 'mechanics', 'energy'],
    'chemistry': ['stoichiometry', 'chemical', 'reaction', 'molecule'],
    'mathematics': [
      'math',
      'maths',
      'algebra',
      'calculus',
      'geometry',
      'equation',
    ],
    'english speaking': ['english', 'speaking', 'language', 'grammar'],
    'python programming': [
      'python',
      'programming',
      'coding',
      'computer',
      'software',
    ],
  };

  static const _fallbackCount = 3;

  @override
  AiSuggestionResult suggest(
    String problem, {
    required List<TutorProfile> tutors,
    required List<Subject> subjects,
  }) {
    final text = problem.toLowerCase();

    Subject? bestSubject;
    var bestScore = 0;
    var bestKeywords = <String>[];

    for (final subject in subjects) {
      var score = 0;
      final matched = <String>[];
      for (final keyword in _keywordsFor(subject)) {
        final hits = _countWholeWord(text, keyword);
        if (hits > 0) {
          score += hits;
          matched.add(keyword);
        }
      }
      if (score > bestScore) {
        bestScore = score;
        bestSubject = subject;
        bestKeywords = matched;
      }
    }

    if (bestSubject == null) {
      return AiSuggestionResult(
        subjectName: null,
        suggestedTutors: List<TutorProfile>.unmodifiable(
          _byRating(tutors).take(_fallbackCount),
        ),
        reason:
            'No subject matched your description, '
            'so here are our top-rated tutors.',
      );
    }

    final subject = bestSubject;
    return AiSuggestionResult(
      subjectName: subject.name,
      suggestedTutors: List<TutorProfile>.unmodifiable(
        _byRating(tutors.where((t) => t.subjectIds.contains(subject.id))),
      ),
      reason:
          'You mentioned ${_quoteList(bestKeywords)}, '
          'so we suggest ${subject.name}.',
    );
  }

  static Set<String> _keywordsFor(Subject subject) {
    final name = subject.name.toLowerCase();
    return {
      ...name.split(RegExp(r'\s+')).where((word) => word.length > 2),
      ...?_extraKeywords[name],
    };
  }

  /// Whole-word hits, allowing a plural "s"/"es": "math" matches "maths" but
  /// not "aftermath", and "newton" matches "Newton's".
  static int _countWholeWord(String text, String keyword) {
    final pattern = RegExp('\\b${RegExp.escape(keyword)}(?:e?s)?\\b');
    return pattern.allMatches(text).length;
  }

  static List<TutorProfile> _byRating(Iterable<TutorProfile> tutors) =>
      [...tutors]..sort((a, b) => b.ratingAverage.compareTo(a.ratingAverage));

  static String _quoteList(List<String> words) {
    final quoted = words.map((word) => '"$word"').toList();
    if (quoted.length == 1) {
      return quoted.single;
    }
    final head = quoted.sublist(0, quoted.length - 1).join(', ');
    return '$head and ${quoted.last}';
  }
}
