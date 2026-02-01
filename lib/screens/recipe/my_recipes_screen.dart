import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';

class MyRecipesScreen extends StatelessWidget {
  const MyRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: const CustomAppBar(title: "My Recipes"),
      endDrawer: const CustomEndDrawer(),


      body: Center(child: Text("MY RECIPES", style: TextStyle(fontSize: 24))),
    );
  }
}
