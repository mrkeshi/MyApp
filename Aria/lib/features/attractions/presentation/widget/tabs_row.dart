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
    final base = DefaultTextStyle.of(context).style;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        removeBottom: true,
        removeLeft: true,
        removeRight: true,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height:55,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.menuBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: List.generate(items.length, (i) {
                  final selected = index == i;
                  return Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onChanged(i),
                      child: Container(
                        alignment: Alignment.center,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Center(
                              child: Text(
                                items[i],
                                textAlign: TextAlign.center,
                                style: (selected
                                    ? base.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                )
                                    : base.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w400,
                                ))
                                    .merge(const TextStyle(fontSize: 12)),
                              ),
                            ),
                            if (selected)
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  height: 3,
                                  width: MediaQuery.of(context).size.width /
                                      items.length -
                                      36,
                                  margin:
                                  const EdgeInsets.only(bottom: 0),
                                  decoration: BoxDecoration(
                                    color: primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
