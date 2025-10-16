import '../entities/event.dart';
import '../entities/event_detail.dart';

abstract class EventRepository {
  Future<List<Event>> getEvents();
  Future<EventDetail> getEventDetail(int id);
  Future<void> upsertMyReview({required int eventId, required int rating, required String comment});
}
