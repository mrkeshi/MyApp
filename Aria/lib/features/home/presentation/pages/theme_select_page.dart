// lib/features/settings/presentation/pages/theme_select_page.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/theme.dart';
import '../../../../shared/styles/colors.dart';

class ThemeSelectPage extends StatefulWidget {
  const ThemeSelectPage({super.key});

  @override
  State<ThemeSelectPage> createState() => _ThemeSelectPageState();
}

class _ThemeSelectPageState extends State<ThemeSelectPage> {
  final PageController _pageController =
  PageController(viewportFraction: 0.82, keepPage: true);

  late int _index;
  late AppThemeType _selected;

  final _items = <AppThemeType, _ThemeCardData>{
    AppThemeType.yellow: _ThemeCardData(
      title: 'نقش جهان',
      image: 'assets/images/themes/a1.jpg',
      keyName: 'yellow',
    ),
    AppThemeType.blue: _ThemeCardData(
      title: 'آزادی',
      image: 'assets/images/themes/a3.jpg',
      keyName: 'blue',
    ),
    AppThemeType.red: _ThemeCardData(
      title: 'نصیرالدین',
      image: 'assets/images/themes/a2.jpg',
      keyName: 'red',
    ),
  };

  @override
  void initState() {
    super.initState();
    _index = 0;
    _selected = AppThemeType.yellow;
    _load();
  }

  Future<void> _load() async {
    final type = await AppTheme.loadTheme();
    final i = AppThemeType.values.indexOf(type);
    setState(() {
      _index = i;
      _selected = type;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pageController.jumpToPage(_index);
    });
  }

  Color get _primary => AppTheme.getTheme(_selected).primaryColor;

  @override
  Widget build(BuildContext context) {
    final background = _items[_selected]!.image;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(background, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.65),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          color: Colors.white,
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'انتخاب تم',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'از شکوه نقش‌جهان و رنگ‌های نصیرالملک تا شکوه میدان آزادی؛ همه ایران اینجاست.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.right,
                    ),
                    const SizedBox(height: 16),

                    // Slider
                    SizedBox(
                      height: 360,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (i) {
                          final t = AppThemeType.values[i];
                          setState(() {
                            _index = i;
                            _selected = t;
                          });
                        },
                        itemCount: _items.length,
                        itemBuilder: (context, i) {
                          final type = AppThemeType.values[i];
                          final data = _items[type]!;
                          final isSelected = i == _index;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 10),
                            child: _ThemeCard(
                              data: data,
                              accent: AppTheme.getTheme(type).primaryColor,
                              isSelected: isSelected,
                              onTap: () {
                                _pageController.animateToPage(
                                  i,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Dots indicator (RTL-friendly)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _items.length,
                            (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _index ? 18 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _index
                                ? _primary
                                : Colors.white.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Save button
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primary,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          await AppTheme.saveTheme(_selected);
                          if (context.mounted) {
                            Navigator.pop(context, _selected);
                          }
                        },
                        child: const Text(
                          'ذخیره',
                          style: TextStyle(
                            fontFamily: 'Customy',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeCardData {
  final String title;
  final String image;
  final String keyName;
  const _ThemeCardData({
    required this.title,
    required this.image,
    required this.keyName,
  });
}

class _ThemeCard extends StatelessWidget {
  final _ThemeCardData data;
  final Color accent;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.data,
    required this.accent,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isSelected ? 1.0 : 0.96,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: accent.withOpacity(0.45),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  data.image,
                  fit: BoxFit.cover,
                ),
                // soft overlay for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.center,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.75),
                      ],
                    ),
                  ),
                ),
                // title
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Text(
                            data.title,
                            style: const TextStyle(
                              fontFamily: 'Customy',
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (isSelected)
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: accent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
