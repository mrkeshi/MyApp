import '../../domain/entities/event_review.dart';

class EventReviewDto {
  final int id;
  final int user;
  final String userDisplay;
  final String profileImage;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String createdAtText;

  EventReviewDto({
    required this.id,
    required this.user,
    required this.userDisplay,
    required this.profileImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.createdAtText,
  });

  factory EventReviewDto.fromJson(Map<String, dynamic> json) {
    return EventReviewDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      user: (json['user'] as num?)?.toInt() ?? 0,
      userDisplay: (json['user_display'] ?? '').toString(),
      profileImage: (json['profile_image'] ?? '').toString(),
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] ?? '').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      createdAtText: (json['created_at_text'] ?? '').toString(),
    );
  }

  EventReview toEntity() => EventReview(
    id: id,
    user: user,
    userDisplay: userDisplay,
    profileImage: profileImage,
    rating: rating,
    comment: comment,
    createdAt: createdAt,
    createdAtText: createdAtText,
  );
}
