import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/screens/auth/login_screen.dart';

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
        StreamBuilder<User?>(
    stream: FirebaseAuth.instance.authStateChanges(),
    builder: (context, snapshot) {
      final user = snapshot.data;

      if (user == null) {
        return TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
          child: const Text("Login"),
        );
      }

      return PopupMenuButton<String>(
  child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: SizedBox(
      width: 120,
      child: Text(
        user.displayName ?? user.email ?? "User",
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.right,
      ),
    ),
  ),
  onSelected: (value) async {
    if (value == "logout") {
      await FirebaseAuth.instance.signOut();
    }
  },
  itemBuilder: (_) => [
    const PopupMenuItem(
      value: "logout",
      child: Text("Log out"),
    ),
  ],
);

    },
  ),
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
