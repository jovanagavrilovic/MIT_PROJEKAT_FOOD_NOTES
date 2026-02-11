import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:food_notes/providers/theme_provider.dart';
import 'package:food_notes/screens/about/about_screen.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            child: Text(
              "Menu",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),

          SwitchListTile(
            title: const Text("Dark Mode"),
            secondary: const Icon(Icons.dark_mode),
            value: themeProvider.isDark,
            onChanged: (val) => context.read<ThemeProvider>().toggleTheme(val),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text("About"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}
