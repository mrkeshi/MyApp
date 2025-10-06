import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../features/gallery/presentation/pages/gallery_page.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/home/presentation/pages/settings_page.dart';
import '../shared/styles/colors.dart';

class MainNavHost extends StatefulWidget {
  final int initialIndex;
  const MainNavHost({super.key, this.initialIndex = 1});

  @override
  State<MainNavHost> createState() => _MainNavHostState();
}

class _MainNavHostState extends State<MainNavHost> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Widget> _pages = [

    SettingsPage(),
    HomePage(),
    // BookmarkPage(),
    GalleryPage(),
  ];

  final List<IconData> _icons = [
    Icons.settings_outlined,

    Icons.bookmark_outline,
    Icons.image_outlined,
    Icons.home_outlined,

  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _selectedIndex);
  }

  void _onNavBarTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: AppColors.black,
      body: PageView(
        controller: _pageController,
        children: _pages,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.menuBackground.withOpacity(0.95),
              AppColors.menuBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            bool isSelected = index == _selectedIndex;

            return GestureDetector(
              onTap: () => _onNavBarTapped(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? primary.withOpacity(0.2) : Colors.transparent,
                ),
                child: Icon(
                  _icons[index],
                  color: isSelected ? primary : AppColors.iconColor,
                  size: 28,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
