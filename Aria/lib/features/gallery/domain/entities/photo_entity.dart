class PhotoEntity {
  final int id;
  final String imageUrl;
  final String? title;
  final String? locationLabel;

  const PhotoEntity({
    required this.id,
    required this.imageUrl,
    this.title,
    this.locationLabel,
  });
}
