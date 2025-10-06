import 'package:aria/features/gallery/domain/entities/photo_entity.dart';
import 'package:aria/features/gallery/domain/repositories/photo_repository.dart';
import 'package:aria/features/gallery/data/datasources/photo_remote_data_source.dart';

class PhotoRepositoryImpl implements PhotoRepository {
  final PhotoRemoteDataSource remote;
  PhotoRepositoryImpl(this.remote);

  @override
  Future<List<PhotoEntity>> getAttractionPhotos({required int provinceId}) async {

    final items = await remote.fetchPhotos(provinceId);
    return items;
  }
}
