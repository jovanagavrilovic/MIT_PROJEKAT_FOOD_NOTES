import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int prepTime;
  final DateTime createdAt;
  final String authorId;
  final String imageUrl;

  Recipe({
  required this.id,
  required this.title,
  required this.description,
  required this.category,
  required this.prepTime,
  DateTime? createdAt,
  required this.authorId,
  required this.imageUrl,
}) : createdAt = createdAt ?? DateTime.now();

Recipe copyWith({
  String? id,
  String? title,
  String? description,
  String? category,
  int? prepTime,
  DateTime? createdAt,
  String? authorId,
  String? imageUrl,
}) {
  return Recipe(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    category: category ?? this.category,
    prepTime: prepTime ?? this.prepTime,
    createdAt: createdAt ?? this.createdAt,
    authorId: authorId ?? this.authorId,
    imageUrl: imageUrl ?? this.imageUrl,
  );
}

 
  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
  final rawCreatedAt = data['createdAt'];

  DateTime createdAt;
  if (rawCreatedAt is Timestamp) {
    createdAt = rawCreatedAt.toDate();
  } else {
    createdAt = DateTime.now();
  }

  final rawPrep = data['prepTime'];
  final prepTime = (rawPrep is int)
      ? rawPrep
      : (rawPrep is num ? rawPrep.toInt() : 0);

  return Recipe(
    id: id,
    title: (data['title'] ?? '').toString(),
    description: (data['description'] ?? '').toString(),
    category: (data['category'] ?? '').toString(),
    prepTime: prepTime,
    createdAt: createdAt,
    authorId: (data['authorId'] ?? '').toString(),
    imageUrl: (data['imageUrl'] ?? '').toString(),
  ); 
}



  Map<String, dynamic> toMap() {
  return {
    'title': title,
    'description': description,
    'category': category,
    'prepTime': prepTime,
    'authorId': authorId,
    'imageUrl': imageUrl,
  };
}

}
