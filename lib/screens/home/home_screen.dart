import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/services/favorites_service.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../recipe/recipe_details_screen.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onGoProfile;

  HomeScreen({super.key, required this.onGoProfile});
  final RecipeService _recipeService = RecipeService();
  final FavoriteService _favoriteService = FavoriteService();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Food Notes",
        onLoginTap: onGoProfile,
        onProfileTap: onGoProfile,
      ),
      endDrawer: const CustomEndDrawer(),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  TextField(
                    onChanged: (_) {},
                    decoration: InputDecoration(
                      hintText: "Search recipes...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: scheme.surfaceVariant.withOpacity(0.7),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: scheme.outlineVariant.withOpacity(0.6),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: scheme.outlineVariant.withOpacity(0.6),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: scheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _chip("All", true, scheme),
                        _chip("Breakfast", false, scheme),
                        _chip("Lunch", false, scheme),
                        _chip("Dinner", false, scheme),
                        _chip("Dessert", false, scheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<List<Recipe>>(
                stream: _recipeService.getRecipes(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        "Error: ${snapshot.error}",
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final recipes = snapshot.data ?? [];

                  if (recipes.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.menu_book_outlined,
                            size: 56,
                            color: scheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "No recipes yet",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Tap Add to create your first recipe",
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(
                                        r.imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Center(
                                              child: Icon(Icons.image),
                                            ),
                                      ),

                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: StreamBuilder<bool>(
                                          stream: _favoriteService
                                              .isFavoriteStream(r.id),
                                          builder: (context, favSnap) {
                                            final isFav = favSnap.data ?? false;

                                            return Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                onTap: () async {
                                                  try {
                                                    await _favoriteService
                                                        .toggleFavorite(r.id);
                                                  } on FirebaseAuthException {
                                                    if (!context.mounted)
                                                      return;
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Log in to use Favorites",
                                                        ),
                                                      ),
                                                    );
                                                  }
                                                },
                                                child: Container(
                                                  padding: const EdgeInsets.all(
                                                    8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: scheme.surface
                                                        .withOpacity(0.85),
                                                    shape: BoxShape.circle,
                                                    border: Border.all(
                                                      color: scheme
                                                          .outlineVariant
                                                          .withOpacity(0.6),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                    isFav
                                                        ? Icons.favorite
                                                        : Icons.favorite_border,
                                                    color: isFav
                                                        ? Colors.red
                                                        : scheme.onSurface,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
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
                                    r.title,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _chip(String text, bool selected, ColorScheme scheme) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? scheme.primary : scheme.surfaceVariant,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? scheme.onPrimary : scheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}
