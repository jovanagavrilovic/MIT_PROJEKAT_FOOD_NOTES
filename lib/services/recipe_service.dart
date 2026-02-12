import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';

class RecipeService {
  final _recipesRef = FirebaseFirestore.instance.collection('recipes');
  final _storage = FirebaseStorage.instance;

  Stream<List<Recipe>> getRecipes() {
    return _recipesRef.orderBy('createdAt', descending: true).snapshots().map((
      snapshot,
    ) {
      final list = <Recipe>[];

      for (final doc in snapshot.docs) {
        try {
          list.add(Recipe.fromMap(doc.id, doc.data()));
        } catch (e) {
          print("⚠️ Skipping broken recipe ${doc.id}: $e");
        }
      }

      return list;
    });
  }

  Stream<Recipe?> getRecipeById(String id) {
    return _recipesRef.doc(id).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data();
      if (data == null) return null;
      return Recipe.fromMap(doc.id, data);
    });
  }

  Future<String> uploadRecipeImage({
    required XFile file,
    Uint8List? webBytes,
  }) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('recipes/$fileName.jpg');

    if (kIsWeb) {
      final bytes = webBytes ?? await file.readAsBytes();
      await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    } else {
      await ref.putFile(File(file.path));
    }

    return await ref.getDownloadURL();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipesRef.add({
      ...recipe.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteRecipe(String id) async {
    await _recipesRef.doc(id).delete();
  }
}
