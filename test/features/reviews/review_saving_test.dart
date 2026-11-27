import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tutor_finder/features/bookings/domain/booking.dart';
import 'package:tutor_finder/features/reviews/data/in_memory_review_repository.dart';
import 'package:tutor_finder/features/reviews/domain/review.dart';
import 'package:tutor_finder/features/reviews/domain/review_repository.dart';
import 'package:tutor_finder/features/reviews/presentation/reviews_provider.dart';
import 'package:tutor_finder/features/tutors/data/in_memory_tutor_repository.dart';
import 'package:tutor_finder/features/tutors/domain/tutor_profile.dart';
import 'package:tutor_finder/features/tutors/presentation/tutors_provider.dart';

const _tutor = TutorProfile(
  userId: 't1',
  name: 'Abebe Kebede',
  bio: '',
  educationStatus: EducationStatus.graduated,
  school: 'Addis Ababa University',
  fieldOfStudy: 'BSc in Physics',
  subjectIds: ['s1'],
  pricePerHour: 250,
  availability: [],
  ratingAverage: 4,
  ratingCount: 4,
);

final _booking = Booking(
  id: 'b1',
  requestedById: 'u1',
  studentName: 'Semhal Dawit',
  tutorId: 't1',
  subjectId: 's1',
  start: DateTime(2026, 11, 22, 17),
  durationMinutes: 60,
  status: BookingStatus.completed,
  createdAt: DateTime(2026, 11, 20),
);

Review _review({
  String id = 'r1',
  String bookingId = 'b1',
  String tutorId = 't1',
  int rating = 5,
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    bookingId: bookingId,
    reviewerId: 'u1',
    reviewerName: 'Semhal Dawit',
    tutorId: tutorId,
    rating: rating,
    comment: 'Great session',
    createdAt: createdAt ?? DateTime(2026, 11, 22),
  );
}

/// Tutor repository whose next [failures] profile updates throw.
class _FlakyTutorRepository extends InMemoryTutorRepository {
  _FlakyTutorRepository({this.failures = 0}) : super(tutors: [_tutor]);

  int failures;

  @override
  Future<TutorProfile> updateTutorProfile(TutorProfile profile) async {
    if (failures > 0) {
      failures--;
      throw Exception('network down');
    }
    return super.updateTutorProfile(profile);
  }
}

