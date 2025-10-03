import 'dart:async';
import 'dart:convert';
import 'package:aria/app/theme.dart';
import 'package:aria/shared/styles/colors.dart';
import 'package:aria/core/network/dio_client.dart'; // ✅ اضافه شد
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

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
        setState(() {
          isLoading = false;
          hasError = true;
        });
        return;
      }

      final next = await _decideRoute();
      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 800), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, next);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  Future<String> _decideRoute() async {
    final prefs = await SharedPreferences.getInstance();
    final access = prefs.getString('access_token');
    final refresh = prefs.getString('refresh_token');

    if (access != null && access.isNotEmpty && !_isJwtExpired(access)) {
      print("hi");
      print(access);
      return '/home';
    }

    if (refresh != null && refresh.isNotEmpty) {
      final refreshed = await _tryRefreshWithPrefs(prefs, refresh);
      return refreshed ? '/home' : '/welcome';
    }

    return '/welcome';
  }

  bool _isJwtExpired(String jwt) {

    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return true;

      String payload = parts[1].replaceAll('-', '+').replaceAll('_', '/');
      while (payload.length % 4 != 0) {
        payload += '=';
      }
      final decoded =
      json.decode(utf8.decode(base64.decode(payload))) as Map<String, dynamic>;

      final exp = (decoded['exp'] as num?)?.toInt();
      if (exp == null) return true;

      final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      return exp <= nowSec;
    } catch (_) {
      return true;
    }
  }

  Future<bool> _tryRefreshWithPrefs(
      SharedPreferences prefs, String refreshToken) async {
    try {
      final baseUrl = const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'http://10.0.2.2:8000',
      );
      final dio = DioClient(baseUrl: baseUrl).dio;

      final res = await dio.post(
        '/api/v1/auth/refresh/',
        data: {'refresh': refreshToken},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );

      if (res.statusCode == 200 && res.data is Map) {
        final map = res.data as Map;

        final newAccess = (map['access'] ?? map['access_token']) as String?;
        final newRefresh = (map['refresh'] ?? map['refresh_token']) as String?;

        if (newAccess != null && newAccess.isNotEmpty) {
          await prefs.setString('access_token', newAccess);
        }
        if (newRefresh != null && newRefresh.isNotEmpty) {
          await prefs.setString('refresh_token', newRefresh);
        }

        return newAccess != null && newAccess.isNotEmpty;
      }
      return false;
    } catch (_) {
      return false;
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
