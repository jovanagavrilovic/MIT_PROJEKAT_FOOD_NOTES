import 'package:flutter/material.dart';
import 'package:food_notes/consts/app_text_styles.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Food Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          "Home screen",
          style: AppTextStyles.appBarTitle,
        ),
      ),
    );
  }
}
