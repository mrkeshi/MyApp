import 'dart:async';
import 'package:aria/app/theme.dart';
import 'package:aria/shared/styles/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:aria/features/home/presentation/pages/home_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool hasError = false;

  AppThemeType? _themeType;
  late AnimationController _controller;
  Animation<Color?>? _colorAnimation;

  String _bgByTheme(AppThemeType t) {
    switch (t) {
      case AppThemeType.yellow:
        return 'assets/images/theme/yellow.png';
      case AppThemeType.red:
        return 'assets/images/theme/red.png';
      case AppThemeType.blue:
      default:
        return 'assets/images/theme/blue.png';
    }
  }

  Color _primaryByTheme(AppThemeType t) {
    switch (t) {
      case AppThemeType.yellow:
        return AppColors.yellowPrimary;
      case AppThemeType.red:
        return AppColors.redPrimary;
      case AppThemeType.blue:
      default:
        return AppColors.bluePrimary;
    }
  }

  @override
  void initState() {
    super.initState();
    _initThemeThenCheck();
  }

  Future<void> _initThemeThenCheck() async {
    final t = await AppTheme.loadTheme();
    final primary = _primaryByTheme(t);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _colorAnimation = ColorTween(
      begin: primary,
      end: Colors.white,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    setState(() => _themeType = t);

    _checkConnection();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    try {
      final bool isConnected = await InternetConnection().hasInternetAccess;
      if (isConnected) {
        _checkJWT();
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<void> _checkJWT() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token');

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      if (token != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _retryConnection() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    _checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    if (_themeType == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final bg = _bgByTheme(_themeType!);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(bg, fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              children: [
                SizedBox(height: h * 0.25),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'آریا گرد',
                      style: TextStyle(
                        fontSize: 120,
                        fontFamily: 'jahan',
                        color: Colors.white,
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -25),
                      child: Text(
                        'ایران، سرزمین افسانه‌ها',
                        style: TextStyle(
                          fontFamily: 'Customy',
                          color: AppColors.gray,
                          fontSize: 20,
                          fontWeight: FontWeight.w100,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: h * 0.23),

                if (isLoading && _colorAnimation != null)
                  AnimatedBuilder(
                    animation: _colorAnimation!,
                    builder: (context, child) {
                      final color = _colorAnimation!.value ?? _primaryByTheme(_themeType!);
                      return ColorFiltered(
                        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                        child: Image.asset(
                          'assets/svg/loading.png',
                          width: 180,
                          height: 180,
                        ),
                      );
                    },
                  ),

                if (hasError || (!hasError && !isLoading))
                  const SizedBox(height: 20),

                if (hasError)
                  Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'لطفا اتصال به اینترنت دستگاه خود را چک کنید و دوباره تلاش کنید',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Customy',
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _retryConnection,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 32),
                          elevation: 1,
                        ),
                        child: const Text(
                          'تلاش دوباره',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Customy',
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
