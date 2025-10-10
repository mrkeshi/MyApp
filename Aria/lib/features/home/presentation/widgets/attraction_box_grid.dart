import 'dart:math' as math;
import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';

class AttractionBoxGrid extends StatelessWidget {
  const AttractionBoxGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        'title': 'جغرافیای\nاستان',
        'icon': 'assets/images/icons/7.png',
        'isNew': false,
        'route': '/about-province',
      },
      {
        'title': 'ماجراجویی\nدر طبیعت',
        'icon': 'assets/images/icons/1.png',
        'isNew': true,
        'route': null,
      },
      {
        'title': 'پیشنهادی\nگردشگران',
        'icon': 'assets/images/icons/3.png',
        'isNew': false,
        'route': null,
      },
      {
        'title': 'جاذبه‌های\nگردشگری',
        'icon': 'assets/images/icons/2.png',
        'isNew': false,
        'route': null,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return _AttractionBox(
          title: item['title'] as String,
          iconPath: item['icon'] as String,
          isNew: item['isNew'] as bool,
          route: item['route'] as String?,
        );
      },
    );
  }
}

class _AttractionBox extends StatelessWidget {
  final String title;
  final String iconPath;
  final bool isNew;
  final String? route;

  const _AttractionBox({
    required this.title,
    required this.iconPath,
    this.isNew = false,
    this.route,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.menuBackground,
          borderRadius: BorderRadius.circular(10),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: route != null
              ? () => Navigator.pushNamed(context, route!)
              : null,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(iconPath, width: 55, height: 55),
                    const SizedBox(width: 15),
                    Flexible(
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          height: 1.9,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isNew)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'بزودی',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
