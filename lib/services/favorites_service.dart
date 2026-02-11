import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoriteService {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<bool> isFavoriteStream(String recipeId) {
    final user = currentUser;
    if (user == null) return Stream.value(false);

    final ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeId);

    return ref.snapshots().map((doc) => doc.exists);
  }

  Future<void> toggleFavorite(String recipeId) async {
    final user = currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'not-authenticated',
        message: 'You must be logged in to favorite recipes.',
      );
    }

    final ref = _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(recipeId);

    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({'createdAt': FieldValue.serverTimestamp()});
    }
  }

  Stream<List<String>> favoriteIdsStream() {
    final user = currentUser;
    if (user == null) return Stream.value(const []);

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((qs) => qs.docs.map((d) => d.id).toList());
  }
}
