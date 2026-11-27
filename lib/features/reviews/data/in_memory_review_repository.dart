import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/reviews/domain/review.dart';
import 'package:tutor_finder/features/reviews/domain/review_repository.dart';

/// Keeps reviews in memory, starting from the fake seed data.
class InMemoryReviewRepository implements ReviewRepository {
  InMemoryReviewRepository({List<Review>? reviews})
    : _reviews = [...(reviews ?? seedReviews)];

  final List<Review> _reviews;

  @override
  Future<List<Review>> getReviewsForTutor(String tutorId) async {
    final reviews =
        _reviews.where((review) => review.tutorId == tutorId).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List<Review>.unmodifiable(reviews);
  }

  @override
  Future<Review> addReview(Review review) async {
    if (review.rating < 1 || review.rating > 5) {
      throw ArgumentError.value(review.rating, 'rating', 'must be 1 to 5');
    }
    if (_reviews.any((existing) => existing.bookingId == review.bookingId)) {
      throw DuplicateReviewException(review.bookingId);
    }
    _reviews.add(review);
    return review;
  }
}
