import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_repository.dart';

/// Keeps tutors and subjects in memory, starting from the fake seed data.
class InMemoryTutorRepository implements TutorRepository {
  InMemoryTutorRepository({List<TutorProfile>? tutors, List<Subject>? subjects})
    : _tutors = [...(tutors ?? seedTutors)],
      _subjects = List<Subject>.unmodifiable(subjects ?? seedSubjects);

  final List<TutorProfile> _tutors;
  final List<Subject> _subjects;

  @override
  Future<List<TutorProfile>> getTutors() async =>
      List<TutorProfile>.unmodifiable(_tutors);

  @override
  List<Subject> getSubjects() => _subjects;

  @override
  Future<TutorProfile?> getTutorById(String tutorId) async {
    for (final tutor in _tutors) {
      if (tutor.userId == tutorId) {
        return tutor;
      }
    }
    return null;
  }

  @override
  Future<TutorProfile> updateTutorProfile(TutorProfile profile) async {
    final index = _tutors.indexWhere((t) => t.userId == profile.userId);
    if (index == -1) {
      throw StateError('No tutor with id ${profile.userId}');
    }
    _tutors[index] = profile;
    return profile;
  }
}
