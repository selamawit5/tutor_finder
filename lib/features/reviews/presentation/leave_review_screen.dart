import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_finder/core/utils/initials.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/reviews/presentation/reviews_provider.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

const _ratingLabels = ['Poor', 'Fair', 'Good', 'Great', 'Excellent'];

/// Screen 7: Leave a Review for a completed booking.
///
/// Form state lives in [reviewFormProvider]; this widget only owns the comment
/// controller, so it is a [ConsumerStatefulWidget] without `setState`.
class LeaveReviewScreen extends ConsumerStatefulWidget {
  const LeaveReviewScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<LeaveReviewScreen> createState() => _LeaveReviewScreenState();
}

class _LeaveReviewScreenState extends ConsumerState<LeaveReviewScreen> {
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit(Booking booking) async {
    FocusScope.of(context).unfocus();
    final saved = await ref
        .read(reviewFormProvider(widget.bookingId).notifier)
        .submit(booking: booking, comment: _commentController.text);
    if (!saved || !mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thanks! Your review was saved.')),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(reviewBookingProvider(widget.bookingId));
    final alreadyReviewed =
        booking != null &&
        (ref.watch(reviewsProvider(booking.tutorId)).value ?? const []).any(
          (review) => review.bookingId == booking.id,
        );

    final Widget body;
    Widget? bottomBar;
    if (booking == null) {
      body = const _MessageView(
        icon: Icons.search_off,
        title: 'Booking not found',
        message: 'This session may have been removed.',
      );
    } else if (booking.status != BookingStatus.completed) {
      body = const _MessageView(
        icon: Icons.hourglass_top,
        title: 'Session not finished yet',
        message: 'You can leave a review once the session is completed.',
      );
    } else if (alreadyReviewed) {
      body = const _MessageView(
        icon: Icons.task_alt,
        title: 'Already reviewed',
        message: 'Thanks! You have already reviewed this session.',
      );
    } else {
      body = _ReviewForm(
        booking: booking,
        commentController: _commentController,
      );
      bottomBar = _SubmitBar(
        bookingId: widget.bookingId,
        onSubmit: () => _submit(booking),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Leave a Review')),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomBar,
    );
  }
}

class _ReviewForm extends ConsumerWidget {
  const _ReviewForm({required this.booking, required this.commentController});

  final Booking booking;
  final TextEditingController commentController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final form = ref.watch(reviewFormProvider(booking.id));
    final notifier = ref.read(reviewFormProvider(booking.id).notifier);
    // Locked while saving, and once the review is stored (only a retry of
    // the rating update is left), so the saved text cannot drift.
    final isLocked = form.isSubmitting || form.needsRatingRetry;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: ListView(
        children: [
          _SessionCard(booking: booking),
          const SizedBox(height: 20),
          Text('How was your session?', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var star = 1; star <= 5; star++)
                IconButton(
                  tooltip: '$star star${star == 1 ? '' : 's'}',
                  iconSize: 36,
                  onPressed: isLocked ? null : () => notifier.setRating(star),
                  icon: Icon(
                    star <= form.rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                ),
            ],
          ),
          Text(
            form.rating == 0
                ? 'Tap a star to rate'
                : _ratingLabels[form.rating - 1],
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge?.copyWith(
              color: form.ratingError != null
                  ? theme.colorScheme.error
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (form.ratingError != null) ...[
            const SizedBox(height: 8),
            Text(
              form.ratingError!,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: 20),
          TextField(
            controller: commentController,
            enabled: !isLocked,
            maxLines: 3,
            maxLength: reviewCommentMaxLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => notifier.clearCommentError(),
            decoration: InputDecoration(
              labelText: 'Write a short review',
              hintText: 'What went well? What could be better?',
              alignLabelWithHint: true,
              errorText: form.commentError,
            ),
          ),
          if (form.submitError != null) ...[
            const SizedBox(height: 8),
            Text(
              form.submitError!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionCard extends ConsumerWidget {
  const _SessionCard({required this.booking});

  final Booking booking;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final localizations = MaterialLocalizations.of(context);
    final tutorName = ref.watch(tutorByIdProvider(booking.tutorId))?.name;
    final subjectName = ref.watch(subjectByIdProvider(booking.subjectId))?.name;

    final date = localizations.formatMediumDate(booking.start);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(booking.start),
    );
    final details = [
      ?subjectName,
      '$date · $time',
      '${booking.durationMinutes} min',
    ].join(' · ');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(child: Text(initialsOf(tutorName ?? ''))),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tutorName ?? 'Your tutor',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    details,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitBar extends ConsumerWidget {
  const _SubmitBar({required this.bookingId, required this.onSubmit});

  final String bookingId;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(reviewFormProvider(bookingId));
    final isSubmitting = form.isSubmitting;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: isSubmitting ? null : onSubmit,
          icon: isSubmitting
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(
                  form.needsRatingRetry
                      ? Icons.refresh
                      : Icons.rate_review_outlined,
                ),
          label: Text(form.needsRatingRetry ? 'Retry' : 'Submit Review'),
        ),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
