import '../../domain/entities/attraction_search_result.dart';

class AttractionSearchResultDto {
  final int id;
  final String title;
  final String shortDescription;
  final String coverImageUrl;
  final String coverImageName;
  final double averageRating;

  const AttractionSearchResultDto({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.coverImageUrl,
    required this.coverImageName,
    required this.averageRating,
  });

  factory AttractionSearchResultDto.fromJson(Map<String, dynamic> json) {
    return AttractionSearchResultDto(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      shortDescription: (json['short_description'] ?? '') as String,
      coverImageUrl: (json['cover_image_url'] ?? '') as String,
      coverImageName: (json['cover_image_name'] ?? '') as String,
      averageRating: (json['average_rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'short_description': shortDescription,
      'cover_image_url': coverImageUrl,
      'cover_image_name': coverImageName,
      'average_rating': averageRating,
    };
  }

  AttractionSearchResult toEntity() {
    return AttractionSearchResult(
      id: id,
      title: title,
      shortDescription: shortDescription,
      coverImageUrl: coverImageUrl,
      coverImageName: coverImageName,
      averageRating: averageRating,
    );
  }
}
