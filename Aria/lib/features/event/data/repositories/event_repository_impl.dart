import '../../domain/entities/event.dart';
import '../../domain/entities/event_detail.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_data_source.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remote;
  EventRepositoryImpl(this.remote);

  @override
  Future<List<Event>> getEvents() => remote.getEvents();

  @override
  Future<EventDetail> getEventDetail(int id) => remote.getEventDetail(id);

  @override
  Future<void> upsertMyReview({required int eventId, required int rating, required String comment}) =>
      remote.upsertMyReview(eventId: eventId, rating: rating, comment: comment);
}
