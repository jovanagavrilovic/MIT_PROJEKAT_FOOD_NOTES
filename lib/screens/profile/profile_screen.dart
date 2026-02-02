import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/screens/auth/login_screen.dart';
import 'package:food_notes/screens/auth/register_screen.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      endDrawer: const CustomEndDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: user == null ? _LoggedOutView() : _LoggedInView(user: user),
      ),
    );
  }
}
class _LoggedOutView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.person_outline, size: 80),
          const SizedBox(height: 16),
          const Text(
            "You are not logged in",
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Log in"),
          ),

          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              );
            },
            child: const Text("Create account"),
          ),
        ],
      ),
    );
  }
}

class _LoggedInView extends StatelessWidget {
  final User user;
  const _LoggedInView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.person, size: 80),
        const SizedBox(height: 16),

        Text(
          user.email ?? "No email",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text("UID: ${user.uid}"),

        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            }
          },
          icon: const Icon(Icons.logout),
          label: const Text("Log out"),
        ),
      ],
    );
  }
}
