import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/event_detail.dart';
import '../controller/events_controller.dart';
import 'event_review_form_page.dart';

class EventDetailPage extends StatefulWidget {
  final int eventId;
  const EventDetailPage({super.key, required this.eventId});
  @override
  State<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends State<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<EventsController>().fetchDetail(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<EventsController>();
    final detail = vm.getCachedDetail(widget.eventId);
    return Scaffold(
      appBar: AppBar(title: Text(detail?.title ?? 'جزئیات رویداد')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(context).push<Map<String, dynamic>>(
            MaterialPageRoute(builder: (_) => EventReviewFormPage()),
          );
          if (result != null) {
            await vm.submitMyReview(widget.eventId, rating: result['rating'] as int, comment: result['comment'] as String);
          }
        },
        child: const Icon(Icons.rate_review),
      ),
      body: detail == null ? const Center(child: CircularProgressIndicator()) : _Body(detail: detail),
    );
  }
}

class _Body extends StatelessWidget {
  final EventDetail detail;
  const _Body({required this.detail});

  @override
  Widget build(BuildContext context) {
    final styleLabel = Theme.of(context).textTheme.bodySmall;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (detail.coverImage.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(detail.coverImage, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 12),
        Text(detail.title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(detail.shortDescription),
        const SizedBox(height: 12),
        Row(children: [
          Text('میانگین امتیاز: ', style: styleLabel),
          Text(detail.averageRating.toStringAsFixed(1)),
          const SizedBox(width: 8),
          Text('تعداد نظرات: ', style: styleLabel),
          Text(detail.reviewsCount.toString()),
        ]),
        const SizedBox(height: 12),
        Text('محل برگزاری: ${detail.venue}'),
        const SizedBox(height: 6),
        Text('زمان شروع: ${detail.startAt.toLocal()}'),
        const SizedBox(height: 12),
        Text(detail.description),
        const SizedBox(height: 16),
        Text('نظرات کاربران', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (detail.reviews.isEmpty)
          const Text('نظری ثبت نشده است')
        else
          Column(
            children: detail.reviews
                .map((r) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(backgroundImage: r.profileImage.isNotEmpty ? NetworkImage(r.profileImage) : null, child: r.profileImage.isEmpty ? const Icon(Icons.person) : null),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Expanded(child: Text(r.userDisplay, style: const TextStyle(fontWeight: FontWeight.bold))),
                        const Icon(Icons.star, size: 16),
                        const SizedBox(width: 4),
                        Text(r.rating.toString()),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.comment),
                      const SizedBox(height: 6),
                      Text(r.createdAt.toLocal().toString(), style: Theme.of(context).textTheme.bodySmall),
                    ]),
                  )
                ],
              ),
            ))
                .toList(),
          ),
        const SizedBox(height: 80),
      ]),
    );
  }
}
