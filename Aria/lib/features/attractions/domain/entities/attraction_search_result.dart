class AttractionSearchResult {
  final int id;
  final String title;
  final String shortDescription;
  final String coverImageUrl;
  final String coverImageName;
  final double averageRating;

  const AttractionSearchResult({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.coverImageUrl,
    required this.coverImageName,
    required this.averageRating,
  });

  AttractionSearchResult copyWith({
    int? id,
    String? title,
    String? shortDescription,
    String? coverImageUrl,
    String? coverImageName,
    double? averageRating,
  }) {
    return AttractionSearchResult(
      id: id ?? this.id,
      title: title ?? this.title,
      shortDescription: shortDescription ?? this.shortDescription,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      coverImageName: coverImageName ?? this.coverImageName,
      averageRating: averageRating ?? this.averageRating,
    );
  }
}
