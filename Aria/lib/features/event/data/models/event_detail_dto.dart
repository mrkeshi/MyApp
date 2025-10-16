import '../../domain/entities/event_detail.dart';
import '../../domain/entities/event_review.dart';
import 'event_dto.dart';
import 'event_review_dto.dart';

class EventDetailDto extends EventDto {
  final List<EventReviewDto> reviews;

  EventDetailDto({
    required super.id,
    required super.province,
    required super.title,
    required super.shortDescription,
    required super.description,
    required super.registrationCost,
    required super.discountCode,
    required super.venue,
    required super.latitude,
    required super.longitude,
    required super.mapsUrl,
    required super.coverImage,
    required super.startAt,
    required super.averageRating,
    required super.reviewsCount,
    required this.reviews,
  });

  factory EventDetailDto.fromJson(Map<String, dynamic> json) {
    final base = EventDto.fromJson(json);
    final list = (json['reviews'] as List?)
        ?.whereType<Map<String, dynamic>>()
        .map((e) => EventReviewDto.fromJson(e))
        .toList(growable: false) ??
        const <EventReviewDto>[];
    return EventDetailDto(
      id: base.id,
      province: base.province,
      title: base.title,
      shortDescription: base.shortDescription,
      description: base.description,
      registrationCost: base.registrationCost,
      discountCode: base.discountCode,
      venue: base.venue,
      latitude: base.latitude,
      longitude: base.longitude,
      mapsUrl: base.mapsUrl,
      coverImage: base.coverImage,
      startAt: base.startAt,
      averageRating: base.averageRating,
      reviewsCount: base.reviewsCount,
      reviews: list,
    );
  }

  EventDetail toEntity() => EventDetail(
    id: id,
    province: province,
    title: title,
    shortDescription: shortDescription,
    description: description,
    registrationCost: registrationCost,
    discountCode: discountCode,
    venue: venue,
    latitude: latitude,
    longitude: longitude,
    mapsUrl: mapsUrl,
    coverImage: coverImage,
    startAt: startAt,
    averageRating: averageRating,
    reviewsCount: reviewsCount,
    reviews: reviews.map<EventReview>((e) => e.toEntity()).toList(growable: false),
  );
}
