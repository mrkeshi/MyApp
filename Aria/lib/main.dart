import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:aria/app/theme.dart';
import 'package:aria/app/di.dart';
import 'package:aria/app/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final type = await AppTheme.loadTheme();

  runApp(MyApp(initialType: type));
}

class MyApp extends StatelessWidget {
  final AppThemeType initialType;
  const MyApp({super.key, required this.initialType});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: AppDI.providers(),
      child: MaterialApp(
        title: 'My App',
        theme: AppTheme.getTheme(initialType),
        initialRoute: '/',
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
