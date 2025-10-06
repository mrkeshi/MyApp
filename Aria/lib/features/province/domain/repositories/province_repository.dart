import '../entities/province.dart';


abstract class ProvinceRepository {
  Future<Province> getProvinceDetail(int id);
  Future<Province> changeProvinceAndFetch(int id);
}