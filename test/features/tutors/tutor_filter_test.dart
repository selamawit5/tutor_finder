import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_filter.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

const _subjects = [
  Subject(
    id: 'phy',
    name: 'Physics',
    type: SubjectType.schoolSubject,
    gradeLevel: 'Grade 11-12',
  ),
  Subject(
    id: 'eng',
    name: 'English Speaking',
    type: SubjectType.skill,
    gradeLevel: 'All Levels',
  ),
  Subject(
    id: 'py',
    name: 'Python Programming',
    type: SubjectType.skill,
    gradeLevel: 'Beginner',
  ),
];

TutorProfile _tutor(
  String id, {
  required List<String> subjectIds,
  required double rating,
  String name = 'Tutor',
  String bio = '',
  String school = 'Some University',
}) {
  return TutorProfile(
    userId: id,
    name: name,
    bio: bio,
    educationStatus: EducationStatus.graduated,
    school: school,
    fieldOfStudy: 'Education',
    subjectIds: subjectIds,
    pricePerHour: 200,
    availability: const [],
    ratingAverage: rating,
    ratingCount: 1,
  );
}

final _tutors = [
  // Teaches a Grade 11-12 school subject AND an "All Levels" skill.
  _tutor(
    'mixed',
    subjectIds: ['phy', 'eng'],
    rating: 4.5,
    name: 'Abebe Kebede',
    bio: 'Mechanics and exam practice.',
  ),
  _tutor('coder', subjectIds: ['py'], rating: 4.9, name: 'Yonas Bekele'),
  _tutor(
    'speaker',
    subjectIds: ['eng'],
    rating: 4.2,
    name: 'Hanna Mekonnen',
    school: 'AAiT',
  ),
];

List<String> _ids(TutorFilter filter) => filterTutors(
  tutors: _tutors,
  subjects: _subjects,
  filter: filter,
).map((tutor) => tutor.userId).toList();

void main() {
  group('filterTutors', () {
    test('no filter returns every tutor, best rated first', () {
      expect(_ids(const TutorFilter()), ['coder', 'mixed', 'speaker']);
    });

    test('search matches name, bio, school and subject name, ignoring case '
        'and surrounding spaces', () {
      expect(_ids(const TutorFilter(searchQuery: 'yonas')), ['coder']);
      expect(_ids(const TutorFilter(searchQuery: 'MECHANICS')), ['mixed']);
      expect(_ids(const TutorFilter(searchQuery: 'aait')), ['speaker']);
      expect(_ids(const TutorFilter(searchQuery: '  python ')), ['coder']);
      expect(_ids(const TutorFilter(searchQuery: 'chemistry')), isEmpty);
    });

    test('subject filter keeps tutors who teach that subject', () {
      expect(_ids(const TutorFilter(selectedSubjectId: 'eng')), [
        'mixed',
        'speaker',
      ]);
    });

    test('type filter keeps tutors with at least one subject of that type', () {
      expect(_ids(const TutorFilter(selectedType: SubjectType.skill)), [
        'coder',
        'mixed',
        'speaker',
      ]);
      expect(_ids(const TutorFilter(selectedType: SubjectType.schoolSubject)), [
        'mixed',
      ]);
    });

    test('grade filter keeps tutors with a subject at that grade', () {
      expect(_ids(const TutorFilter(selectedGrade: 'Grade 11-12')), ['mixed']);
    });

    test('type and grade must match the same subject', () {
      // "mixed" teaches a skill and a Grade 11-12 subject, but no single
      // subject is both, so it must not match.
      expect(
        _ids(
          const TutorFilter(
            selectedType: SubjectType.skill,
            selectedGrade: 'Grade 11-12',
          ),
        ),
        isEmpty,
      );
      expect(
        _ids(
          const TutorFilter(
            selectedType: SubjectType.skill,
            selectedGrade: 'All Levels',
          ),
        ),
        ['mixed', 'speaker'],
      );
    });

    test('search and filters combine', () {
      expect(
        _ids(const TutorFilter(searchQuery: 'hanna', selectedSubjectId: 'eng')),
        ['speaker'],
      );
      expect(
        _ids(const TutorFilter(searchQuery: 'hanna', selectedSubjectId: 'py')),
        isEmpty,
      );
    });
  });

  group('TutorFilter.copyWith', () {
    test('keeps values unless replaced, and clear flags unset them', () {
      const filter = TutorFilter(
        searchQuery: 'math',
        selectedSubjectId: 'phy',
        selectedType: SubjectType.schoolSubject,
        selectedGrade: 'Grade 11-12',
      );

      final updated = filter.copyWith(searchQuery: 'physics');
      expect(updated.searchQuery, 'physics');
      expect(updated.selectedSubjectId, 'phy');

      final cleared = filter.copyWith(
        clearSubjectId: true,
        clearType: true,
        clearGrade: true,
      );
      expect(cleared.selectedSubjectId, isNull);
      expect(cleared.selectedType, isNull);
      expect(cleared.selectedGrade, isNull);
      expect(cleared.searchQuery, 'math');
      expect(cleared.hasFilters, isTrue);
      expect(const TutorFilter(searchQuery: '   ').hasFilters, isFalse);
    });
  });
}
