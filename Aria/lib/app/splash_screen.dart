import 'dart:async';
import 'dart:convert';
import 'package:aria/app/theme.dart';
import 'package:aria/shared/styles/colors.dart';
import 'package:aria/core/network/dio_client.dart'; // ✅ اضافه شد
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import '../features/auth/presentation/controllers/auth_controller.dart';

extension NextStepRoute on NextStep {
  String get route => switch (this) {
    NextStep.welcome        => '/welcome',
    NextStep.chooseProvince => '/choose-province',
    NextStep.editProfile    => '/edit-profile',
    NextStep.home           => '/home',
  };
}
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
        return AppColors.bluePrimary;
      default:
        return AppColors.yellowPrimary;
    }
  }

  @override
  void initState() {
    super.initState();
    _initThemeThenDecide();
  }

  Future<void> _initThemeThenDecide() async {
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

    _startFlow();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _startFlow() async {
    try {
      final hasNet = await InternetConnection().hasInternetAccess;
      if (!hasNet) {
        if (!mounted) return;
        setState(() { isLoading = false; hasError = true; });
        return;
      }

      final auth = context.read<AuthController>();
      final step = await auth.resolveNextStep();
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;

      Navigator.of(context)
          .pushNamedAndRemoveUntil(step.route, (r) => false);
    } catch (_) {
      if (!mounted) return;
      setState(() { isLoading = false; hasError = true; });
    }
  }





  void _retryConnection() {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    _startFlow();
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
                      final color =
                          _colorAnimation!.value ?? _primaryByTheme(_themeType!);
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
