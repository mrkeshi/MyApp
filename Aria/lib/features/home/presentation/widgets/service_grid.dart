import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';

class SoonServicesGrid extends StatelessWidget {
  const SoonServicesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {'title': 'حمل و نقل', 'color': Colors.orange},
      {'title': 'خدمات سفر', 'color': Colors.green},
      {'title': 'تورگردشگری', 'color': Colors.blueAccent},
      {'title': 'اقامتگاه', 'color': Colors.red},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.menuBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items.map((item) {
          return _SoonBox(
            title: item['title'] as String,
            color: item['color'] as Color,
          );
        }).toList(),
      ),
    );
  }
}

class _SoonBox extends StatelessWidget {
  final String title;
  final Color color;

  const _SoonBox({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white24,
            highlightColor: Colors.white10,
            onTap: () {},
            child: Ink(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: AppColors.grayBlack,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'بزودی',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
