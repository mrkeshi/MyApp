import '../../domain/repositories/bookmark_repository.dart';
import '../datasources/bookmark_remote_data_source.dart';

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
}
