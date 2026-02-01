import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      titleSpacing: 0,

      leading: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: Image.asset(
          'assets/images/logo.png',
          width: 30,
          height: 30,
        ),
      ),

      title: Text(title),

      actions: [
  Builder(
    builder: (context) => IconButton(
      icon: const Icon(Icons.menu),
      onPressed: () {
        Scaffold.of(context).openEndDrawer(); 
      },
    ),
  ),
],

    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
