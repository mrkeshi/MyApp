import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../domain/entities/province.dart';
import '../../domain/repositories/province_repository.dart';

class ProvinceController extends ChangeNotifier {
  final ProvinceRepository repo;
  ProvinceController(this.repo);

  Province? province;
  bool loading = false;
  String? errorText;

  Future<void> changeProvinceFromCode(String code) async {
    final parts = code.split('-');
    if (parts.length < 2) {
      errorText = 'کد استان نامعتبر است';
      notifyListeners();
      return;
    }
    final id = int.tryParse(parts[1]);
    if (id == null) {
      errorText = 'شناسه استان نامعتبر است';
      notifyListeners();
      return;
    }
    await changeProvince(id);
  }

  Future<void> changeProvince(int id) async {
    loading = true;
    errorText = null;
    notifyListeners();
    try {
      final p = await repo.changeProvinceAndFetch(id);
      province = p;
    } on DioException catch (e) {
      errorText = (e.error?.toString() ?? e.message ?? 'خطا');
    } catch (e) {
      errorText = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> fetchProvinceDetail(int id) async {
    loading = true;
    errorText = null;
    notifyListeners();
    try {
      province = await repo.getProvinceDetail(id);
    } on DioException catch (e) {
      errorText = (e.error?.toString() ?? e.message ?? 'خطا');
    } catch (e) {
      errorText = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
