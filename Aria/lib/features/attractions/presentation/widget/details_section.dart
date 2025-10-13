import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/utils/url_abs.dart';
import '../../../../shared/styles/colors.dart';

class DetailsSection extends StatelessWidget {
  final dynamic data;
  const DetailsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('جزئیات بیشتر', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (data.description?.isNotEmpty == true)
          Text(data.description, style: const TextStyle(color: Colors.white, height: 1.6)),
        if (data.photos.isNotEmpty) ...[
          const SizedBox(height: 16),
          const Text('عکس‌ها', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: data.photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(imageUrl: absUrl(data.photos[i].image), width: 220, height: 160, fit: BoxFit.cover),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}
