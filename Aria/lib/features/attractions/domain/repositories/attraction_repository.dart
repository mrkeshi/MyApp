import '../entities/attraction.dart';
import '../entities/attraction_detail.dart';
import '../entities/attraction_search_result.dart';

abstract class AttractionRepository {
  Future<List<Attraction>> get3TopAttractions(int provinceId);

  Future<List<Attraction>> get10TopAttractions(int provinceId);

  Future<List<Attraction>> getAttractions();

  Future<AttractionDetail> getAttractionDetail(int id);

  Future<List<AttractionSearchResult>> searchAttractions(String query);

  Future<void> submitReview({required int attractionId, required int rating, required String comment});
}
