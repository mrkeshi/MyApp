import 'package:flutter/material.dart';
import '../../../../shared/styles/colors.dart';
import '../../domain/entities/event_detail.dart';

class EventDetailsSection extends StatefulWidget {
  final EventDetail data;
  const EventDetailsSection({super.key, required this.data});

  @override
  State<EventDetailsSection> createState() => _EventDetailsSectionState();
}

class _EventDetailsSectionState extends State<EventDetailsSection> with TickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final baseText = DefaultTextStyle.of(context).style;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'توضیحات',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: baseText.copyWith(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.5, letterSpacing: 0.1),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: _buildDescription(baseText, primary),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.center,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: BorderRadius.circular(50),
                child: AnimatedRotation(
                  duration: const Duration(milliseconds: 220),
                  turns: _expanded ? 0.5 : 0,
                  child: Icon(Icons.expand_more, color: primary, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );

  }

  Widget _buildDescription(TextStyle baseText, Color primary) {
    final text = (widget.data.description).toString();
    if (text.trim().isEmpty) {
      return Text('توضیحاتی ثبت نشده است.', textAlign: TextAlign.center, style: baseText.copyWith(color: Colors.white38, fontSize: 12));
    }

    final content = Text(
      text,
      textAlign: TextAlign.justify,
      textDirection: TextDirection.rtl,
      style: baseText.copyWith(color: Colors.white70, height: 1.7, fontSize: 13.5, wordSpacing: 0.5),
      maxLines: _expanded ? null : 6,
      overflow: _expanded ? TextOverflow.visible : TextOverflow.fade,
    );

    if (_expanded) return content;

    return Stack(
      children: [
        content,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              alignment: Alignment.bottomCenter,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.menuBackground.withOpacity(0.9)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
