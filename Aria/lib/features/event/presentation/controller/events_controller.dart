import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/event.dart';
import '../../domain/entities/event_detail.dart';
import '../../domain/repositories/event_repository.dart';

class EventsController extends ChangeNotifier {
  final EventRepository repository;
  EventsController(this.repository);

  final List<Event> _items = [];
  List<Event> get items => List.unmodifiable(_items);

  final Map<int, EventDetail> _detailCache = {};
  final Map<int, Future<EventDetail?>> _inflightDetail = {};

  bool _loadingList = false;
  bool get loadingList => _loadingList;

  bool _hasFetchedAll = false;

  bool _postingReview = false;
  bool get postingReview => _postingReview;

  String? _error;
  String? get error => _error;

  void clearDetailCache() {
    _detailCache.clear();
  }

  EventDetail? getCachedDetail(int id) => _detailCache[id];

  String _friendlyMessageFromError(Object e) {
    const fallback = 'خطا رخ داد. لطفاً دوباره تلاش کنید';
    if (e is DioException) {
      if (e.type == DioExceptionType.cancel) return 'عملیات لغو شد';
      if (e.type == DioExceptionType.connectionError || e.type == DioExceptionType.unknown) {
        return 'عدم دسترسی به اینترنت یا سرور. اتصال خود را بررسی کنید';
      }
      if (e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout) {
        return 'اتصال کند است. کمی بعد دوباره تلاش کنید';
      }
      final status = e.response?.statusCode ?? 0;
      switch (status) {
        case 400:
          return 'اطلاعات ارسالی نامعتبر است';
        case 401:
          return 'برای انجام این عمل وارد حساب کاربری شوید';
        case 403:
          return 'اجازه انجام این عمل را ندارید';
        case 404:
          return 'مورد موردنظر پیدا نشد';
        case 405:
          return 'روش درخواست نامعتبر است';
        case 409:
          return 'از قبل ثبت شده است';
        case 413:
          return 'متن ارسالی خیلی طولانی است';
        case 422:
          return 'اطلاعات ارسالی ناقص است';
        case 429:
          return 'درخواست‌های زیاد. کمی بعد دوباره تلاش کنید';
        default:
          if (status >= 500 && status < 600) return 'مشکل از سرور است. کمی بعد دوباره تلاش کنید';
          return fallback;
      }
    }
    return fallback;
  }

  // ====== List ======
  Future<void> fetchAll({bool force = false}) async {
    if (_loadingList) return;
    if (!force && _hasFetchedAll) return;

    _loadingList = true;
    _error = null;
    notifyListeners();

    try {
      final res = await repository.getEvents();
      _items
        ..clear()
        ..addAll(res);
      _hasFetchedAll = true;
    } catch (e, st) {
      if (kDebugMode) print('❌ fetchAll error: $e\n$st');
      _error = 'خطا در دریافت رویدادها';
      _hasFetchedAll = false;
    } finally {
      _loadingList = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    if (_loadingList) return;
    await fetchAll(force: true);
  }

  Future<EventDetail?> fetchDetail(int id, {bool force = false}) {
    // از کش
    if (!force && _detailCache.containsKey(id)) {
      return SynchronousFuture(_detailCache[id]!);
    }

    final existing = _inflightDetail[id];
    if (!force && existing != null) return existing;

    final fut = _doFetchDetail(id);
    _inflightDetail[id] = fut;
    fut.whenComplete(() => _inflightDetail.remove(id));
    return fut;
  }

  Future<EventDetail?> _doFetchDetail(int id) async {
    try {
      final detail = await repository.getEventDetail(id);
      if (detail != null) {
        _detailCache[id] = detail;
        notifyListeners();
      }
      return detail;
    } catch (e, st) {
      if (kDebugMode) print('❌ fetchDetail error: $e\n$st');
      _error = 'خطا در دریافت جزئیات رویداد';
      notifyListeners();
      return _detailCache[id];
    }
  }

  Future<bool> submitMyReview(int eventId, {required int rating, required String comment}) async {
    if (_postingReview) return false;
    _postingReview = true;
    _error = null;
    notifyListeners();

    try {
      await repository.upsertMyReview(eventId: eventId, rating: rating, comment: comment);
      await fetchDetail(eventId, force: true);
      return true;
    } catch (e, st) {
      if (kDebugMode) print('❌ submitMyReview error: $e\n$st');
      _error = _friendlyMessageFromError(e);
      return false;
    } finally {
      _postingReview = false;
      notifyListeners();
    }
  }
}
