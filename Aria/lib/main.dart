import 'package:flutter/material.dart';
import 'app/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeType = await AppTheme.loadTheme();

  runApp(MyApp(themeType: themeType));
}

class MyApp extends StatelessWidget {
  final AppThemeType themeType;

  const MyApp({Key? key, required this.themeType}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tourism App',
      theme: AppTheme.getTheme(themeType),
      home: const Scaffold(
        body: Center(child: Text("Hello Tourism App")),
      ),
    );
  }
}
