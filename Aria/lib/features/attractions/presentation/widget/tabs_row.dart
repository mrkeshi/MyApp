import 'package:flutter/material.dart';
import '../../../../shared/styles/colors.dart';

class TabsRow extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const TabsRow({super.key, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final items = const ['جزئیات بیشتر', 'مسیر‌یابی با نقشه', 'نظرات کاربران'];

    return Container(
      decoration: BoxDecoration(color: AppColors.menuBackground, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = index == i;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: selected ? primary : Colors.transparent, width: 2)),
                ),
                child: Center(
                  child: Text(
                    items[i],
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.gray,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
