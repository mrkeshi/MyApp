  import '../../domain/entities/bookmark.dart';

  class BookmarkDto {
    final int id;
    final String type;
    final String title;
    final String? coverImage;
    final String? address;
    final DateTime createdAt;

    const BookmarkDto({
      required this.id,
      required this.type,
      required this.title,
      required this.coverImage,
      required this.address,
      required this.createdAt,
    });

    factory BookmarkDto.fromJson(Map<String, dynamic> json) {
      return BookmarkDto(
        id: (json['id'] as num).toInt(),
        type: json['type'] as String,
        title: json['title'] as String,
        coverImage: json['cover_image'] as String?,
        address: json['address'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
    }

    Bookmark toEntity() {
      return Bookmark(
        id: id,
        type: type,
        title: title,
        coverImage: coverImage,
        address: address,
        createdAt: createdAt,
      );
    }
  }
