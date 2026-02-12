import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:food_notes/services/favorites_service.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../recipe/recipe_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onGoProfile;

  const HomeScreen({super.key, required this.onGoProfile});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final RecipeService _recipeService = RecipeService();
  final FavoriteService _favoriteService = FavoriteService();

  final _searchCtrl = TextEditingController();

  String _selectedCategory = "All";
  String _q = "";
  String _role = "user";
  bool _isBlocked = false;

  final _categories = const ["All", "Breakfast", "Lunch", "Dinner", "Dessert", "Snack"];

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _q = _searchCtrl.text.trim().toLowerCase();
      });
    });
    _loadUserRole();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .get();

    if (!doc.exists) return;

    final data = doc.data() ?? {};

    final role = (data["role"] ?? "user").toString();
    final blocked = (data["isBlocked"] ?? false) == true;

    if (!mounted) return;

    setState(() {
      _role = role;
      _isBlocked = blocked;
    });

    if (blocked) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your account has been blocked by admin."),
        ),
      );
    }
  }

  bool _matches(Recipe r) {
    final categoryOk =
        _selectedCategory == "All" ||
        r.category.trim().toLowerCase() == _selectedCategory.toLowerCase();

    if (_q.isEmpty) return categoryOk;

    final inTitle = r.title.toLowerCase().contains(_q);
    final inDesc = r.description.toLowerCase().contains(_q);
    final inTags = r.tags.any((t) => t.trim().toLowerCase().contains(_q));

    return categoryOk && (inTitle || inDesc || inTags);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Food Notes",
        onLoginTap: widget.onGoProfile,
        onProfileTap: widget.onGoProfile,
        isAdmin: _role == "admin",
      ),
      endDrawer: _isBlocked ? null : CustomEndDrawer(isAdmin: _role == "admin"),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: "Search recipes...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _q.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                _searchCtrl.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
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
                      children: _categories.map((c) {
                        return _chip(
                          c,
                          c == _selectedCategory,
                          scheme,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            setState(() => _selectedCategory = c);
                          },
                        );
                      }).toList(),
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
                  final filtered = recipes.where(_matches).toList();

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
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        "No recipes found.",
                        style: TextStyle(
                          color: scheme.onSurface.withOpacity(0.7),
                        ),
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
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final r = filtered[index];

                      return InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RecipeDetailsScreen(
                                recipe: r,
                                isAdmin: _role == "admin",
                              ),
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
                                      if (_role == "admin")
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Material(
                                            color: Colors.transparent,
                                            child: InkWell(
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                              onTap: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        "Delete recipe",
                                                      ),
                                                      content: const Text(
                                                        "Are you sure you want to permanently delete this recipe?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            "Cancel",
                                                          ),
                                                        ),
                                                        ElevatedButton(
                                                          style:
                                                              ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                              ),
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            "Delete",
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                                if (confirm == true) {
                                                  await _recipeService
                                                      .deleteRecipe(r.id);

                                                  if (!context.mounted) return;

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Recipe deleted successfully",
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
                                                    color: scheme.outlineVariant
                                                        .withOpacity(0.6),
                                                  ),
                                                ),
                                                child: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                  size: 20,
                                                ),
                                              ),
                                            ),
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

Widget _chip(
  String text,
  bool selected,
  ColorScheme scheme, {
  required VoidCallback onTap,
}) {
  return Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
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
    ),
  );
}
