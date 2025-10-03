import 'package:aria/app/main_nav_host.dart';
import 'package:aria/app/splash_screen.dart';
import 'package:aria/features/home/presentation/pages/settings_screen.dart';
import 'package:aria/features/home/presentation/pages/welcome_Screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/edit_profile_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/otp_page.dart';
import '../features/home/presentation/pages/about-dev_page.dart';
import '../features/home/presentation/pages/home_screen.dart';
import '../features/home/presentation/pages/theme_select_page.dart';


class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => const MainNavHost(initialIndex: 1));
      case '/settings':
        return MaterialPageRoute(builder: (_) => const MainNavHost(initialIndex: 0));
      case '/bookmark':
        return MaterialPageRoute(builder: (_) => const MainNavHost(initialIndex: 2));
      case '/gallery':
        return MaterialPageRoute(builder: (_) => const MainNavHost(initialIndex: 3));
      case '/welcome':
        return MaterialPageRoute(builder: (_) => OnboardingScreen());
      case '/edit-profile':
        return MaterialPageRoute(builder: (_) => EditProfilePage());
      case '/select-theme':
        return MaterialPageRoute(builder: (_) => ThemeSelectPage());
      case '/about-dev':
        return MaterialPageRoute(builder: (_) => AboutDeveloperPage());
      case '/otp': {
        final args = settings.arguments;
        String phone = '';

        if (args is String) {
          phone = args;
        } else if (args is Map) {
          final p = args['phone'];
          if (p is String) phone = p;
        }

        return MaterialPageRoute(builder: (_) => OtpPage(phone: phone));
      }
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found!')),
          ),
        );
    }
  }
}
