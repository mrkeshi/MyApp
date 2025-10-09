import '../../domain/entities/attraction.dart';
import '../../domain/repositories/attraction_repository.dart';
import '../datasources/attraction_remote_data_source.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  final AttractionRemoteDataSource remote;

  AttractionRepositoryImpl(this.remote);

  @override
  Future<List<Attraction>> get3TopAttractions(int provinceId) async {
    return await remote.getTopAttractions(provinceId);
  }
}
