import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/recipe.dart';


class RecipeService {
  final _recipesRef =
      FirebaseFirestore.instance.collection('recipes');
      final _storage = FirebaseStorage.instance;

  Stream<List<Recipe>> getRecipes() {
  return _recipesRef
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        final list = <Recipe>[];
        for (final doc in snapshot.docs) {
          list.add(Recipe.fromMap(doc.id, doc.data()));
        }
        return list;
      });
}

Future<String> uploadRecipeImage(File file) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = _storage.ref().child('recipes/$fileName.jpg');

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }




  Future<void> addRecipe(Recipe recipe) async {
  await _recipesRef.add({
    ...recipe.toMap(),
    'createdAt': FieldValue.serverTimestamp(),
  });
}

}