void main() {
  group('InMemoryReviewRepository', () {
    test('saves reviews and lists a tutor\'s reviews newest first', () async {
      final repository = InMemoryReviewRepository(reviews: []);
      await repository.addReview(
        _review(id: 'old', bookingId: 'b1', createdAt: DateTime(2026, 1, 1)),
      );
      await repository.addReview(
        _review(id: 'new', bookingId: 'b2', createdAt: DateTime(2026, 2, 1)),
      );
      await repository.addReview(
        _review(id: 'other', bookingId: 'b3', tutorId: 't2'),
      );

      final reviews = await repository.getReviewsForTutor('t1');
      expect(reviews.map((review) => review.id), ['new', 'old']);
    });

    test('rejects a second review for the same booking', () async {
      final repository = InMemoryReviewRepository(reviews: [_review()]);

      await expectLater(
        repository.addReview(_review(id: 'r2')),
        throwsA(isA<DuplicateReviewException>()),
      );
      expect(await repository.getReviewsForTutor('t1'), hasLength(1));
    });

    test('rejects ratings outside 1 to 5', () async {
      final repository = InMemoryReviewRepository(reviews: []);

      for (final rating in [0, 6]) {
        await expectLater(
          repository.addReview(_review(rating: rating)),
          throwsArgumentError,
        );
      }
      expect(await repository.getReviewsForTutor('t1'), isEmpty);
    });
  });

  group('Leave a Review form', () {
    late InMemoryReviewRepository reviews;
    late _FlakyTutorRepository tutors;
    late ProviderContainer container;
    late ProviderSubscription<ReviewFormState> form;

    ReviewFormNotifier notifier() =>
        container.read(reviewFormProvider(_booking.id).notifier);

    Future<TutorProfile> savedTutor() async =>
        (await tutors.getTutorById('t1'))!;

    void setUpContainer({int ratingUpdateFailures = 0}) {
      reviews = InMemoryReviewRepository(reviews: []);
      tutors = _FlakyTutorRepository(failures: ratingUpdateFailures);
      container = ProviderContainer.test(
        overrides: [
          reviewRepositoryProvider.overrideWithValue(reviews),
          tutorRepositoryProvider.overrideWithValue(tutors),
        ],
      );
      // The form provider is auto-dispose; keep it alive like the screen does.
      form = container.listen(reviewFormProvider(_booking.id), (_, _) {});
    }

    test('requires a rating and a comment before saving', () async {
      setUpContainer();

      final saved = await notifier().submit(booking: _booking, comment: '  ');

      expect(saved, isFalse);
      expect(form.read().ratingError, isNotNull);
      expect(form.read().commentError, isNotNull);
      expect(await reviews.getReviewsForTutor('t1'), isEmpty);
    });

    test('saves the review and updates the tutor rating', () async {
      setUpContainer();

      notifier().setRating(5);
      final saved = await notifier().submit(
        booking: _booking,
        comment: '  Very clear explanations  ',
      );

      expect(saved, isTrue);
      final stored = await reviews.getReviewsForTutor('t1');
      expect(stored, hasLength(1));
      expect(stored.single.bookingId, 'b1');
      expect(stored.single.reviewerName, 'Semhal Dawit');
      expect(stored.single.rating, 5);
      expect(stored.single.comment, 'Very clear explanations');

      final tutor = await savedTutor();
      expect(tutor.ratingCount, 5);
      expect(tutor.ratingAverage, closeTo(4.2, 1e-9));

      expect(await container.read(reviewsProvider('t1').future), hasLength(1));
    });

    test('shows an error for a booking that was already reviewed', () async {
      setUpContainer();
      await reviews.addReview(_review(id: 'existing'));

      notifier().setRating(4);
      final saved = await notifier().submit(booking: _booking, comment: 'Hi');

      expect(saved, isFalse);
      expect(form.read().submitError, contains('already reviewed'));
      expect((await savedTutor()).ratingCount, 4);
    });

    test('if the rating update fails, retry finishes it without a '
        'duplicate review', () async {
      setUpContainer(ratingUpdateFailures: 1);

      notifier().setRating(3);
      final first = await notifier().submit(booking: _booking, comment: 'OK');

      expect(first, isFalse);
      expect(form.read().needsRatingRetry, isTrue);
      expect(form.read().submitError, contains('Retry'));
      expect(await reviews.getReviewsForTutor('t1'), hasLength(1));
      expect((await savedTutor()).ratingCount, 4);

      // The locked form ignores rating changes while a retry is pending.
      notifier().setRating(1);
      expect(form.read().rating, 3);

      final retry = await notifier().submit(booking: _booking, comment: '');

      expect(retry, isTrue);
      expect(form.read().needsRatingRetry, isFalse);
      expect(await reviews.getReviewsForTutor('t1'), hasLength(1));
      final tutor = await savedTutor();
      expect(tutor.ratingCount, 5);
      expect(tutor.ratingAverage, closeTo(3.8, 1e-9));
    });

    test(
      'leaving before the rating update succeeds removes the review',
      () async {
        setUpContainer(ratingUpdateFailures: 1);

        notifier().setRating(5);
        await notifier().submit(booking: _booking, comment: 'Great');
        expect(await reviews.getReviewsForTutor('t1'), hasLength(1));

        // The screen closes: the auto-dispose form provider is disposed.
        form.close();
        await container.pump();

        expect(await reviews.getReviewsForTutor('t1'), isEmpty);
        expect((await savedTutor()).ratingCount, 4);
      },
    );

    test(
      'recordRating rejects ratings outside 1 to 5 and unknown tutors',
      () async {
        setUpContainer();
        await container.read(tutorsProvider.future);
        final tutorsNotifier = container.read(tutorsProvider.notifier);

        for (final rating in [0, 6]) {
          await expectLater(
            tutorsNotifier.recordRating('t1', rating),
            throwsArgumentError,
          );
        }
        await expectLater(
          tutorsNotifier.recordRating('missing', 4),
          throwsStateError,
        );
        expect((await savedTutor()).ratingCount, 4);
      },
    );
  });
}
