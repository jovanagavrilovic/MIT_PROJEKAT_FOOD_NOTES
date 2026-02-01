import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';

class AddRecipeScreen extends StatelessWidget {
  const AddRecipeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: const CustomAppBar(title: "Add Recipe"),
     endDrawer: const CustomEndDrawer(),

      body: Center(child: Text("ADD RECIPE", style: TextStyle(fontSize: 24))),
    );
  }
}
