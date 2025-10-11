import 'package:flutter/material.dart';
import 'package:aria/shared/styles/colors.dart';

class LocalEventsGrid extends StatelessWidget {
  const LocalEventsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final items = [
      {
        'title': 'رویدادهای محلی',
        'subtitle': 'مشاهده تجربه تازه ',
        'icon': 'assets/images/icons/6.png',
        'isNew': false,
        'color': AppColors.menuBackground,
      },
      {
        'title': 'سوغاتی و صنایع دستی',
        'subtitle': '!هدیه‌ای اصیل، خاطره‌ای ماندگار',
        'icon': 'assets/images/icons/4.png',
        'isNew': true,
        'gradient': const LinearGradient(
          colors: [Color(0xFF5A6BFF), Color(0xFF3240D8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'title': 'کافه و رستوران',
        'subtitle': '!لحظه‌هاتو خوشمزه کن',
        'icon': 'assets/images/icons/5.png',
        'isNew': true,
        'gradient': const LinearGradient(
          colors: [Color(0xFFFF6E6E), Color(0xFFD53A3A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 65,
          child: Column(
            children: [
              _LocalEventBoxLeft(
                title: items[1]['title'] as String,
                subtitle: items[1]['subtitle'] as String,
                iconPath: items[1]['icon'] as String,
                isNew: items[1]['isNew'] as bool,
                gradient: items[1]['gradient'] as LinearGradient?,
                primaryColor: colorScheme.primary,
                height: 75,
                iconOffset: const Offset(0, -2),
                iconPaddingRight: 0,
                spaceBetweenTextAndIcon: 0,
                textOffset: const Offset(8, 0),
                onTap: () {
                },
              ),
              const SizedBox(height: 10),
              _LocalEventBoxLeft(
                title: items[2]['title'] as String,
                subtitle: items[2]['subtitle'] as String,
                iconPath: items[2]['icon'] as String,
                isNew: items[2]['isNew'] as bool,
                gradient: items[2]['gradient'] as LinearGradient?,
                primaryColor: colorScheme.primary,
                height: 75,
                iconOffset: const Offset(-8, -5),
                iconPaddingRight: 0,
                spaceBetweenTextAndIcon: 0,
                textOffset: const Offset(0, 0),
                onTap: () {
                  print("Tapped ${items[2]['title']}");
                },
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 35,
          child: _LocalEventBoxRight(
            title: items[0]['title'] as String,
            subtitle: items[0]['subtitle'] as String,
            iconPath: items[0]['icon'] as String,
            isNew: items[0]['isNew'] as bool,
            bgColor: items[0]['color'] as Color,
            primaryColor: colorScheme.primary,
            height: 162,
            iconOffset: const Offset(0, 8),
            textOffset: const Offset(0, 0),
            onTap: () {
              print("Tapped ${items[0]['title']}");
            },
          ),
        ),
      ],
    );
  }
}

class _LocalEventBoxLeft extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final bool isNew;
  final Color primaryColor;
  final LinearGradient? gradient;
  final double? height;
  final Offset iconOffset;
  final double iconPaddingRight;
  final double spaceBetweenTextAndIcon;
  final Offset textOffset;
  final VoidCallback onTap;

  const _LocalEventBoxLeft({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.isNew,
    required this.primaryColor,
    required this.iconOffset,
    required this.textOffset,
    required this.onTap,
    this.gradient,
    this.height,
    this.iconPaddingRight = 0,
    this.spaceBetweenTextAndIcon = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(vertical: 0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (isNew)
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomRight: Radius.circular(6),
                        ),
                      ),
                      child: const Text(
                        'بزودی',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: spaceBetweenTextAndIcon),
                        child: Transform.translate(
                          offset: textOffset,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  wordSpacing: -2,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                subtitle,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  wordSpacing: -3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: iconPaddingRight),
                      child: Transform.translate(
                        offset: iconOffset,
                        child: Image.asset(
                          iconPath,
                          width: 60,
                          height: 65,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LocalEventBoxRight extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconPath;
  final bool isNew;
  final Color? bgColor;
  final Color primaryColor;
  final double? height;
  final Offset iconOffset;
  final Offset textOffset;
  final VoidCallback onTap;

  const _LocalEventBoxRight({
    required this.title,
    required this.subtitle,
    required this.iconPath,
    required this.isNew,
    required this.primaryColor,
    required this.iconOffset,
    required this.textOffset,
    required this.onTap,
    this.bgColor,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          splashColor: Colors.white24,
          highlightColor: Colors.white10,
          child: Container(
            constraints: BoxConstraints(maxHeight: height ?? 170),
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Transform.translate(
                      offset: Offset(0, 10),
                      child: Column(
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              wordSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              wordSpacing: 0.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Transform.translate(
                      offset: Offset(0, 13),
                      child: Image.asset(
                        iconPath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
