import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFF111314),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text(
                  'تنظیمات کاربری',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 18),

                _SettingItem(
                  title: 'ویرایش پروفایل',
                  icon: Icons.person,
                  iconBg: const Color(0xFF6E6BDE),
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                ),
                const SizedBox(height: 12),

                _SettingItem(
                  title: 'انتخاب استان',
                  icon: Icons.map_rounded,
                  iconBg: const Color(0xFF8B8B90), // خاکستری مطابق شِمای تصویر
                  onTap: () => Navigator.pushNamed(context, '/choose-province'),
                ),
                const SizedBox(height: 12),

                _SettingItem(
                  title: 'انتخاب تم',
                  icon: Icons.wb_sunny_rounded,
                  iconBg: const Color(0xFFFFA629), // نارنجیِ تصویر
                  onTap: () => Navigator.pushNamed(context, '/choose-theme'),
                ),
                const SizedBox(height: 12),

                _SettingItem(
                  title: 'درباره توسعه‌دهنده',
                  icon: Icons.code_rounded,
                  iconBg: const Color(0xFF2ED573), // سبز
                  onTap: () => Navigator.pushNamed(context, '/about-dev'),
                ),

                // فاصله تا منوی پایین
                const Spacer(),
              ],
            ),
          ),
        ),
      ),

      // منوی پایین: TODO
      bottomNavigationBar: _BottomBarTodo(primary: primary),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final VoidCallback onTap;

  const _SettingItem({
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1B1E20),
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2A2E31),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white10, width: 1),
                ),
                child: Center(
                  child: Container(
                    height: 28,
                    width: 28,
                    decoration: BoxDecoration(
                      color: iconBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 18,
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

class _BottomBarTodo extends StatelessWidget {
  final Color primary;
  const _BottomBarTodo({required this.primary});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1C1E),
          border: const Border(
            top: BorderSide(color: Colors.white12, width: 1),
          ),
        ),
        child: Center(
          child: Text(
            'TODO: Bottom Navigation (بعداً جایگزین می‌شود)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
