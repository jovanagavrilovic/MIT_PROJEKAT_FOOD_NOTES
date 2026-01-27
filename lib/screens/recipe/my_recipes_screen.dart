import 'package:flutter/material.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("MY RECIPES", style: TextStyle(fontSize: 24))),
    );
  }
}
