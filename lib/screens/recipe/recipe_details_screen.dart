import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/recipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:food_notes/services/nutrition_service.dart';

class RecipeDetailsScreen extends StatelessWidget {
  final Recipe recipe;
  final bool isAdmin;

  const RecipeDetailsScreen({
    super.key,
    required this.recipe,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(recipe.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: recipe.imageUrl.isEmpty
                    ? Container(
                        color: scheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 44),
                      )
                    : Image.network(
                        recipe.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.image_outlined, size: 44),
                        ),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 0,
              surfaceTintColor: Colors.transparent,
              color: scheme.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
                side: BorderSide(color: scheme.outlineVariant.withOpacity(0.6)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (isAdmin) ...[
                      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(recipe.authorId)
                            .snapshots(),
                        builder: (context, snap) {
                          final data = snap.data?.data();
                          final author =
                              (data?['email'] ??
                                      data?['name'] ??
                                      'Unknown user')
                                  .toString();

                          return Text(
                            "Posted by: $author",
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.65),
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                    ],

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _InfoChip(
                          icon: Icons.schedule,
                          text: "${recipe.prepTime} min",
                        ),
                        _InfoChip(
                          icon: Icons.restaurant_menu,
                          text: recipe.category,
                        ),

                        if (recipe.servings != null)
                          _InfoChip(
                            icon: Icons.groups_2_outlined,
                            text: "${recipe.servings} servings",
                          ),

                        if ((recipe.difficulty ?? "").isNotEmpty)
                          _InfoChip(
                            icon: Icons.speed,
                            text: recipe.difficulty!,
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),

                    Text(
                      recipe.description.isEmpty
                          ? "No description yet."
                          : recipe.description,
                      style: TextStyle(
                        height: 1.4,
                        color: scheme.onSurface.withOpacity(0.85),
                      ),
                    ),
                    if ((recipe.tags ?? []).isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        "Tags",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: (recipe.tags ?? [])
                            .map(
                              (t) =>
                                  _InfoChip(icon: Icons.sell_outlined, text: t),
                            )
                            .toList(),
                      ),
                    ],

                    if ((recipe.ingredients ?? []).isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        "Ingredients",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...((recipe.ingredients ?? []).map(
                        (ing) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _openNutritionSheet(context, ing),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                "• $ing",
                                style: TextStyle(
                                  color: scheme.onSurface.withOpacity(0.85),
                                  height: 1.4,
                                  decoration: TextDecoration
                                      .underline, // da se vidi da je klik
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                    ],

                    if ((recipe.steps ?? []).isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Text(
                        "Steps",
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      for (int i = 0; i < (recipe.steps ?? []).length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            "${i + 1}. ${(recipe.steps ?? [])[i]}",
                            style: TextStyle(
                              color: scheme.onSurface.withOpacity(0.85),
                              height: 1.4,
                            ),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openNutritionSheet(BuildContext context, String ingredient) {
    final service = NutritionService();
    final queryCtrl = TextEditingController(text: ingredient);
    final gramsCtrl = TextEditingController(text: "100");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            bool loading = false;
            String? error;
            List<NutritionItem> results = [];
            NutritionItem? selected;

            Future<void> doSearch() async {
              final q = queryCtrl.text.trim();
              if (q.isEmpty) return;

              setModalState(() {
                loading = true;
                error = null;
                selected = null;
              });

              try {
                final items = await service.search(q);
                setModalState(() {
                  results = items;
                });
              } catch (e) {
                setModalState(() {
                  error = e.toString();
                });
              } finally {
                setModalState(() {
                  loading = false;
                });
              }
            }

            double grams() {
              final v = double.tryParse(gramsCtrl.text.trim());
              if (v == null || v <= 0) return 100;
              return v;
            }

            double? scale(double? per100g) {
              if (per100g == null) return null;
              return per100g * grams() / 100.0;
            }

            Widget metricRow(String label, double? per100, double? scaledVal) {
              String fmt(double? x) => x == null ? "-" : x.toStringAsFixed(1);
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      "${fmt(per100)} /100g   |   ${fmt(scaledVal)} /${grams().toStringAsFixed(0)}g",
                    ),
                  ],
                ),
              );
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: queryCtrl,
                          decoration: const InputDecoration(
                            labelText: "Search ingredient",
                            prefixIcon: Icon(Icons.search),
                          ),
                          onSubmitted: (_) => doSearch(),
                        ),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 90,
                        child: TextField(
                          controller: gramsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: "grams"),
                          onChanged: (_) {
                            if (selected != null) setModalState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : doSearch,
                      icon: const Icon(Icons.search),
                      label: const Text("Search"),
                    ),
                  ),

                  if (loading) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(),
                  ],
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(error!, style: const TextStyle(color: Colors.red)),
                  ],

                  const SizedBox(height: 12),

                  if (selected == null) ...[
                    SizedBox(
                      height: 260,
                      child: results.isEmpty
                          ? const Center(
                              child: Text("No results yet. Try search."),
                            )
                          : ListView.separated(
                              itemCount: results.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (ctx, i) {
                                final it = results[i];
                                final subtitle = it.brand == null
                                    ? ""
                                    : it.brand!;
                                return ListTile(
                                  title: Text(
                                    it.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: subtitle.isEmpty
                                      ? null
                                      : Text(
                                          subtitle,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    setModalState(() {
                                      selected = it;
                                    });
                                  },
                                );
                              },
                            ),
                    ),
                  ] else ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        selected!.brand == null
                            ? selected!.name
                            : "${selected!.name} • ${selected!.brand}",
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    metricRow(
                      "Calories (kcal)",
                      selected!.kcal100g,
                      scale(selected!.kcal100g),
                    ),
                    metricRow(
                      "Protein (g)",
                      selected!.protein100g,
                      scale(selected!.protein100g),
                    ),
                    metricRow(
                      "Fat (g)",
                      selected!.fat100g,
                      scale(selected!.fat100g),
                    ),
                    metricRow(
                      "Carbs (g)",
                      selected!.carbs100g,
                      scale(selected!.carbs100g),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            setModalState(() {
                              selected = null;
                            });
                          },
                          icon: const Icon(Icons.arrow_back),
                          label: const Text("Back"),
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Done"),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: scheme.surfaceVariant.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
