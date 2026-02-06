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

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();

  String _category = "Breakfast";
  final _service = RecipeService();

  File? _imageFile;
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

    setState(() {
      _imageFile = File(xfile.path);
    });
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login required"),
        content: const Text("You need to log in to add a recipe."),
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

    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image (required).")),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final imageUrl = await _service.uploadRecipeImage(_imageFile!);


      final recipe = Recipe(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        prepTime: int.parse(_timeCtrl.text),
        authorId: user.uid,
        imageUrl: imageUrl,
      );

      await FirebaseFirestore.instance
          .collection('recipes')
          .add(recipe.toMap());

      if (!mounted) return;
      Navigator.pop(context);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Add Recipe"),
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
                            child: _imageFile == null
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.add_a_photo_outlined,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          size: 30,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Tap to select image (required)",
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withOpacity(0.75),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: Image.file(
                                      _imageFile!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                    ),
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

                        DropdownButtonFormField<String>(
                          value: _category,
                          items: _categories
                              .map(
                                (c) =>
                                    DropdownMenuItem(value: c, child: Text(c)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _category = v!),
                          decoration: _formDeco(
                            context,
                            "Category",
                            Icons.restaurant_menu,
                          ),
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
                                : const Text("Save Recipe"),
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
