import '../../domain/entities/province.dart';
import '../../domain/repositories/province_repository.dart';
import '../datasource/province_remote.dart';

class ProvinceRepositoryImpl implements ProvinceRepository {
  final ProvinceRemote remote;
  ProvinceRepositoryImpl(this.remote);

  @override
  Future<Province> getProvinceDetail(int id) async {
    final dto = await remote.getProvinceDetail(id);
    return dto.toEntity();
  }

  @override
  Future<Province> changeProvinceAndFetch(int id) async {
    await remote.changeProvince(id);
    final dto = await remote.getProvinceDetail(id);
    return dto.toEntity();
  }
}