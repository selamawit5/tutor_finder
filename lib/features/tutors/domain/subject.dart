import 'package:freezed_annotation/freezed_annotation.dart';

part 'subject.freezed.dart';

enum SubjectType { schoolSubject, skill }

@freezed
abstract class Subject with _$Subject {
  const factory Subject({
    required String id,
    required String name,
    required SubjectType type,
    required String gradeLevel,
  }) = _Subject;
}
