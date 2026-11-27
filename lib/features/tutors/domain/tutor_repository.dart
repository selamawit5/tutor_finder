import 'package:tutor_finder/features/tutors/domain/subject.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';

/// Reads and updates tutors and subjects.
///
/// Milestone 1 uses an in-memory implementation; a backend-backed one can
/// replace it later without touching the UI.
abstract interface class TutorRepository {
  Future<List<TutorProfile>> getTutors();

  List<Subject> getSubjects();

  Future<TutorProfile?> getTutorById(String tutorId);

  /// Replaces the stored profile with the same `userId` and returns it.
  /// Throws a [StateError] if no such tutor exists.
  Future<TutorProfile> updateTutorProfile(TutorProfile profile);
}
