import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';

@freezed
abstract class Review with _$Review {
  const factory Review({
    required String id,
    required String bookingId,
    required String reviewerId,
    required String reviewerName,
    required String tutorId,
    required int rating,
    required String comment,
    required DateTime createdAt,
  }) = _Review;
}
