import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/utils/open_in_maps.dart';
import '../../../../shared/styles/colors.dart';



class InfoCard extends StatelessWidget {
  final dynamic data;
  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final rating = (data.averageRating as num).clamp(0, 5).toDouble();
    final ratingText = '${faDigits(rating.toStringAsFixed(1))} (${faDigits(data.reviewsCount.toString())})';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(Icons.star, color: primary, size: 18),
          const SizedBox(width: 6),
          Text(ratingText, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: AppColors.grayBlack, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              Icon(Icons.favorite_border, size: 16, color: primary),
              const SizedBox(width: 6),
              const Text('FAV', style: TextStyle(color: Colors.white, fontSize: 12)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Text(data.title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        if (data.shortDescription?.isNotEmpty == true)
          const SizedBox(height: 2),
        if (data.shortDescription?.isNotEmpty == true)
          const SizedBox(height: 0),
        if (data.shortDescription?.isNotEmpty == true)
          Text(data.shortDescription, style: const TextStyle(color: Colors.white70, height: 1.5)),
        const SizedBox(height: 8),
        if (data.venue?.isNotEmpty == true)
          Row(children: [
            const Icon(Icons.place, color: Colors.white70, size: 18),
            const SizedBox(width: 6),
            Expanded(child: Text(data.venue, style: const TextStyle(color: Colors.white70))),
            const SizedBox(width: 8),
            TextButton(
              onPressed: () => openInMaps(data),
              style: TextButton.styleFrom(foregroundColor: primary),
              child: const Text('مسیر‌یابی با نقشه'),
            ),
          ]),
      ]),
    );
  }
}
