import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/features/bookings/data/in_memory_booking_repository.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/bookings/domain/booking_repository.dart';

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return InMemoryBookingRepository();
});

class BookingsNotifier extends AsyncNotifier<List<Booking>> {
  @override
  Future<List<Booking>> build() {
    return ref.watch(bookingRepositoryProvider).getBookings();
  }

  Future<void> createBooking({
    required String requestedById,
    required String studentName,
    required String tutorId,
    required String subjectId,
    required DateTime start,
    int durationMinutes = 60,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.createBooking(
      requestedById: requestedById,
      studentName: studentName,
      tutorId: tutorId,
      subjectId: subjectId,
      start: start,
      durationMinutes: durationMinutes,
    );
    state = AsyncData(await repo.getBookings());
  }

  Future<void> updateStatus({
    required String bookingId,
    required BookingStatus status,
  }) async {
    final repo = ref.read(bookingRepositoryProvider);
    await repo.updateStatus(bookingId: bookingId, status: status);
    state = AsyncData(await repo.getBookings());
  }
}

final bookingsProvider = AsyncNotifierProvider<BookingsNotifier, List<Booking>>(
  BookingsNotifier.new,
);

class BookSessionSelection {
  const BookSessionSelection({this.subjectId, this.timeSlot});

  final String? subjectId;
  final String? timeSlot;

  BookSessionSelection copyWith({String? subjectId, String? timeSlot}) {
    return BookSessionSelection(
      subjectId: subjectId ?? this.subjectId,
      timeSlot: timeSlot ?? this.timeSlot,
    );
  }
}

class BookSessionSelectionNotifier extends Notifier<BookSessionSelection> {
  @override
  BookSessionSelection build() => const BookSessionSelection();

  void selectSubject(String subjectId) {
    state = state.copyWith(subjectId: subjectId);
  }

  void selectTimeSlot(String timeSlot) {
    state = state.copyWith(timeSlot: timeSlot);
  }

  void reset() {
    state = const BookSessionSelection();
  }
}

final bookSessionSelectionProvider =
    NotifierProvider<BookSessionSelectionNotifier, BookSessionSelection>(
      BookSessionSelectionNotifier.new,
    );
