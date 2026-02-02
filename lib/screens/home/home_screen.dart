import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../recipe/recipe_details_screen.dart';



class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final RecipeService _recipeService = RecipeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Food Notes"),
      endDrawer: const CustomEndDrawer(),


      body: StreamBuilder<List<Recipe>>(
  stream: _recipeService.getRecipes(),
  builder: (context, snapshot) {

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (snapshot.hasError) {
    return Center(
      child: Text("Error: ${snapshot.error}"),
    );
  }

    final recipes = snapshot.data ?? [];

    if (recipes.isEmpty) {
      return const Center(child: Text("No recipes yet"));
    }

    return GridView.builder(
  padding: const EdgeInsets.all(16),
  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.85,
  ),
  itemCount: recipes.length,
  itemBuilder: (context, index) {
    final r = recipes[index];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RecipeDetailsScreen(recipe: r),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                r.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.image));
                },
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  color: Colors.black54,
                  child: Text(
                    r.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);

  },
),

    );
  }
}
