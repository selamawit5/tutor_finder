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
    this.savedReview,
  });

  /// 0 means no star chosen yet; otherwise 1–5.
  final int rating;
  final bool isSubmitting;
  final String? ratingError;
  final String? commentError;
  final String? submitError;

  /// Set when the review is stored but the tutor rating update failed.
  /// The form is locked and submitting again only retries the rating step.
  final Review? savedReview;

  bool get needsRatingRetry => savedReview != null;
}

/// Submitting a review is two steps: store the review, then fold its rating
/// into the tutor's average. To keep them consistent:
/// - if step 2 fails, the stored review is kept and [submit] retries only
///   step 2 (no duplicate-review error, nothing to re-enter);
/// - if the user leaves before step 2 succeeds, the stored review is
///   deleted, so there is never a review whose rating was not counted.
class ReviewFormNotifier extends Notifier<ReviewFormState> {
  ReviewFormNotifier(this.bookingId);

  final String bookingId;

  /// Stored review whose rating has not been applied yet.
  Review? _pendingReview;

  @override
  ReviewFormState build() {
    final repository = ref.read(reviewRepositoryProvider);
    ref.onDispose(() {
      final pending = _pendingReview;
      if (pending != null) {
        repository.deleteReview(pending.id);
      }
    });
    return const ReviewFormState();
  }

  void setRating(int rating) {
    if (state.needsRatingRetry) {
      return;
    }
    state = ReviewFormState(
      rating: rating.clamp(1, 5),
      commentError: state.commentError,
    );
  }

  void clearCommentError() {
    if (state.commentError != null) {
      state = ReviewFormState(
        rating: state.rating,
        ratingError: state.ratingError,
      );
    }
  }

  /// Validates, saves the review and updates the tutor rating. Returns `true`
  /// on success; on failure the error is put on the state for the screen.
  Future<bool> submit({
    required Booking booking,
    required String comment,
  }) async {
    final review = _pendingReview ?? await _saveReview(booking, comment);
    if (review == null) {
      return false;
    }
    if (!ref.mounted) {
      return false;
    }
    state = ReviewFormState(
      rating: review.rating,
      isSubmitting: true,
      savedReview: review,
    );

    try {
      await ref
          .read(tutorsProvider.notifier)
          .recordRating(review.tutorId, review.rating);
    } catch (_) {
      if (ref.mounted) {
        state = ReviewFormState(
          rating: review.rating,
          savedReview: review,
          submitError:
              "Your review was saved, but the tutor's rating could not be "
              'updated. Tap Retry to finish.',
        );
      }
      return false;
    }

    _pendingReview = null;
    if (ref.mounted) {
      ref.invalidate(reviewsProvider(review.tutorId));
      state = ReviewFormState(rating: review.rating);
    }
    return true;
  }

  /// Step 1: validate and store the review. Returns `null` on failure.
  Future<Review?> _saveReview(Booking booking, String comment) async {
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
      return null;
    }

    final rating = state.rating;
    final review = Review(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      bookingId: booking.id,
      reviewerId: booking.requestedById,
      reviewerName: booking.studentName,
      tutorId: booking.tutorId,
      rating: rating,
      comment: text,
      createdAt: DateTime.now(),
    );
    final repository = ref.read(reviewRepositoryProvider);
    state = ReviewFormState(rating: rating, isSubmitting: true);

    String? submitError;
    try {
      await repository.addReview(review);
    } on DuplicateReviewException {
      submitError = 'You have already reviewed this session.';
    } catch (_) {
      submitError = 'Could not save your review. Please try again.';
    }

    if (!ref.mounted) {
      // The screen closed while saving: undo so nothing is left half-done.
      if (submitError == null) {
        await repository.deleteReview(review.id);
      }
      return null;
    }
    if (submitError != null) {
      state = ReviewFormState(rating: rating, submitError: submitError);
      return null;
    }
    _pendingReview = review;
    return review;
  }
}

final reviewFormProvider = NotifierProvider.autoDispose
    .family<ReviewFormNotifier, ReviewFormState, String>(
      ReviewFormNotifier.new,
    );
