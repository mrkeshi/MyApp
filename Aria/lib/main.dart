import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aria/app/theme.dart';
import 'package:aria/app/di.dart';
import 'package:aria/app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final initialTheme = await AppTheme.loadTheme();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(initialTheme),
      child: const MyApp(),
    ),
  );
}

class ThemeNotifier extends ChangeNotifier {
  AppThemeType _currentTheme;
  ThemeNotifier(this._currentTheme);

  AppThemeType get currentTheme => _currentTheme;

  void setTheme(AppThemeType theme) {
    _currentTheme = theme;
    AppTheme.saveTheme(theme);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = context.watch<ThemeNotifier>();

    return MultiProvider(
      providers: AppDI.providers(),
      child: MaterialApp(
        title: 'My App',
        theme: AppTheme.getTheme(themeNotifier.currentTheme),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
