import 'package:flutter/material.dart';
import 'package:food_notes/consts/theme_data.dart';
import 'package:food_notes/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'screens/root_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Styles.themeData(
        isDarkTheme: themeProvider.isDark,
        context: context,
      ),
      home: const RootScreen(),
    );
  }
}
