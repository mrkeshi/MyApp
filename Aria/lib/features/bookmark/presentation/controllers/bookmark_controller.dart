import 'package:flutter/foundation.dart';
import '../../domain/entities/bookmark.dart';
import '../../domain/repositories/bookmark_repository.dart';

class BookmarkController extends ChangeNotifier {
  final BookmarkRepository repository;
  BookmarkController(this.repository);

  final List<Bookmark> _items = [];
  List<Bookmark> get items => List.unmodifiable(_items);

  final Set<int> _attractionIds = {};
  final Set<int> _eventIds = {};

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Future<void> loadAll() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        repository.list(type: 'attraction'),
        repository.list(type: 'event'),
      ]);
      final atts = results[0];
      final evs = results[1];
      _items
        ..clear()
        ..addAll(atts)
        ..addAll(evs);
      _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _attractionIds
        ..clear()
        ..addAll(atts.map((e) => e.id));
      _eventIds
        ..clear()
        ..addAll(evs.map((e) => e.id));
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  bool isBookmarked(String type, int id) {
    return type == 'attraction' ? _attractionIds.contains(id) : _eventIds.contains(id);
  }

  Future<void> toggle(String type, int id, {bool removeFromList = true}) async {
    try {
      final bookmarked = await repository.toggle(type: type, id: id);
      if (!bookmarked) {
        if (removeFromList) {
          _items.removeWhere((it) => it.type == type && it.id == id);
        }
        if (type == 'attraction') {
          _attractionIds.remove(id);
        } else {
          _eventIds.remove(id);
        }
      } else {
        if (type == 'attraction') {
          _attractionIds.add(id);
        } else {
          _eventIds.add(id);
        }
        if (removeFromList) {
          final fresh = await repository.list(type: type);
          _items.removeWhere((it) => it.type == type);
          _items.addAll(fresh);
          _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        }
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
