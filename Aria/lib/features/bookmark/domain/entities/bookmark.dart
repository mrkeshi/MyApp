class Bookmark {
  final int id;
  final String type;
  final String title;
  final String? coverImage;
  final String? address;
  final DateTime createdAt;

  const Bookmark({
    required this.id,
    required this.type,
    required this.title,
    required this.coverImage,
    required this.address,
    required this.createdAt,
  });
}
