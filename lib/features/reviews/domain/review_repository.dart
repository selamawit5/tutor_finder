import 'package:tutor_finder/features/reviews/domain/review.dart';

/// Thrown when a booking already has a review.
class DuplicateReviewException implements Exception {
  const DuplicateReviewException(this.bookingId);

  final String bookingId;

  @override
  String toString() =>
      'DuplicateReviewException: booking $bookingId '
      'already has a review';
}

abstract interface class ReviewRepository {
  /// Reviews for a tutor, newest first.
  Future<List<Review>> getReviewsForTutor(String tutorId);

  /// Saves [review]. Throws [DuplicateReviewException] if its booking was
  /// already reviewed, and [ArgumentError] if the rating is not 1–5.
  Future<Review> addReview(Review review);
}
