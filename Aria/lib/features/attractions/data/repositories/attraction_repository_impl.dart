import '../../domain/entities/attraction.dart';
import '../../domain/entities/attraction_detail.dart';
import '../../domain/entities/attraction_search_result.dart';
import '../../domain/repositories/attraction_repository.dart';
import '../datasources/attraction_remote_data_source.dart';

class AttractionRepositoryImpl implements AttractionRepository {
  final AttractionRemoteDataSource remote;

  AttractionRepositoryImpl(this.remote);

  @override
  Future<List<Attraction>> get3TopAttractions(int provinceId) async {
    return await remote.getTopAttractions(provinceId);
  }

  @override
  Future<List<Attraction>> get10TopAttractions(int provinceId) async {
    return await remote.getTop10Attractions(provinceId);
  }

  @override
  Future<List<Attraction>> getAttractions() async {
    return await remote.getAttractions();
  }

  @override
  Future<AttractionDetail> getAttractionDetail(int id) async {
    return await remote.getAttractionDetail(id);
  }

  @override
  Future<List<AttractionSearchResult>> searchAttractions(String query) async {
    return await remote.searchAttractions(query);
  }
}
