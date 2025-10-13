import 'package:flutter/material.dart';
import '../../../../core/utils/open_in_maps.dart';
import '../../../../shared/styles/colors.dart';

class MapSection extends StatelessWidget {
  final dynamic data;
  const MapSection({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Container(
            height: 180,
            decoration: const BoxDecoration(
              color: AppColors.grayBlack,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: const Center(child: Icon(Icons.map, size: 64, color: AppColors.gray)),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary, foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => openInMaps(data),
                child: const Text('بازکردن در نقشه'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
