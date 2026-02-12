import 'dart:convert';
import 'package:http/http.dart' as http;

class NutritionItem {
  final String name;
  final String? brand;
  final double? kcal100g;
  final double? protein100g;
  final double? fat100g;
  final double? carbs100g;

  NutritionItem({
    required this.name,
    this.brand,
    this.kcal100g,
    this.protein100g,
    this.fat100g,
    this.carbs100g,
  });

  factory NutritionItem.fromJson(Map<String, dynamic> j) {
    double? _d(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    final name = (j['product_name'] ?? j['generic_name'] ?? 'Unnamed').toString();
    final brand = (j['brands'] ?? '').toString().trim();
    final nutr = (j['nutriments'] is Map) ? (j['nutriments'] as Map) : const {};

    return NutritionItem(
      name: name,
      brand: brand.isEmpty ? null : brand,
      kcal100g: _d(nutr['energy-kcal_100g']),
      protein100g: _d(nutr['proteins_100g']),
      fat100g: _d(nutr['fat_100g']),
      carbs100g: _d(nutr['carbohydrates_100g']),
    );
  }
}

class NutritionService {
  Future<List<NutritionItem>> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.parse(
      'https://world.openfoodfacts.org/cgi/search.pl'
      '?search_terms=${Uri.encodeQueryComponent(q)}'
      '&search_simple=1&action=process&json=1&page_size=20',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Nutrition API error: ${res.statusCode}');
    }

    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final products = (body['products'] as List?) ?? [];

    final items = products
        .whereType<Map<String, dynamic>>()
        .map(NutritionItem.fromJson)
        .where((x) =>
            x.kcal100g != null ||
            x.protein100g != null ||
            x.fat100g != null ||
            x.carbs100g != null)
        .toList();

    return items;
  }
}
