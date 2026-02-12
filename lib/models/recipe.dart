import 'package:cloud_firestore/cloud_firestore.dart';

class Recipe {
  final String id;
  final String title;
  final String description;
  final String category;
  final int prepTime;

  final int servings;
  final String difficulty;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> steps;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final String authorId;
  final String imageUrl;

  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.prepTime,
    required this.authorId,
    required this.imageUrl,

    this.servings = 1,
    this.difficulty = "Easy",
    this.tags = const [],
    this.ingredients = const [],
    this.steps = const [],

    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    int? prepTime,
    int? servings,
    String? difficulty,
    List<String>? tags,
    List<String>? ingredients,
    List<String>? steps,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorId,
    String? imageUrl,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      prepTime: prepTime ?? this.prepTime,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      tags: tags ?? this.tags,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorId: authorId ?? this.authorId,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  factory Recipe.fromMap(String id, Map<String, dynamic> data) {
    final rawCreatedAt = data['createdAt'];
    DateTime createdAt;
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is DateTime) {
      createdAt = rawCreatedAt;
    } else {
      createdAt = DateTime.now();
    }

    final rawUpdatedAt = data['updatedAt'];
    DateTime? updatedAt;
    if (rawUpdatedAt is Timestamp) {
      updatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is DateTime) {
      updatedAt = rawUpdatedAt;
    }

    final rawPrep = data['prepTime'];
    final prepTime = (rawPrep is int)
        ? rawPrep
        : (rawPrep is num
              ? rawPrep.toInt()
              : int.tryParse('${rawPrep ?? ''}') ?? 0);

    final rawServ = data['servings'];
    final servings = (rawServ is int)
        ? rawServ
        : (rawServ is num
              ? rawServ.toInt()
              : int.tryParse('${rawServ ?? ''}') ?? 1);

    final difficulty = (data['difficulty'] ?? 'Easy').toString();

    List<String> _asStringList(dynamic v) {
      if (v is List) {
        return v
            .map((e) => e.toString())
            .where((s) => s.trim().isNotEmpty)
            .toList();
      }
      return [];
    }

    return Recipe(
      id: id,
      title: (data['title'] ?? '').toString(),
      description: (data['description'] ?? '').toString(),
      category: (data['category'] ?? '').toString(),
      prepTime: prepTime,
      servings: servings <= 0 ? 1 : servings,
      difficulty: difficulty.isEmpty ? "Easy" : difficulty,
      tags: _asStringList(data['tags']),
      ingredients: _asStringList(data['ingredients']),
      steps: _asStringList(data['steps']),
      createdAt: createdAt,
      updatedAt: updatedAt,
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

      'servings': servings,
      'difficulty': difficulty,
      'tags': tags,
      'ingredients': ingredients,
      'steps': steps,

      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null) 'updatedAt': Timestamp.fromDate(updatedAt!),
    };
  }
}
