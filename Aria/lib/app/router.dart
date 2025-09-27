import 'package:aria/app/splash_screen.dart';
import 'package:aria/features/home/presentation/pages/welcome_Screen.dart';
import 'package:flutter/material.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/home/presentation/pages/home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => SplashScreen());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case '/welcome':
        return MaterialPageRoute(builder: (_)=>OnboardingScreen());
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
