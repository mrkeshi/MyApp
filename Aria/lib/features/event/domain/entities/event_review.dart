class EventReview {
  final int id;
  final int user;
  final String userDisplay;
  final String profileImage;
  final int rating;
  final String comment;
  final DateTime createdAt;
  final String  createdAtText;

  const EventReview({
    required this.id,
    required this.user,
    required this.userDisplay,
    required this.profileImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.createdAtText,
  });
}
