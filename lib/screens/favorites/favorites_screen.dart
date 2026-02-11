import 'package:flutter/material.dart';
import 'package:food_notes/models/recipe.dart';
import 'package:food_notes/screens/recipe/recipe_details_screen.dart';
import 'package:food_notes/services/favorites_service.dart';
import 'package:food_notes/services/recipe_service.dart';

class FavoritesScreen extends StatelessWidget {
  final VoidCallback onGoHome;

  FavoritesScreen({super.key,  required this.onGoHome});

  final _favService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final _recipeService = RecipeService();

    return Scaffold(
      appBar: AppBar(title: const Text("Favorites")),
      body: StreamBuilder<List<String>>(
        stream: _favService.favoriteIdsStream(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final ids = snap.data ?? [];

          if (ids.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border,
                      size: 56,
                      color: scheme.primary,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "No favorites yet",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Explore recipes and tap the heart to save them here.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: scheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 46,
                      child: FilledButton.icon(
                        onPressed: () {
                          onGoHome();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.explore_outlined),
                        label: const Text("Explore recipes"),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: ids.length,
            itemBuilder: (_, i) {
              final recipeId = ids[i];

              return StreamBuilder<Recipe?>(
                stream: _recipeService.getRecipeById(recipeId),
                builder: (context, rSnap) {
                  if (rSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final recipe = rSnap.data;
                  if (recipe == null) {
                    return const SizedBox.shrink();
                  }

                  return InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailsScreen(recipe: recipe),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: scheme.outlineVariant.withOpacity(0.6),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: scheme.shadow.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: Image.network(
                                recipe.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Center(child: Icon(Icons.image)),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                10,
                                10,
                                10,
                                12,
                              ),
                              color: scheme.surfaceVariant.withOpacity(0.7),
                              alignment: Alignment.center,
                              child: Text(
                                recipe.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15,
                                  letterSpacing: 0.2,
                                  fontWeight: FontWeight.w700,
                                  color: scheme.onSurface,
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
          );
        },
      ),
    );
  }
}
