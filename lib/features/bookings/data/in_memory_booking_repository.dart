import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/bookings/domain/booking_repository.dart';

class InMemoryBookingRepository implements BookingRepository {
  final List<Booking> _bookings = List<Booking>.from(seedBookings);

  @override
  Future<List<Booking>> getBookings() async {
    return List<Booking>.unmodifiable(_bookings);
  }

  @override
  Future<Booking> createBooking({
    required String requestedById,
    required String studentName,
    required String tutorId,
    required String subjectId,
    required DateTime start,
    required int durationMinutes,
  }) async {
    final newBooking = Booking(
      id: 'b${_bookings.length + 1}',
      requestedById: requestedById,
      studentName: studentName,
      tutorId: tutorId,
      subjectId: subjectId,
      start: start,
      durationMinutes: durationMinutes,
      status: BookingStatus.pending,
      createdAt: DateTime.now(),
    );
    _bookings.insert(0, newBooking);
    return newBooking;
  }

  @override
  Future<Booking> updateStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1) {
      throw StateError('Booking not found: $bookingId');
    }
    final updated = _bookings[index].copyWith(status: status);
    _bookings[index] = updated;
    return updated;
  }
}
