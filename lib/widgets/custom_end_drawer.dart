import 'package:flutter/material.dart';
import 'package:food_notes/consts/app_colors.dart';
import 'package:provider/provider.dart';

import 'package:food_notes/providers/theme_provider.dart';
import 'package:food_notes/screens/about/about_screen.dart';
import 'package:food_notes/screens/admin/admin_users_screen.dart';
import 'package:food_notes/screens/nutrition/nutrition_search_screen.dart';

class CustomEndDrawer extends StatelessWidget {
  final bool isAdmin;

  const CustomEndDrawer({super.key, this.isAdmin = false});
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: context.watch<ThemeProvider>().isDark
          ? AppColors.darkSurface
          : AppColors.lightSurface,
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
            title: const Text("Switch Theme"),
            secondary: const Icon(Icons.dark_mode),
            value: context.watch<ThemeProvider>().isDark,
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
          ListTile(
            leading: const Icon(Icons.restaurant_menu),
            title: const Text("Nutrition search"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NutritionSearchScreen(),
                ),
              );
            },
          ),

          if (isAdmin) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text("Manage Users"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
