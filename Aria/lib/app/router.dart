import 'package:aria/app/splash_screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen()); // صفحه اسپلش
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen()); // صفحه خانه
      case '/login':
        return MaterialPageRoute(builder: (_) => LoginPage()); // صفحه لاگین
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found!')),
          ),
        );
    }
  }
}
