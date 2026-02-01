import 'package:flutter/material.dart';
import 'package:food_notes/consts/app_text_styles.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Food Notes"),
      endDrawer: const CustomEndDrawer(),


      body: const Center(
        child: Text(
          "Home screen",
          style: AppTextStyles.appBarTitle,
        ),
      ),
    );
  }
}
