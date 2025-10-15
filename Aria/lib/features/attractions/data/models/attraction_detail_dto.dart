import '../../domain/entities/attraction_detail.dart';

class AttractionPhotoDto {
  final int id;
  final String image;
  final String title;
  final int order;
  final String createdAt;

  const AttractionPhotoDto({
    required this.id,
    required this.image,
    required this.title,
    required this.order,
    required this.createdAt,
  });

  factory AttractionPhotoDto.fromJson(Map<String, dynamic> json) {
    return AttractionPhotoDto(
      id: (json['id'] ?? 0) as int,
      image: (json['image'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      order: (json['order'] ?? 0) as int,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }

  AttractionPhoto toEntity() {
    return AttractionPhoto(
      id: id,
      image: image,
      title: title,
      order: order,
      createdAt: createdAt,
    );
  }
}

class AttractionReviewDto {
  final int id;
  final int user;
  final String userDisplay;
  final int rating;
  final String comment;
  final String createdAt;
  final String? createdAtText;
  final String? profileImage;

  const AttractionReviewDto({
    required this.id,
    required this.user,
    required this.userDisplay,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.createdAtText,
    this.profileImage,
  });

  factory AttractionReviewDto.fromJson(Map<String, dynamic> json) {
    return AttractionReviewDto(
      id: (json['id'] ?? 0) as int,
      user: (json['user'] ?? 0) as int,
      userDisplay: (json['user_display'] ?? '') as String,
      rating: (json['rating'] ?? 0) as int,
      comment: (json['comment'] ?? '') as String,
      createdAt: (json['created_at'] ?? '') as String,
      createdAtText: json['created_at_text'] as String?,
      profileImage: json['profile_image'] as String?,
    );
  }

  AttractionReview toEntity() {
    return AttractionReview(
      id: id,
      user: user,
      userDisplay: userDisplay,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
      createdAtText: createdAtText,
      profileImage: profileImage,
    );
  }
}

class AttractionDetailDto {
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
  final List<AttractionPhotoDto> photos;
  final List<AttractionReviewDto> reviews;

  const AttractionDetailDto({
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
    required this.photos,
    required this.reviews,
  });

  factory AttractionDetailDto.fromJson(Map<String, dynamic> json) {
    return AttractionDetailDto(
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
      photos: (json['photos'] as List<dynamic>? ?? [])
          .map((e) => AttractionPhotoDto.fromJson(e))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((e) => AttractionReviewDto.fromJson(e))
          .toList(),
    );
  }

  AttractionDetail toEntity() {
    return AttractionDetail(
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
      photos: photos.map((p) => p.toEntity()).toList(),
      reviews: reviews.map((r) => r.toEntity()).toList(),
    );
  }
}
