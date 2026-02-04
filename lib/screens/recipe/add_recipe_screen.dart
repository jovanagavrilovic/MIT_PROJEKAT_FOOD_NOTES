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

      final uid = user.uid;

      final recipe = Recipe(
        id: '',
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        category: _category,
        prepTime: int.parse(_timeCtrl.text),
        authorId: user.uid,
        imageUrl: imageUrl,
      );

      //await _service.addRecipe(recipe);
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _saving ? null : _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.black12),
                  ),
                  child: _imageFile == null
                      ? const Center(
                          child: Text("Tap to select image (required)"),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 10),

              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: "Title"),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter title" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: "Description"),
                maxLines: 3,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? "Enter description" : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _timeCtrl,
                decoration: const InputDecoration(labelText: "Prep time (min)"),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return "Enter time";
                  if (int.tryParse(v) == null) return "Numbers only";
                  return null;
                },
              ),

              const SizedBox(height: 12),

              DropdownButtonFormField(
                value: _category,
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
                decoration: const InputDecoration(labelText: "Category"),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saving ? null : _saveRecipe,
                child: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Save Recipe"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
