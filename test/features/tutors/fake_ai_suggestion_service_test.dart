import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/features/tutors/data/fake_ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/domain/ai_suggestion_service.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

const _subjects = [
  Subject(
    id: 'phy',
    name: 'Physics',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 11-12',
  ),
  Subject(
    id: 'math',
    name: 'Mathematics',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 9-12',
  ),
  Subject(
    id: 'py',
    name: 'Python Programming',
    type: SubjectType.skill,
    gradeLevel: 'Beginner',
  ),
  Subject(
    id: 'art',
    name: 'Drawing',
    type: SubjectType.skill,
    gradeLevel: 'All Levels',
  ),
];

TutorProfile _tutor(String id, List<String> subjectIds, double rating) {
  return TutorProfile(
    userId: id,
    name: 'Tutor $id',
    bio: '',
    educationStatus: EducationStatus.graduated,
    school: 'Some University',
    fieldOfStudy: 'Education',
    subjectIds: subjectIds,
    pricePerHour: 200,
    availability: const [],
    ratingAverage: rating,
    ratingCount: 1,
  );
}

final _tutors = [
  _tutor('physicsOk', ['phy'], 4.1),
  _tutor('physicsBest', ['phy', 'math'], 4.8),
  _tutor('mathOnly', ['math'], 4.5),
  _tutor('coder', ['py'], 4.9),
];

const _ai = FakeAiSuggestionService();

AiSuggestionResult _suggest(String problem) =>
    _ai.suggest(problem, tutors: _tutors, subjects: _subjects);

List<String> _ids(AiSuggestionResult result) =>
    result.suggestedTutors.map((tutor) => tutor.userId).toList();

void main() {
  group('FakeAiSuggestionService', () {
    test('matches a subject by its extra keywords', () {
      final result = _suggest("I don't understand Newton's laws");

      expect(result.subjectName, 'Physics');
      expect(result.hasMatch, isTrue);
      expect(result.reason, contains('"newton"'));
    });

    test('suggests only tutors of the subject, best rated first', () {
      expect(_ids(_suggest('help with physics')), ['physicsBest', 'physicsOk']);
    });

    test('matching is case-insensitive and allows plurals', () {
      expect(_suggest('PYTHON loops').subjectName, 'Python Programming');
      expect(_suggest('solving equations').subjectName, 'Mathematics');
      expect(_suggest('I hate maths').subjectName, 'Mathematics');
    });

    test('only whole words match', () {
      // "aftermath" contains "math", "enforce" contains "force".
      expect(_suggest('the aftermath').hasMatch, isFalse);
      expect(_suggest('enforce the rules').hasMatch, isFalse);
    });

    test('the subject with the most keyword hits wins', () {
      // One physics word vs three maths words.
      final result = _suggest('energy in algebra, geometry and calculus');

      expect(result.subjectName, 'Mathematics');
      expect(result.reason, contains('"algebra"'));
    });

    test('a tie keeps the subject listed first', () {
      expect(_suggest('physics and math').subjectName, 'Physics');
    });

    test('no match falls back to the top three tutors by rating', () {
      final result = _suggest('I need help with my homework');

      expect(result.subjectName, isNull);
      expect(result.hasMatch, isFalse);
      expect(_ids(result), ['coder', 'physicsBest', 'mathOnly']);
      expect(result.reason, contains('top-rated'));
    });

    test('a matched subject with no tutors returns an empty list', () {
      final result = _suggest('drawing portraits');

      expect(result.subjectName, 'Drawing');
      expect(result.suggestedTutors, isEmpty);
    });
  });
}
