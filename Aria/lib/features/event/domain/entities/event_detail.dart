import 'event.dart';
import 'event_review.dart';

class EventDetail extends Event {
  final List<EventReview> reviews;

  const EventDetail({
    required super.id,
    required super.province,
    required super.title,
    required super.shortDescription,
    required super.description,
    required super.registrationCost,
    required super.discountCode,
    required super.venue,
    required super.latitude,
    required super.longitude,
    required super.mapsUrl,
    required super.coverImage,
    required super.startAt,
    required super.averageRating,
    required super.reviewsCount,
    required this.reviews,
  });
}
