import 'package:flutter/material.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../shared/styles/colors.dart';

class ReviewsSection extends StatelessWidget {
  final dynamic data;
  const ReviewsSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    if (data.reviews.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('نظری ثبت نشده است', style: TextStyle(color: Colors.white70))),
      );
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('نظرات کاربران', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...data.reviews.take(10).map((r) => Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.grayBlack, borderRadius: BorderRadius.circular(12)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 14, child: Text(r.userDisplay.isNotEmpty ? r.userDisplay.characters.first : '؟')),
              const SizedBox(width: 8),
              Expanded(child: Text(r.userDisplay, style: const TextStyle(color: Colors.white))),
              Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, size: 16, color: primary))),
            ]),
            const SizedBox(height: 8),
            Text(r.comment, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text(faDigits(r.createdAt), style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ]),
        )),
      ]),
    );
  }
}
