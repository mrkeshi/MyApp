import 'package:flutter/foundation.dart';
import '../../domain/entities/attraction.dart';
import '../../domain/repositories/attraction_repository.dart';

class AttractionsController extends ChangeNotifier {
  final AttractionRepository repository;

  AttractionsController(this.repository);

  final List<Attraction> _items = [];
  List<Attraction> get items => List.unmodifiable(_items);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  int? _currentProvinceId;
  int? get currentProvinceId => _currentProvinceId;

  bool _hasFetchedForCurrentProvince = false;

  Future<void> load(int provinceId, {bool force = false}) async {
    if (_loading) return;

    if (!force && _hasFetchedForCurrentProvince && _currentProvinceId == provinceId) {
      return;
    }

    _currentProvinceId = provinceId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.get3TopAttractions(provinceId);
      print("fetch if");
      _items
        ..clear()
        ..addAll(data);
      _hasFetchedForCurrentProvince = true;
    } catch (e, st) {
      if (kDebugMode) print('❌ AttractionsController.load error: $e\n$st');
      _error = 'خطا در دریافت جاذبه‌ها';
      _hasFetchedForCurrentProvince = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentProvinceId == null || _loading) return;

    try {
      _loading = true;
      notifyListeners();

      final data = await repository.get3TopAttractions(_currentProvinceId!);
      _items
        ..clear()
        ..addAll(data);
      _error = null;
      _hasFetchedForCurrentProvince = true;
    } catch (e, st) {
      if (kDebugMode) print('❌ AttractionsController.refresh error: $e\n$st');
      _error = 'خطا در دریافت جاذبه‌ها';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
