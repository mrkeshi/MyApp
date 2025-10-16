import '../../domain/entities/event.dart';

class EventDto {
  final int id;
  final int province;
  final String title;
  final String shortDescription;
  final String description;
  final String registrationCost;
  final String discountCode;
  final String venue;
  final String latitude;
  final String longitude;
  final String mapsUrl;
  final String coverImage;
  final DateTime startAt;
  final double averageRating;
  final int reviewsCount;

  EventDto({
    required this.id,
    required this.province,
    required this.title,
    required this.shortDescription,
    required this.description,
    required this.registrationCost,
    required this.discountCode,
    required this.venue,
    required this.latitude,
    required this.longitude,
    required this.mapsUrl,
    required this.coverImage,
    required this.startAt,
    required this.averageRating,
    required this.reviewsCount,
  });

  factory EventDto.fromJson(Map<String, dynamic> json) {
    return EventDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      province: (json['province'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      shortDescription: (json['short_description'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      registrationCost: (json['registration_cost'] ?? '').toString(),
      discountCode: (json['discount_code'] ?? '').toString(),
      venue: (json['venue'] ?? '').toString(),
      latitude: (json['latitude'] ?? '').toString(),
      longitude: (json['longitude'] ?? '').toString(),
      mapsUrl: (json['maps_url'] ?? '').toString(),
      coverImage: (json['cover_image'] ?? '').toString(),
      startAt: DateTime.tryParse((json['start_at'] ?? '').toString()) ?? DateTime.fromMillisecondsSinceEpoch(0),
      averageRating: (json['average_rating'] is num) ? (json['average_rating'] as num).toDouble() : 0.0,
      reviewsCount: (json['reviews_count'] as num?)?.toInt() ?? 0,
    );
  }

  Event toEntity() => Event(
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
  );
}
