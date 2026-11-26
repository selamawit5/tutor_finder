import 'package:freezed_annotation/freezed_annotation.dart';

part 'tutor_profile.freezed.dart';

enum EducationStatus { graduated, learning }

@freezed
abstract class TutorProfile with _$TutorProfile {
  const factory TutorProfile({
    required String userId,
    required String name,
    required String bio,
    required EducationStatus educationStatus,
    required String school,
    required String fieldOfStudy,
    required List<String> subjectIds,
    required double pricePerHour,
    required List<String> availability,
    required double ratingAverage,
    required int ratingCount,
    String? photoUrl,
  }) = _TutorProfile;
}
