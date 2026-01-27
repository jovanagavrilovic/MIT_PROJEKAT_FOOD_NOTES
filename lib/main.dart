import 'package:flutter/material.dart';
import 'package:food_notes/consts/theme_data.dart';
import 'screens/root_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Notes',
      theme: Styles.themeData(isDarkTheme: false, context: context),
      home: const RootScreen(),
    );
  }
}
