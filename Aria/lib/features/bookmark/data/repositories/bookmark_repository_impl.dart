import 'package:aria/features/bookmark/domain/entities/bookmark.dart';

import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_data_source.dart';
import '../models/bookmark_dto.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final BookmarkRemoteDataSource remote;
  BookmarkRepositoryImpl(this.remote);

  @override
  Future<bool> toggle({required String type, required int id}) {
    return remote.toggle(type: type, id: id);
  }

  @override
  Future<Set<int>> listIds({required String type}) {
    return remote.listIds(type: type);
  }

  @override
  Future<List<Bookmark>> list({required String type}) async {
    final dtos = await remote.list(type: type);
    return dtos.map((e) => e.toEntity()).toList();
  }
}
