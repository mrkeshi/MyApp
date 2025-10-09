import '../entities/attraction.dart';

abstract class AttractionRepository {
  Future<List<Attraction>> get3TopAttractions(int provinceId);
}
