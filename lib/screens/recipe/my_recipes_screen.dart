import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';

class MyRecipesScreen extends StatelessWidget {
  final VoidCallback onGoHome;
  final VoidCallback onGoAdd;

  const MyRecipesScreen({
    super.key,
    required this.onGoHome,
    required this.onGoAdd,
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
            appBar: const CustomAppBar(title: "My Recipes"),
            endDrawer: const CustomEndDrawer(),
            body: _EmptyCard(
              icon: Icons.lock_outline,
              title: "Log in to see your recipes",
              subtitle: "Your saved recipes will appear here once you log in.",
              primaryText: "Login",
              onPrimary: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Use the Login button in the top bar."),
                  ),
                );
              },
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
                            final data = docs[i].data();
                            final title = (data['title'] ?? '').toString();
                            final category = (data['category'] ?? '')
                                .toString();
                            final imageUrl = (data['imageUrl'] ?? '')
                                .toString();
                            final prepTime = data['prepTime'];

                            return _RecipeGridCard(
                              title: title.isEmpty ? "Untitled" : title,
                              category: category,
                              imageUrl: imageUrl,
                              prepTime: prepTime == null
                                  ? null
                                  : prepTime.toString(),
                              onTap: () {},
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
              appBar: CustomAppBar(title: appBarTitle),
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

  const _RecipeGridCard({
    required this.title,
    required this.category,
    required this.imageUrl,
    required this.prepTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: imageUrl.isEmpty
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        child: const Icon(Icons.image_outlined, size: 34),
                      )
                    : Image.network(imageUrl, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (category.isNotEmpty)
                        Flexible(
                          child: Text(
                            category,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      if (prepTime != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          "• ${prepTime}m",
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
