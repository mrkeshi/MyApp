import 'package:flutter/foundation.dart';

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

  bool _postingReview = false;
  bool get postingReview => _postingReview;

  Future<void> fetchAll() async {
    if (_loadingList) return;
    _loadingList = true;
    notifyListeners();
    try {
      final res = await repository.getEvents();
      _items
        ..clear()
        ..addAll(res);
    } finally {
      _loadingList = false;
      notifyListeners();
    }
  }

  EventDetail? getCachedDetail(int id) => _detailCache[id];

  Future<EventDetail?> fetchDetail(int id, {bool force = false}) {
    if (!force && _detailCache.containsKey(id)) return SynchronousFuture(_detailCache[id]!);
    final existing = _inflightDetail[id];
    if (existing != null) return existing;
    final fut = _doFetchDetail(id);
    _inflightDetail[id] = fut;
    fut.whenComplete(() => _inflightDetail.remove(id));
    return fut;
  }

  Future<EventDetail?> _doFetchDetail(int id) async {
    try {
      final detail = await repository.getEventDetail(id);
      _detailCache[id] = detail;
      notifyListeners();
      return detail;
    } catch (_) {
      return null;
    }
  }

  Future<bool> submitMyReview(int eventId, {required int rating, required String comment}) async {
    if (_postingReview) return false;
    _postingReview = true;
    notifyListeners();
    try {
      await repository.upsertMyReview(eventId: eventId, rating: rating, comment: comment);
      await fetchDetail(eventId, force: true);
      return true;
    } catch (_) {
      return false;
    } finally {
      _postingReview = false;
      notifyListeners();
    }
  }
}
