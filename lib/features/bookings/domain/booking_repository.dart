import 'package:tutor_finder/features/bookings/domain/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();

  Future<Booking> createBooking({
    required String requestedById,
    required String studentName,
    required String tutorId,
    required String subjectId,
    required DateTime start,
    required int durationMinutes,
  });

  Future<Booking> updateStatus({
    required String bookingId,
    required BookingStatus status,
  });
}
