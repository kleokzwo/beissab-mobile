import 'package:flutter/material.dart';
import '../api/beissab_api.dart';
import '../widgets/common.dart';

class RecipeScreen extends StatefulWidget {
  final dynamic id, initial;
  const RecipeScreen({required this.id, this.initial, super.key});
  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  List<dynamic> ingredients = [], steps = [];
  bool loading = true;

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    try {
      final r = await Future.wait([mealApi.ingredients(widget.id), mealApi.steps(widget.id)]);
      ingredients = r[0]; steps = r[1];
    } catch (x) {
      if (mounted) snack(context, '$x');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.initial;
    return Scaffold(
      appBar: AppBar(title: Text(mealTitle(m))),
      body: loading ? const Center(child: CircularProgressIndicator()) : ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(mealTitle(m), style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
          if (m is Map) ...[
            const SizedBox(height: 8),
            Text([m['dietType'] ?? m['diet_type'], m['cookTime'] ?? m['cookingTime'], m['difficulty']].where((x) => x != null).join(' • ')),
          ],
          const SizedBox(height: 24),
          Text('Zutaten', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...ingredients.map((x) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.check_circle_outline),
            title: Text(x is Map ? (x['name'] ?? x['ingredientName'] ?? x['ingredient_name'] ?? '$x').toString() : '$x'),
            subtitle: x is Map ? Text([x['quantity'] ?? x['amount'], x['unit']].where((v) => v != null).join(' ')) : null,
          )),
          const SizedBox(height: 18),
          Text('Zubereitung', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(child: Text('${e.key + 1}')),
            title: Text(e.value is Map ? (e.value['description'] ?? e.value['text'] ?? e.value['instruction'] ?? '').toString() : '${e.value}'),
          )),
        ],
      ),
    );
  }
}
