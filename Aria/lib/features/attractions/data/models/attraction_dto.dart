import '../../domain/entities/attraction.dart';

class AttractionDto {
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
  final double averageRating;
  final int reviewsCount;

  const AttractionDto({
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
    required this.averageRating,
    required this.reviewsCount,
  });

  factory AttractionDto.fromJson(Map<String, dynamic> json) {
    return AttractionDto(
      id: (json['id'] ?? 0) as int,
      province: (json['province'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      shortDescription: (json['short_description'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      registrationCost: (json['registration_cost'] ?? '') as String,
      discountCode: (json['discount_code'] ?? '') as String,
      venue: (json['venue'] ?? '') as String,
      latitude: (json['latitude'] ?? '') as String,
      longitude: (json['longitude'] ?? '') as String,
      mapsUrl: (json['maps_url'] ?? '') as String,
      coverImage: (json['cover_image'] ?? '') as String,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
      reviewsCount: (json['reviews_count'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'province': province,
      'title': title,
      'short_description': shortDescription,
      'description': description,
      'registration_cost': registrationCost,
      'discount_code': discountCode,
      'venue': venue,
      'latitude': latitude,
      'longitude': longitude,
      'maps_url': mapsUrl,
      'cover_image': coverImage,
      'average_rating': averageRating,
      'reviews_count': reviewsCount,
    };
  }

  Attraction toEntity() {
    return Attraction(
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
      averageRating: averageRating,
      reviewsCount: reviewsCount,
    );
  }
}
