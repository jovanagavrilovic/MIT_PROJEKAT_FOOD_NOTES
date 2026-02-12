import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:food_notes/widgets/custom_app_bar.dart';
import 'package:food_notes/widgets/custom_end_drawer.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/recipe.dart';
import '../../services/recipe_service.dart';
import '../auth/login_screen.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

class AddRecipeScreen extends StatefulWidget {
  final VoidCallback onGoProfile;
  final Recipe? recipe;
  final String? recipeId;

  const AddRecipeScreen({
    super.key,
    required this.onGoProfile,
    this.recipe,
    this.recipeId,
  });

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _IngredientRow {
  final TextEditingController nameCtrl;
  final TextEditingController amountCtrl;
  String unit;

  _IngredientRow({String name = "", String amount = "", this.unit = "g"})
    : nameCtrl = TextEditingController(text: name),
      amountCtrl = TextEditingController(text: amount);

  void dispose() {
    nameCtrl.dispose();
    amountCtrl.dispose();
  }
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  final _servingsCtrl = TextEditingController();

  final List<_IngredientRow> _ingredients = [];
  final List<String> _units = const ["g", "ml", "pcs"];
  final List<TextEditingController> _stepCtrls = [];

  String _difficulty = "Easy";

  final List<String> _difficulties = ["Easy", "Medium", "Hard"];

  final List<String> _allTags = [
    "Quick",
    "Vegan",
    "Vegetarian",
    "Gluten-free",
    "Healthy",
    "Spicy",
    "Kids",
    "Lenten",
  ];
  final Set<String> _selectedTags = {};

  _IngredientRow _parseIngredient(String raw) {
    final parts = raw.split("|");
    if (parts.length < 2) {
      return _IngredientRow(name: raw.trim(), amount: "", unit: "g");
    }

    final name = parts[0].trim();
    final right = parts[1].trim();
    final tokens = right.split(RegExp(r"\s+"));
    String amount = "";
    String unit = "g";

    if (tokens.isNotEmpty) amount = tokens[0].trim();
    if (tokens.length >= 2) {
      final u = tokens[1].trim();
      if (_units.contains(u)) unit = u;
    }

    return _IngredientRow(name: name, amount: amount, unit: unit);
  }

  String _formatIngredient(_IngredientRow r) {
    final name = r.nameCtrl.text.trim();
    final amount = r.amountCtrl.text.trim();
    return "$name | $amount ${r.unit}";
  }

  bool get _isEdit => widget.recipe != null && widget.recipeId != null;

  Widget _imagePlaceholder() {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_a_photo_outlined, color: scheme.primary, size: 30),
          const SizedBox(height: 8),
          Text(
            _isEdit ? "Tap to change image" : "Tap to select image (required)",
            style: TextStyle(
              color: scheme.onSurface.withOpacity(0.75),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reorderableTextList({
    required String title,
    required List<TextEditingController> ctrls,
    required VoidCallback onAdd,
    required void Function(int oldIndex, int newIndex) onReorder,
    required String hint,
  }) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saving ? null : onAdd,
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ctrls.length,
              onReorder: (oldIndex, newIndex) {
                if (_saving) return;
                if (newIndex > oldIndex) newIndex -= 1;
                onReorder(oldIndex, newIndex);
              },
              itemBuilder: (context, i) {
                return Container(
                  key: ValueKey(ctrls[i]),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      ReorderableDragStartListener(
                        index: i,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Icon(Icons.drag_handle),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          controller: ctrls[i],
                          decoration: InputDecoration(
                            hintText: hint,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 12,
                            ),
                          ),
                          validator: (v) {
                            if (ctrls.length == 1 &&
                                (v == null || v.trim().isEmpty)) {
                              return "Required";
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: (_saving || ctrls.length == 1)
                            ? null
                            : () {
                                setState(() {
                                  ctrls[i].dispose();
                                  ctrls.removeAt(i);
                                });
                              },
                        icon: const Icon(Icons.close),
                        tooltip: "Remove",
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _reorderableIngredientList() {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    "Ingredients",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                  ),
                ),
                FilledButton.tonalIcon(
                  onPressed: _saving
                      ? null
                      : () =>
                            setState(() => _ingredients.add(_IngredientRow())),
                  icon: const Icon(Icons.add),
                  label: const Text("Add"),
                ),
              ],
            ),
            const SizedBox(height: 10),

            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredients.length,
              onReorder: (oldIndex, newIndex) {
                if (_saving) return;
                if (newIndex > oldIndex) newIndex -= 1;
                setState(() {
                  final item = _ingredients.removeAt(oldIndex);
                  _ingredients.insert(newIndex, item);
                });
              },
              itemBuilder: (context, i) {
                final row = _ingredients[i];

                return Container(
                  key: ValueKey(row),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: scheme.surfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: scheme.outlineVariant.withOpacity(0.7),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        ReorderableDragStartListener(
                          index: i,
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(Icons.drag_handle),
                          ),
                        ),

                        Expanded(
                          flex: 5,
                          child: TextFormField(
                            controller: row.nameCtrl,
                            decoration: const InputDecoration(
                              hintText: "Ingredient",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Required"
                                : null,
                          ),
                        ),

                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: row.amountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: "Qty",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty)
                                return "Required";
                              final n = double.tryParse(
                                v.trim().replaceAll(",", "."),
                              );
                              if (n == null || n <= 0) return "Invalid";
                              return null;
                            },
                          ),
                        ),

                        DropdownButton<String>(
                          value: row.unit,
                          underline: const SizedBox.shrink(),
                          items: _units
                              .map(
                                (u) =>
                                    DropdownMenuItem(value: u, child: Text(u)),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (v) => setState(() => row.unit = v!),
                        ),

                        IconButton(
                          onPressed: (_saving || _ingredients.length == 1)
                              ? null
                              : () {
                                  setState(() {
                                    _ingredients[i].dispose();
                                    _ingredients.removeAt(i);
                                  });
                                },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    final r = widget.recipe;
    if (r != null) {
      _titleCtrl.text = r.title;
      _descCtrl.text = r.description;
      _timeCtrl.text = r.prepTime.toString();
      _category = r.category;

      _difficulty = r.difficulty ?? "Easy";
      _servingsCtrl.text = (r.servings ?? 1).toString();
      _selectedTags.addAll(r.tags ?? []);

      for (final ing in (r.ingredients ?? [])) {
        _ingredients.add(_parseIngredient(ing));
      }

      for (final st in (r.steps ?? [])) {
        _stepCtrls.add(TextEditingController(text: st));
      }
    }

    if (_ingredients.isEmpty) _ingredients.add(_IngredientRow());
    if (_stepCtrls.isEmpty) _stepCtrls.add(TextEditingController());
  }

  String _category = "Breakfast";
  final _service = RecipeService();

  XFile? _pickedImage;
  Uint8List? _webImageBytes;
  bool _saving = false;

  final List<String> _categories = [
    "Breakfast",
    "Lunch",
    "Dinner",
    "Snack",
    "Dessert",
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (xfile == null) return;

    if (kIsWeb) {
      final bytes = await xfile.readAsBytes();
      setState(() {
        _pickedImage = xfile;
        _webImageBytes = bytes;
      });
    } else {
      setState(() {
        _pickedImage = xfile;
        _webImageBytes = null;
      });
    }
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login required"),
        content: Text(
          _isEdit
              ? "You need to log in to edit a recipe."
              : "You need to log in to add a recipe.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Log in"),
          ),
        ],
      ),
    );
  }

  Future<void> _saveRecipe() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showLoginRequiredDialog();
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    if (!_isEdit && _pickedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image (required).")),
      );
      return;
    }

    if (_saving) return;
    setState(() => _saving = true);

    try {
      final prepTime = int.tryParse(_timeCtrl.text.trim());
      final servings = int.tryParse(_servingsCtrl.text.trim());

      if (prepTime == null || servings == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Prep time and servings must be numbers."),
          ),
        );
        return;
      }

      String imageUrl;
      if (_pickedImage != null) {
        imageUrl = await _service.uploadRecipeImage(
          file: _pickedImage!,
          webBytes: _webImageBytes,
        );
      } else {
        imageUrl = widget.recipe!.imageUrl;
      }

      final ingredients = _ingredients
          .map(_formatIngredient)
          .where((s) => !s.startsWith("|"))
          .toList();

      final steps = _stepCtrls
          .map((c) => c.text.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      if (ingredients.isEmpty || steps.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please add at least 1 ingredient and 1 step."),
          ),
        );
        return;
      }

      final recipesRef = FirebaseFirestore.instance.collection('recipes');

      final docRef = _isEdit
          ? recipesRef.doc(widget.recipeId!)
          : recipesRef.doc();

      final recipeMap = Recipe(
        id: docRef.id,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        prepTime: prepTime,
        authorId: user.uid,
        imageUrl: imageUrl,
        servings: servings,
        difficulty: _difficulty,
        tags: _selectedTags.toList(),
        ingredients: ingredients,
        steps: steps,
      ).toMap();

      if (_isEdit) {
        await docRef.update({...recipeMap, 'updatedAt': Timestamp.now()});
      } else {
        await docRef.set({...recipeMap, 'createdAt': Timestamp.now()});
      }

      if (!mounted) return;

      setState(() => _saving = false);
      Navigator.pop(context, true);
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving recipe: $e")));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _timeCtrl.dispose();
    _servingsCtrl.dispose();

    for (final r in _ingredients) {
      r.dispose();
    }

    for (final c in _stepCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEdit ? "Edit Recipe" : "Add Recipe",
        onLoginTap: widget.onGoProfile,
        onProfileTap: widget.onGoProfile,
      ),
      endDrawer: const CustomEndDrawer(),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Recipe details",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 12),

                        InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: _saving ? null : _pickImage,
                          child: Ink(
                            height: 170,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surfaceVariant.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant.withOpacity(0.7),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(18),
                              child: _pickedImage != null
                                  ? (kIsWeb
                                        ? (_webImageBytes != null
                                              ? Image.memory(
                                                  _webImageBytes!,
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                )
                                              : _imagePlaceholder())
                                        : Image.file(
                                            File(_pickedImage!.path),
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ))
                                  : (_isEdit &&
                                        (widget.recipe?.imageUrl.isNotEmpty ??
                                            false))
                                  ? Image.network(
                                      widget.recipe!.imageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      errorBuilder: (_, __, ___) =>
                                          _imagePlaceholder(),
                                    )
                                  : _imagePlaceholder(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _titleCtrl,
                          decoration: _formDeco(context, "Title", Icons.title),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Enter title"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 4,
                          decoration: _formDeco(
                            context,
                            "Description",
                            Icons.notes_outlined,
                          ),
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Enter description"
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _timeCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _formDeco(
                            context,
                            "Prep time (min)",
                            Icons.schedule,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return "Enter time";
                            if (int.tryParse(v) == null) return "Numbers only";
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _servingsCtrl,
                          keyboardType: TextInputType.number,
                          decoration: _formDeco(
                            context,
                            "Servings",
                            Icons.groups_2_outlined,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty)
                              return "Enter servings";
                            final n = int.tryParse(v.trim());
                            if (n == null || n <= 0)
                              return "Must be a positive number";
                            return null;
                          },
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _category,
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (v) => setState(() => _category = v!),
                          decoration: _formDeco(
                            context,
                            "Category",
                            Icons.restaurant_menu,
                          ),
                        ),
                        const SizedBox(height: 12),

                        DropdownButtonFormField<String>(
                          value: _difficulty,
                          items: _difficulties
                              .map(
                                (d) =>
                                    DropdownMenuItem(value: d, child: Text(d)),
                              )
                              .toList(),
                          onChanged: _saving
                              ? null
                              : (v) => setState(() => _difficulty = v!),
                          decoration: _formDeco(
                            context,
                            "Difficulty",
                            Icons.speed,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Text(
                          "Tags",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _allTags.map((t) {
                            final selected = _selectedTags.contains(t);
                            return FilterChip(
                              label: Text(t),
                              selected: selected,
                              onSelected: _saving
                                  ? null
                                  : (v) => setState(() {
                                      v
                                          ? _selectedTags.add(t)
                                          : _selectedTags.remove(t);
                                    }),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        _reorderableIngredientList(),

                        const SizedBox(height: 12),

                        _reorderableTextList(
                          title: "Steps",
                          ctrls: _stepCtrls,
                          hint: "e.g. Mix everything well",
                          onAdd: () => setState(
                            () => _stepCtrls.add(TextEditingController()),
                          ),
                          onReorder: (a, b) => setState(() {
                            final item = _stepCtrls.removeAt(a);
                            _stepCtrls.insert(b, item);
                          }),
                        ),

                        const SizedBox(height: 16),

                        SizedBox(
                          height: 48,
                          child: FilledButton(
                            onPressed: _saving ? null : _saveRecipe,
                            style: FilledButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _saving
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isEdit ? "Save changes" : "Save Recipe",
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration _formDeco(BuildContext context, String label, IconData icon) {
  final scheme = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon),
    filled: true,
    fillColor: scheme.surfaceVariant.withOpacity(0.75),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.7)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.outlineVariant.withOpacity(0.7)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: scheme.primary, width: 1.4),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
