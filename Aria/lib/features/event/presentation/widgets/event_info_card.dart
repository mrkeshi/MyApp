import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/styles/colors.dart';
import '../../domain/entities/event_detail.dart';

class EventInfoCard extends StatefulWidget {
  final EventDetail data;
  const EventInfoCard({super.key, required this.data});

  @override
  State<EventInfoCard> createState() => _EventInfoCardState();
}

class _EventInfoCardState extends State<EventInfoCard> {
  late Timer _timer;

  String _faDigits(String s) {
    const en = ['0','1','2','3','4','5','6','7','8','9'];
    const fa = ['۰','۱','۲','۳','۴','۵','۶','۷','۸','۹'];
    var out = s;
    for (var i = 0; i < 10; i++) { out = out.replaceAll(en[i], fa[i]); }
    return out;
  }

  Duration get _remaining {
    final now = DateTime.now().toUtc();
    final target = widget.data.startAt.toUtc();
    final d = target.difference(now);
    return d.isNegative ? Duration.zero : d;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final rem = _remaining;
    final days = rem.inDays;
    final hours = rem.inHours.remainder(24);
    final minutes = rem.inMinutes.remainder(60);
    final venueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontSize: 11.5,
      wordSpacing: -2,
    );

    Widget unitBox(String value, String label) {
      return Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_faDigits(value), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.black)),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
          ],
        ),
      );
    }

    Widget sep() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(':', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: primary, height: 1)),
    );

    final costText = (widget.data.registrationCost ?? '').trim();
    final costFa = costText.isNotEmpty ? '${_faDigits(costText)} هزار تومان' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 15),
        Center(
          child: Text('زمان باقی مانده', style: TextStyle(color: primary, fontWeight: FontWeight.w700, fontSize: 12)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            unitBox(minutes.toString().padLeft(2, '0'), 'دقیقه'),
            sep(),
            unitBox(hours.toString().padLeft(2, '0'), 'ساعت'),
            sep(),
            unitBox(days.toString().padLeft(2, '0'), 'روز'),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Container(width: 3, height: 26, margin: const EdgeInsetsDirectional.only(start: 2, end: 8),
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(2))),
            Expanded(
              child: Text(
                widget.data.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (widget.data.shortDescription.isNotEmpty)
          Text(
            widget.data.shortDescription,
            textAlign: TextAlign.justify,
            style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 12.5),
          ),
        const SizedBox(height: 10),
        if (costFa.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'هزینه ثبت نام: ', style: TextStyle(color: primary, fontFamily: 'customy', fontSize: 12, fontWeight: FontWeight.w700)),
                TextSpan(text: costFa, style: const TextStyle(color: Colors.white, fontFamily: 'customy',fontSize: 12.5, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        if ((widget.data.discountCode ?? '').isNotEmpty) ...[
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'کد تخفیف: ', style: TextStyle(color: primary, fontFamily: 'customy', fontWeight: FontWeight.w700, fontSize: 12)),
                TextSpan(text: widget.data.discountCode!, style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w300)),
              ],
            ),
          ),
        ],
        if (widget.data.venue.isNotEmpty) ...[
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(text: 'محل برگزاری: ', style: TextStyle(color: primary, fontFamily: 'customy', fontWeight: FontWeight.w700, fontSize: 12)),
                TextSpan(text: widget.data.venue, style: venueStyle ?? const TextStyle(color: Colors.white, fontSize: 12.5, wordSpacing: -3)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
