import 'package:flutter/material.dart';
import '../../domain/entities/event.dart';
import '../pages/event_detail_page.dart';

class EventCard extends StatelessWidget {
  final Event item;
  const EventCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => EventDetailPage(eventId: item.id),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (item.coverImage.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.coverImage, width: 90, height: 60, fit: BoxFit.cover),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 4),
                Text(item.shortDescription, maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  const Icon(Icons.star, size: 16),
                  const SizedBox(width: 4),
                  Text(item.averageRating.toStringAsFixed(1)),
                  const SizedBox(width: 8),
                  Text('(${item.reviewsCount})'),
                ])
              ]),
            )
          ],
        ),
      ),
    );
  }
}
