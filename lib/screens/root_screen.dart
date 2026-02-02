import 'package:flutter/material.dart';

import 'home/home_screen.dart';
import 'recipe/add_recipe_screen.dart';
import 'recipe/my_recipes_screen.dart';
import 'profile/profile_screen.dart';

class RootScreen extends StatefulWidget {
  static const String routeName = "/RootScreen";
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  late final List<Widget> screens;
  int currentScreen = 0;
  late final PageController controller;

  @override
  void initState() {
    super.initState();

    screens =  [
      HomeScreen(),
      AddRecipeScreen(),
      const MyRecipesScreen(),
      const ProfileScreen(),
    ];

    controller = PageController(initialPage: currentScreen);
  }

  @override
  void dispose() {
    controller.dispose(); 
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: PageView(
        physics: const NeverScrollableScrollPhysics(), 
        controller: controller,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentScreen,
        height: kBottomNavigationBarHeight,
        onDestinationSelected: (index) {
          setState(() {
            currentScreen = index;
          });
          controller.jumpToPage(currentScreen);
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: "Add",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.bookmark),
            icon: Icon(Icons.bookmark_border),
            label: "My",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
