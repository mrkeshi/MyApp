import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/open_in_maps.dart';

class InfoCard extends StatelessWidget {
  final dynamic data;
  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final rating = (data.averageRating as num).clamp(0, 5).toDouble();
    final ratingText = faDigits(rating.toStringAsFixed(1));

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(0, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Transform.translate(
                      offset: const Offset(12, 0),
                      child: Row(
                        children: [
                          Container(
                            width: 3,
                            height: 26,
                            margin: const EdgeInsetsDirectional.only(start: 2, end: 8),
                            decoration: BoxDecoration(
                              color: primary,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              data.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Transform.translate(
                    offset: const Offset(0, 0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: primary, size: 18),
                        const SizedBox(height: 2),
                        Text(
                          ratingText,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12.5,
                            fontFamily: 'customy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.shortDescription?.isNotEmpty == true)
                    Text(
                      data.shortDescription,
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'customy',
                        height: 1.6,
                        fontSize: 13,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Transform.translate(
              offset: const Offset(0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (data.venue?.isNotEmpty == true)
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'آدرس: ',
                            style: TextStyle(
                              color: primary,
                              fontWeight: FontWeight.w700,
                              wordSpacing: -1,
                              fontFamily: 'customy',
                            ),
                          ),
                          TextSpan(
                            text: data.venue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'customy',
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              wordSpacing: -1,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
