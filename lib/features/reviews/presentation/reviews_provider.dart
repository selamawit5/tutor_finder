import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_finder/core/data/fake_seed_data.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/reviews/data/in_memory_review_repository.dart';
import 'package:tutor_finder/features/reviews/domain/review.dart';
import 'package:tutor_finder/features/reviews/domain/review_repository.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => InMemoryReviewRepository(),
);

/// Reviews for one tutor, newest first: `ref.watch(reviewsProvider(tutorId))`.
class ReviewsNotifier extends AsyncNotifier<List<Review>> {
  ReviewsNotifier(this.tutorId);

  final String tutorId;

  @override
  Future<List<Review>> build() =>
      ref.watch(reviewRepositoryProvider).getReviewsForTutor(tutorId);
}

final reviewsProvider =
    AsyncNotifierProvider.family<ReviewsNotifier, List<Review>, String>(
      ReviewsNotifier.new,
    );

/// The booking being reviewed.
///
/// TODO(tsegaye): read from Selamawit's bookings provider once
/// `feat/bookings` is merged, so newly completed bookings can be reviewed.
final reviewBookingProvider = Provider.family<Booking?, String>((ref, id) {
  for (final booking in seedBookings) {
    if (booking.id == id) {
      return booking;
    }
  }
  return null;
});

// ---------------------------------------------------------------------------
// Leave a Review form
// ---------------------------------------------------------------------------

const reviewCommentMaxLength = 300;

@immutable
class ReviewFormState {
  const ReviewFormState({
    this.rating = 0,
    this.isSubmitting = false,
    this.ratingError,
    this.commentError,
    this.submitError,
  });

  /// 0 means no star chosen yet; otherwise 1–5.
  final int rating;
  final bool isSubmitting;
  final String? ratingError;
  final String? commentError;
  final String? submitError;
}

class ReviewFormNotifier extends Notifier<ReviewFormState> {
  ReviewFormNotifier(this.bookingId);

  final String bookingId;

  @override
  ReviewFormState build() => const ReviewFormState();

  void setRating(int rating) => state = ReviewFormState(
    rating: rating.clamp(1, 5),
    commentError: state.commentError,
  );

  void clearCommentError() {
    if (state.commentError != null) {
      state = ReviewFormState(
        rating: state.rating,
        ratingError: state.ratingError,
      );
    }
  }

  /// Validates and saves the review. Returns `true` on success; on failure
  /// the error is put on the state for the screen to show.
  Future<bool> submit({
    required Booking booking,
    required String comment,
  }) async {
    final text = comment.trim();
    final ratingError = state.rating == 0
        ? 'Please choose a star rating.'
        : null;
    final commentError = text.isEmpty ? 'Please write a short review.' : null;
    if (ratingError != null || commentError != null) {
      state = ReviewFormState(
        rating: state.rating,
        ratingError: ratingError,
        commentError: commentError,
      );
      return false;
    }

    final rating = state.rating;
    state = ReviewFormState(rating: rating, isSubmitting: true);

    String? submitError;
    try {
      await ref
          .read(reviewRepositoryProvider)
          .addReview(
            Review(
              id: 'r${DateTime.now().microsecondsSinceEpoch}',
              bookingId: booking.id,
              reviewerId: booking.requestedById,
              reviewerName: booking.studentName,
              tutorId: booking.tutorId,
              rating: rating,
              comment: text,
              createdAt: DateTime.now(),
            ),
          );
      await ref
          .read(tutorsProvider.notifier)
          .recordRating(booking.tutorId, rating);
      ref.invalidate(reviewsProvider(booking.tutorId));
    } on DuplicateReviewException {
      submitError = 'You have already reviewed this session.';
    } catch (_) {
      submitError = 'Could not save your review. Please try again.';
    }

    if (ref.mounted) {
      state = ReviewFormState(rating: rating, submitError: submitError);
    }
    return submitError == null;
  }
}

final reviewFormProvider = NotifierProvider.autoDispose
    .family<ReviewFormNotifier, ReviewFormState, String>(
      ReviewFormNotifier.new,
    );
