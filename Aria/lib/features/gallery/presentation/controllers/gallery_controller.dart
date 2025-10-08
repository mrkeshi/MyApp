import 'package:flutter/foundation.dart';
import 'package:aria/features/gallery/domain/entities/photo_entity.dart';
import 'package:aria/features/gallery/domain/repositories/photo_repository.dart';

class GalleryController extends ChangeNotifier {
  final PhotoRepository repository;
  GalleryController(this.repository);

  final List<PhotoEntity> _items = [];
  List<PhotoEntity> get items => List.unmodifiable(_items);

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
      final data = await repository.getAttractionPhotos(provinceId: provinceId);

      _items
        ..clear()
        ..addAll(data);

      _hasFetchedForCurrentProvince = true;
      _error = null;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ GalleryController.load error: $e\n$st');
      }
      _error = 'خطا در دریافت تصاویر';
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

      final data = await repository.getAttractionPhotos(provinceId: _currentProvinceId!);
      _items
        ..clear()
        ..addAll(data);

      _error = null;
      _hasFetchedForCurrentProvince = true;
    } catch (e, st) {
      if (kDebugMode) {
        print('❌ GalleryController.refresh error: $e\n$st');
      }
      _error = 'خطا در دریافت تصاویر';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void reset() {
    _items.clear();
    _error = null;
    _hasFetchedForCurrentProvince = false;
    _currentProvinceId = null;
    notifyListeners();
  }
}
