import '../entities/bookmark.dart';

abstract class BookmarkRepository {
  Future<bool> toggle({required String type, required int id});

  Future<Set<int>> listIds({required String type});

  Future<List<Bookmark>> list({required String type});
}
