class AttractionPhoto {
  final int id;
  final String image;
  final String title;
  final int order;
  final String createdAt;

  const AttractionPhoto({
    required this.id,
    required this.image,
    required this.title,
    required this.order,
    required this.createdAt,
  });
}

class AttractionReview {
  final int id;
  final int user;
  final String userDisplay;
  final int rating;
  final String comment;
  final String createdAt;

  const AttractionReview({
    required this.id,
    required this.user,
    required this.userDisplay,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class AttractionDetail {
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
  final List<AttractionPhoto> photos;
  final List<AttractionReview> reviews;

  const AttractionDetail({
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
}
