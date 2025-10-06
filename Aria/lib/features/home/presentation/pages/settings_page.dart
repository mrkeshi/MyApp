import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      backgroundColor: AppColors.black,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Text(
                    'تنظیمات کاربری',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 26),

                  _SettingItem(
                    title: 'ویرایش پروفایل',
                    icon: Icons.person,
                    iconBg: const Color(0xFF6E6BDE),
                    onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  ),
                  const SizedBox(height: 14),

                  _SettingItem(
                    title: 'انتخاب استان',
                    svgPath: 'assets/svg/ir.svg',
                    iconBg: const Color(0xFF8B8B90),
                    onTap: () => Navigator.pushNamed(context, '/choose-province'),
                  ),
                  const SizedBox(height: 14),

                  _SettingItem(
                    title: 'انتخاب تم',
                    icon: Icons.palette,
                    iconBg: const Color(0xFFFFA629),
                    onTap: () => Navigator.pushNamed(context, '/select-theme'),
                  ),
                  const SizedBox(height: 14),
                  _SettingItem(
                    title: 'درباره توسعه‌دهنده',
                    icon: Icons.code_rounded,
                    iconBg: const Color(0xFF2ED573),
                    onTap: () => Navigator.pushNamed(context, '/about-dev'),
                  ),

                  const SizedBox(height: 14),
                  _SettingItem(
                    title: 'خروج از حساب کاربری',
                    icon: Icons.exit_to_app,
                    iconBg: const Color(0xFFE74C3C),
                    onTap: () {
                      _showLogoutDialog(context, authController);
                    },
                  ),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),

    );
  }

  void _showLogoutDialog(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'آیا مطمئن هستید؟',
            textAlign: TextAlign.right,
          ),
          content: const Text(
            'آیا می‌خواهید از حساب کاربری خود خارج شوید؟',
            textAlign: TextAlign.right,
          ),
          actions: <Widget>[
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('خیر'),
              ),
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  bool success = await authController.logout();
                  if (success) {
                    Navigator.pushReplacementNamed(context, '/welcome');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('مشکلی در خروج از حساب کاربری پیش آمده')),
                    );
                  }
                },
                child: const Text('بله'),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData? icon;
  final String? svgPath;
  final Color iconBg;
  final VoidCallback onTap;

  const _SettingItem({
    required this.title,
    this.icon,
    this.svgPath,
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
              Container(
                height: 44,
                width: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: svgPath != null
                      ? SvgPicture.asset(
                    svgPath!,
                    width: 28,
                    height: 28,
                    color: Colors.white,
                  )
                      : Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 15),

              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
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


