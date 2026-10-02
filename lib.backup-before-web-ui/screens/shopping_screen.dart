import 'package:flutter/material.dart';
import '../api/beissab_api.dart';
import '../widgets/common.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override
  State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<dynamic> items = [];
  bool loading = true;

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      final w = await weekApi.active();
      items = (w['shoppingItems'] as List?) ?? [];
    } catch (_) { items = []; }
    finally { if (mounted) setState(() => loading = false); }
  }

  bool checked(dynamic i) => i is Map && ((i['checked'] ?? i['isChecked']) == true || (i['checked'] ?? i['isChecked']) == 1);
  dynamic itemId(dynamic i) => i is Map ? (i['id'] ?? i['itemId']) : null;
  String name(dynamic i) => i is Map ? (i['name'] ?? i['title'] ?? i['ingredientName'] ?? 'Unbekannt').toString() : 'Unbekannt';

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: load,
    child: ListView(
      padding: const EdgeInsets.only(bottom: 110),
      children: [
        const PageTitle('Einkauf', subtitle: 'Automatisch aus deinem Wochenplan erstellt.'),
        if (loading)
          const Center(child: CircularProgressIndicator())
        else if (items.isEmpty)
          const Padding(padding: EdgeInsets.all(30), child: Center(child: Text('Deine Einkaufsliste ist leer.')))
        else
          ...items.map((i) => Dismissible(
            key: ValueKey('${itemId(i)}-${name(i)}'),
            background: Container(color: Colors.red.shade100, alignment: Alignment.centerRight, padding: const EdgeInsets.all(20), child: const Icon(Icons.delete)),
            direction: DismissDirection.endToStart,
            onDismissed: (_) async { await weekApi.deleteItem(itemId(i)); items.remove(i); setState(() {}); },
            child: CheckboxListTile(
              value: checked(i),
              onChanged: (v) async { await weekApi.check(itemId(i), v ?? false); if (i is Map) { i['checked'] = v; i['isChecked'] = v; } setState(() {}); },
              title: Text(name(i), style: TextStyle(fontWeight: FontWeight.w700, decoration: checked(i) ? TextDecoration.lineThrough : null)),
              subtitle: Text(i is Map ? [i['quantity'] ?? i['amount'], i['unit'], i['category']].where((x) => x != null && '$x'.isNotEmpty).join(' • ') : ''),
              secondary: IconButton(icon: const Icon(Icons.edit), onPressed: () => edit(i)),
            ),
          )),
      ],
    ),
  );

  Future<void> edit(dynamic i) async {
    final n = TextEditingController(text: name(i));
    final q = TextEditingController(text: '${i is Map ? (i['quantity'] ?? i['amount'] ?? '') : ''}');
    final cat = TextEditingController(text: '${i is Map ? (i['category'] ?? 'Sonstiges') : 'Sonstiges'}');
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Artikel bearbeiten'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: n, decoration: const InputDecoration(labelText: 'Name')),
          const SizedBox(height: 10),
          TextField(controller: q, decoration: const InputDecoration(labelText: 'Menge')),
          const SizedBox(height: 10),
          TextField(controller: cat, decoration: const InputDecoration(labelText: 'Kategorie')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Abbrechen')),
          FilledButton(onPressed: () async { await weekApi.edit(itemId(i), n.text, q.text, cat.text); if (dialogContext.mounted) Navigator.pop(dialogContext); await load(); }, child: const Text('Speichern')),
        ],
      ),
    );
    n.dispose(); q.dispose(); cat.dispose();
  }
}
