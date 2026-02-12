import 'package:flutter/material.dart';
import 'package:food_notes/services/nutrition_service.dart'; // prilagodi putanju gde si stavila servis

class NutritionSearchScreen extends StatefulWidget {
  const NutritionSearchScreen({super.key});

  @override
  State<NutritionSearchScreen> createState() => _NutritionSearchScreenState();
}

class _NutritionSearchScreenState extends State<NutritionSearchScreen> {
  final _ctrl = TextEditingController();
  final _service = NutritionService();

  bool _loading = false;
  String? _error;
  List<NutritionItem> _items = [];

  Future<void> _search() async {
    final q = _ctrl.text.trim();
    if (q.isEmpty) return;

    setState(() {
      _loading = true;
      _error = null;
      _items = [];
    });

    try {
      final res = await _service.search(q);
      setState(() => _items = res);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nutrition search")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _search(),
                    decoration: const InputDecoration(
                      labelText: "Search food (e.g. milk, banana)",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _search,
                  child: const Text("Search"),
                )
              ],
            ),
            const SizedBox(height: 12),

            if (_loading) const LinearProgressIndicator(),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],

            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty && !_loading
                  ? const Center(child: Text("No results yet"))
                  : ListView.separated(
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final x = _items[i];
                        return ListTile(
                          title: Text(x.name),
                          subtitle: Text([
                            if (x.brand != null) x.brand!,
                            if (x.kcal100g != null) "kcal/100g: ${x.kcal100g!.toStringAsFixed(0)}",
                            if (x.protein100g != null) "P: ${x.protein100g!.toStringAsFixed(1)}g",
                            if (x.carbs100g != null) "C: ${x.carbs100g!.toStringAsFixed(1)}g",
                            if (x.fat100g != null) "F: ${x.fat100g!.toStringAsFixed(1)}g",
                          ].join(" • ")),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
