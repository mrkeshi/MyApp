import '../../domain/entities/photo_entity.dart';

class PhotoModel extends PhotoEntity {
  const PhotoModel({
    required super.id,
    required super.imageUrl,
    super.title,
    super.locationLabel,
  });

  factory PhotoModel.fromJson(Map<String, dynamic> json) {
    final dynamic urlCandidate =
        json['image'] ?? json['url'] ?? json['file'] ?? json['photo'] ?? json['src'];

    return PhotoModel(
      id: (json['id'] ?? json['pk'] ?? 0) as int,
      imageUrl: urlCandidate is Map
          ? (urlCandidate['url'] ?? urlCandidate['original'] ?? '').toString()
          : (urlCandidate?.toString() ?? ''),
      title: (json['title'] ?? json['name'] ?? json['caption'])?.toString(),
      locationLabel: (json['location'] ?? json['place'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'image': imageUrl,
    if (title != null) 'title': title,
    if (locationLabel != null) 'location': locationLabel,
  };
}
