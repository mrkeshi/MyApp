import 'package:characters/characters.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/event_detail.dart';
import '../controller/events_controller.dart';
import '../pages/event_review_form_page.dart';

class EventReviewsSection extends StatelessWidget {
  final EventDetail data;
  const EventReviewsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    const commentColor = Color(0xFFC8C8C8);
    const dateColor = Color(0xFFC8C8C8);
    final ctrl = context.watch<EventsController>();
    final detail = ctrl.getCachedDetail(data.id) ?? data;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('نظرات کاربران', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              DecoratedBox(
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      final controller = context.read<EventsController>();
                      final res = await showModalBottomSheet<bool>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => ChangeNotifierProvider.value(
                          value: controller,
                          child: FractionallySizedBox(
                            heightFactor: 0.85,
                            child: EventReviewFormSheet(eventId: data.id),
                          ),
                        ),
                      );
                      if (res == true) {
                        await controller.fetchDetail(data.id, force: true);
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      child: Text('ثبت نظر', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (detail.reviews.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('نظری ثبت نشده است', style: TextStyle(color: Colors.white70)),
              ),
            )
          else
            ...detail.reviews.take(10).map<Widget>((r) {
              final String userName = (r.userDisplay ?? '').toString().trim();
              final String userInitial = userName.isNotEmpty ? userName.characters.first : '؟';
              final String avatarUrl = (r.profileImage ?? '').toString().trim();
              final String dateLabel = faDigits((r.createdAtText?? ''));

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: primary, width: 1)),
                        child: CircleAvatar(
                          backgroundColor: Colors.transparent,
                          backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                          child: avatarUrl.isEmpty ? Text(userInitial, style: const TextStyle(color: Colors.black)) : null,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(userName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(dateLabel, style: const TextStyle(color: dateColor, fontSize: 11)),
                        ]),
                      ),
                      Row(textDirection: TextDirection.ltr, children: [
                        Text('(${faDigits(r.rating.toString())})', style: const TextStyle(color: Colors.white, fontSize: 8)),
                        const SizedBox(width: 3),
                        ...List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 15, color: primary)),
                      ]),
                    ]),
                    const SizedBox(height: 8),
                    Text(
                      (r.comment ?? '').toString(),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(fontSize: 12.5, color: commentColor, wordSpacing: -2),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
