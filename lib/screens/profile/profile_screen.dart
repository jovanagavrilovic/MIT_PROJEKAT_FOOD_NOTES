import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      endDrawer: const CustomEndDrawer(),

      body: Center(child: Text("PROFILE", style: TextStyle(fontSize: 24))),
    );
  }
}
