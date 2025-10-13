import 'package:flutter/foundation.dart';

import '../../domain/entities/attraction.dart';
import '../../domain/entities/attraction_detail.dart';
import '../../domain/entities/attraction_search_result.dart';
import '../../domain/repositories/attraction_repository.dart';

class AttractionsController extends ChangeNotifier {
  final AttractionRepository repository;

  AttractionsController(this.repository);

  final List<Attraction> _top3Items = [];
  List<Attraction> get top3Items => List.unmodifiable(_top3Items);

  final List<Attraction> _top10Items = [];
  List<Attraction> get top10Items => List.unmodifiable(_top10Items);

  final List<Attraction> _allItems = [];
  List<Attraction> get allItems => List.unmodifiable(_allItems);

  final List<AttractionSearchResult> _searchItems = [];
  List<AttractionSearchResult> get searchItems => List.unmodifiable(_searchItems);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  int? _currentProvinceId;
  int? get currentProvinceId => _currentProvinceId;

  bool _hasFetchedTop3 = false;
  bool _hasFetchedAll = false;

  final Map<int, AttractionDetail> _detailCache = {};
  final Map<int, Future<AttractionDetail?>> _inflightDetail = {};

  AttractionDetail? getCachedDetail(int id) => _detailCache[id];

  void clearDetailCache() {
    _detailCache.clear();
  }

  Future<void> loadTop3(int provinceId, {bool force = false}) async {
    if (_loading) return;
    if (!force && _hasFetchedTop3 && _currentProvinceId == provinceId) return;

    _currentProvinceId = provinceId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.get3TopAttractions(provinceId);
      _top3Items
        ..clear()
        ..addAll(data);
      _hasFetchedTop3 = true;
    } catch (e, st) {
      if (kDebugMode) print('❌ loadTop3 error: $e\n$st');
      _error = 'خطا در دریافت جاذبه‌ها';
      _hasFetchedTop3 = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> refreshTop3() async {
    if (_currentProvinceId == null || _loading) return;
    await loadTop3(_currentProvinceId!, force: true);
  }

  Future<void> loadTop10(int provinceId, {bool force = false}) async {
    if (_loading) return;
    if (!force && _top10Items.isNotEmpty && _currentProvinceId == provinceId) return;

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.get10TopAttractions(provinceId);
      _top10Items
        ..clear()
        ..addAll(data);
    } catch (e, st) {
      if (kDebugMode) print('❌ loadTop10 error: $e\n$st');
      _error = 'خطا در دریافت جاذبه‌ها';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadAllAttractions(int provinceId, {bool force = false}) async {
    if (_loading) return;
    if (!force && _hasFetchedAll && _currentProvinceId == provinceId) return;

    _currentProvinceId = provinceId;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.getAttractions();
      _allItems
        ..clear()
        ..addAll(data);
      _hasFetchedAll = true;
    } catch (e, st) {
      if (kDebugMode) print('❌ loadAllAttractions error: $e\n$st');
      _error = 'خطا در دریافت جاذبه‌ها';
      _hasFetchedAll = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> search(String query) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await repository.searchAttractions(query);
      _searchItems
        ..clear()
        ..addAll(data);
    } catch (e, st) {
      if (kDebugMode) print('❌ search error: $e\n$st');
      _error = 'خطا در جستجوی جاذبه‌ها';
      _searchItems.clear();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<AttractionDetail?> getDetail(int id, {bool force = false}) {
    if (!force && _detailCache.containsKey(id)) {
      return Future.value(_detailCache[id]);
    }

    final inflight = _inflightDetail[id];
    if (!force && inflight != null) {
      return inflight;
    }

    final future = repository.getAttractionDetail(id).then((detail) {
      if (detail != null) {
        _detailCache[id] = detail;
      }
      return detail;
    }).catchError((e, st) {
      if (kDebugMode) print('❌ getDetail error: $e\n$st');
      _error = 'خطا در دریافت جزئیات جاذبه';
      notifyListeners();
      return _detailCache[id];
    }).whenComplete(() {
      _inflightDetail.remove(id);
    });

    _inflightDetail[id] = future;
    return future;
  }
}
