import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';
import 'package:food_notes/screens/recipe/add_recipe_screen.dart';
import '../../models/recipe.dart';
import 'package:food_notes/screens/recipe/recipe_details_screen.dart';

class MyRecipesScreen extends StatelessWidget {
  final VoidCallback onGoHome;
  final VoidCallback onGoAdd;
  final VoidCallback onGoProfile;

  const MyRecipesScreen({
    super.key,
    required this.onGoHome,
    required this.onGoAdd,
    required this.onGoProfile,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        final user = authSnap.data;

        if (user == null) {
          return Scaffold(
            appBar: CustomAppBar(
              title: "My Recipes",
              onLoginTap: onGoProfile,
              onProfileTap: onGoProfile,
            ),
            endDrawer: const CustomEndDrawer(),
            body: _EmptyCard(
              icon: Icons.lock_outline,
              title: "Log in to see your recipes",
              subtitle: "Your saved recipes will appear here once you log in.",
              primaryText: "Login",
              onPrimary: onGoProfile,

              secondaryText: "Explore recipes",
              onSecondary: onGoHome,
            ),
          );
        }

        final query = FirebaseFirestore.instance
            .collection('recipes')
            .where('authorId', isEqualTo: user.uid)
            .orderBy('createdAt', descending: true);

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: query.snapshots(),
          builder: (context, snap) {
            final docs = snap.data?.docs ?? [];

            final appBarTitle = docs.isNotEmpty
                ? "My Recipes (${docs.length})"
                : "My Recipes";

            Widget body;

            if (snap.connectionState == ConnectionState.waiting) {
              body = const Center(child: CircularProgressIndicator());
            } else if (snap.hasError) {
              body = Center(
                child: Text(
                  "Something went wrong.\n${snap.error}",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: scheme.error),
                ),
              );
            } else if (docs.isEmpty) {
              body = _EmptyCard(
                icon: Icons.bookmark_border,
                title: "No recipes yet",
                subtitle:
                    "Start by adding your first recipe, or explore dishes from others.",
                primaryText: "Add recipe",
                onPrimary: onGoAdd,
                secondaryText: "Explore recipes",
                onSecondary: onGoHome,
              );
            } else {
              body = SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          itemCount: docs.length,
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.80,
                              ),
                          itemBuilder: (context, i) {
                            final doc = docs[i];
                            final data = doc.data();

                            final title = (data['title'] ?? '').toString();
                            final category = (data['category'] ?? 'Breakfast')
                                .toString();
                            final imageUrl = (data['imageUrl'] ?? '')
                                .toString();

                            final prepTimeRaw = data['prepTime'];
                            final prepTimeInt = prepTimeRaw is int
                                ? prepTimeRaw
                                : int.tryParse(
                                        prepTimeRaw?.toString() ?? '0',
                                      ) ??
                                      0;

                            final servingsRaw = data['servings'];
                            final servingsInt = servingsRaw is int
                                ? servingsRaw
                                : int.tryParse(servingsRaw?.toString() ?? '') ??
                                      1;

                            final difficulty = (data['difficulty'] ?? 'Easy')
                                .toString();

                            final tags =
                                (data['tags'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];

                            final ingredients =
                                (data['ingredients'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];

                            final steps =
                                (data['steps'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];

                            final recipe = Recipe(
                              id: doc.id,
                              title: title.isEmpty ? "Untitled" : title,
                              description: (data['description'] ?? '')
                                  .toString(),
                              category: category,
                              prepTime: prepTimeInt,
                              authorId: (data['authorId'] ?? '').toString(),
                              imageUrl: imageUrl,
                              servings: servingsInt,
                              difficulty: difficulty,
                              tags: tags,
                              ingredients: ingredients,
                              steps: steps,
                            );

                            return _RecipeGridCard(
                              title: recipe.title,
                              category: recipe.category,
                              imageUrl: recipe.imageUrl,

                              prepTime: prepTimeRaw == null
                                  ? null
                                  : prepTimeRaw.toString(),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailsScreen(recipe: recipe),
                                  ),
                                );
                              },

                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AddRecipeScreen(
                                      onGoProfile: onGoProfile,
                                      recipe: recipe,
                                      recipeId: doc.id,
                                    ),
                                  ),
                                );
                              },

                              onDelete: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text("Delete recipe"),
                                    content: const Text(
                                      "Are you sure you want to delete this recipe? This action cannot be undone.",
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, false),
                                        child: const Text("Cancel"),
                                      ),
                                      FilledButton(
                                        onPressed: () =>
                                            Navigator.pop(context, true),
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirm == true) {
                                  await FirebaseFirestore.instance
                                      .collection('recipes')
                                      .doc(doc.id)
                                      .delete();
                                }
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

            return Scaffold(
              appBar: CustomAppBar(
                title: appBarTitle,
                onLoginTap: onGoProfile,
                onProfileTap: onGoProfile,
              ),
              endDrawer: const CustomEndDrawer(),
              body: body,
            );
          },
        );
      },
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String primaryText;
  final VoidCallback onPrimary;
  final String secondaryText;
  final VoidCallback onSecondary;

  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.primaryText,
    required this.onPrimary,
    required this.secondaryText,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            color: scheme.surface,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: scheme.primary),
                  const SizedBox(height: 12),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: FilledButton(
                      onPressed: onPrimary,
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(primaryText),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: OutlinedButton(
                      onPressed: onSecondary,
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(secondaryText),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecipeGridCard extends StatelessWidget {
  final String title;
  final String category;
  final String imageUrl;
  final String? prepTime;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _RecipeGridCard({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.prepTime,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceVariant,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
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
              AspectRatio(
                aspectRatio: 1,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imageUrl.isEmpty
                        ? Container(
                            color: scheme.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.image_outlined,
                              size: 34,
                              color: scheme.onSurfaceVariant,
                            ),
                          )
                        : Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: scheme.surfaceContainerHighest,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.image_outlined,
                                size: 34,
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),

                    Positioned(
                      top: 8,
                      right: 8,
                      child: Row(
                        children: [
                          Material(
                            color: scheme.surface.withOpacity(0.85),
                            shape: const CircleBorder(),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.edit, size: 18),
                              onPressed: onEdit,
                              tooltip: "Edit",
                            ),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: scheme.surface.withOpacity(0.85),
                            shape: const CircleBorder(),
                            child: IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              onPressed: onDelete,
                              tooltip: "Delete",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                color: scheme.surfaceVariant,
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
