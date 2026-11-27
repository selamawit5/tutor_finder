import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking.freezed.dart';

enum BookingStatus { pending, accepted, declined, completed, cancelled }

@freezed
abstract class Booking with _$Booking {
  const factory Booking({
    required String id,
    required String requestedById,
    required String studentName,
    required String tutorId,
    required String subjectId,
    required DateTime start,
    required int durationMinutes,
    required BookingStatus status,
    required DateTime createdAt,
  }) = _Booking;
}
