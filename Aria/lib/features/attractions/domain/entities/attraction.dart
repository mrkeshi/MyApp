class Attraction {
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

  const Attraction({
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

  Attraction copyWith({
    int? id,
    int? province,
    String? title,
    String? shortDescription,
    String? description,
    String? registrationCost,
    String? discountCode,
    String? venue,
    String? latitude,
    String? longitude,
    String? mapsUrl,
    String? coverImage,
    double? averageRating,
    int? reviewsCount,
  }) {
    return Attraction(
      id: id ?? this.id,
      province: province ?? this.province,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      description: description ?? this.description,
      registrationCost: registrationCost ?? this.registrationCost,
      discountCode: discountCode ?? this.discountCode,
      venue: venue ?? this.venue,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      mapsUrl: mapsUrl ?? this.mapsUrl,
      coverImage: coverImage ?? this.coverImage,
      averageRating: averageRating ?? this.averageRating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
    );
  }
}
