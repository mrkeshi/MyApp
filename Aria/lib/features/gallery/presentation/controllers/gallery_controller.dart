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

  Future<void> load(int provinceId) async {
    _currentProvinceId = provinceId;
    _loading = true;
    _error = null;
    _items.clear();
    notifyListeners();

    try {
      final data = await repository.getAttractionPhotos(provinceId: provinceId);
      _items.addAll(data);
    } catch (e) {
      _error = 'خطا در دریافت تصاویر';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (_currentProvinceId == null) return;
    try {
      final data = await repository.getAttractionPhotos(provinceId: _currentProvinceId!);
      _items
        ..clear()
        ..addAll(data);
      notifyListeners();
    } catch (_) {
    }
  }
}
