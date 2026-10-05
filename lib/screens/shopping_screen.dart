import 'package:flutter/material.dart';
import '../api/beissab_api.dart';

class ShoppingScreen extends StatefulWidget {
  const ShoppingScreen({super.key});
  @override State<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends State<ShoppingScreen> {
  List<dynamic> items = [];
  bool loading = true;

  @override void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() => loading = true);
    try { final w = await weekApi.active(); items = List<dynamic>.from((w['shoppingItems'] as List?) ?? const []); }
    catch (_) { items = []; }
    finally { if (mounted) setState(() => loading = false); }
  }

  bool checked(dynamic i) => i is Map && ((i['checked'] ?? i['isChecked']) == true || (i['checked'] ?? i['isChecked']) == 1);
  dynamic itemId(dynamic i) => i is Map ? (i['id'] ?? i['itemId']) : null;
  String name(dynamic i) => i is Map ? (i['name'] ?? i['title'] ?? i['ingredientName'] ?? 'Unbekannt').toString() : 'Unbekannt';
  String category(dynamic i) => i is Map ? (i['category'] ?? 'Sonstiges').toString() : 'Sonstiges';
  String amount(dynamic i) {
    if (i is! Map) return '';
    return [i['quantity'] ?? i['amount'], i['unit']].where((x) => x != null && '$x'.trim().isNotEmpty).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final done = items.where(checked).length;
    final grouped = <String, List<dynamic>>{};
    for (final item in items) { grouped.putIfAbsent(category(item), () => []).add(item); }

    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 116),
        children: [
          _header(done),
          const SizedBox(height: 13),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: load,
            child: Container(padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Row(children: [Icon(Icons.refresh_rounded, size: 21), SizedBox(width: 11), Text('Einkaufsliste aktualisieren', style: TextStyle(fontWeight: FontWeight.w800)), Spacer(), Icon(Icons.chevron_right_rounded, color: Colors.black38)])),
          ),
          const SizedBox(height: 22),
          if (loading)
            const SizedBox(height: 360, child: Center(child: CircularProgressIndicator()))
          else if (items.isEmpty)
            const Padding(padding: EdgeInsets.all(36), child: Center(child: Text('Deine Einkaufsliste ist leer.', style: TextStyle(fontWeight: FontWeight.w700))) )
          else
            ...grouped.entries.expand((entry) => [
              Padding(padding: const EdgeInsets.fromLTRB(3, 8, 3, 10), child: Row(children: [Text(entry.key, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900)), const Spacer(), Text('${entry.value.length} Artikel', style: const TextStyle(color: Color(0xFF9AA0AA), fontSize: 12, fontWeight: FontWeight.w700))])),
              ...entry.value.map(_item),
              const SizedBox(height: 10),
            ]),
        ],
      ),
    );
  }

  Widget _header(int done) {
    final progress = items.isEmpty ? 0.0 : done / items.length;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 21),
      decoration: BoxDecoration(color: const Color(0xFF111827), borderRadius: BorderRadius.circular(28)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Container(width: 45, height: 45, decoration: BoxDecoration(color: const Color(0xFFC7F36B), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF111827))), const SizedBox(width: 13), const Text('E I N K A U F', style: TextStyle(color: Color(0xFFC7F36B), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.7))]),
        const SizedBox(height: 16),
        const Text('Deine Einkaufsliste', style: TextStyle(color: Colors.white, fontSize: 29, height: 1, fontWeight: FontWeight.w900, letterSpacing: -.8)),
        const SizedBox(height: 17),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFF1D293A), borderRadius: BorderRadius.circular(16)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$done/${items.length} Artikel erledigt', style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 6, backgroundColor: Colors.white12, valueColor: const AlwaysStoppedAnimation(Color(0xFFC7F36B)))),
        ])),
      ]),
    );
  }

  Widget _item(dynamic i) {
    final id = itemId(i);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: ValueKey('$id-${name(i)}'),
        direction: DismissDirection.horizontal,
        background: _swipeBg(const Color(0xFFC7F36B), Icons.check_rounded, 'ERLEDIGT', Alignment.centerLeft),
        secondaryBackground: _swipeBg(const Color(0xFFFFE4E8), Icons.delete_outline_rounded, 'LÖSCHEN', Alignment.centerRight),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            final newValue = !checked(i);
            await weekApi.check(id, newValue);
            if (i is Map) { i['checked'] = newValue; i['isChecked'] = newValue; }
            if (mounted) setState(() {});
            return false;
          }
          await weekApi.deleteItem(id);
          return true;
        },
        onDismissed: (_) => setState(() => items.remove(i)),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => edit(i),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
            child: Row(children: [
              Container(width: 24, height: 24, decoration: BoxDecoration(color: checked(i) ? const Color(0xFFC7F36B) : const Color(0xFFF2F3F5), shape: BoxShape.circle), child: checked(i) ? const Icon(Icons.check_rounded, size: 16, color: Color(0xFF111827)) : null),
              const SizedBox(width: 12),
              Expanded(child: Text(name(i), style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, decoration: checked(i) ? TextDecoration.lineThrough : null, color: checked(i) ? Colors.black38 : const Color(0xFF171B24)))),
              if (amount(i).isNotEmpty) Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7), decoration: BoxDecoration(color: const Color(0xFFF1F2F4), borderRadius: BorderRadius.circular(14)), child: Text(amount(i), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF737A86)))),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _swipeBg(Color color, IconData icon, String text, Alignment alignment) => Container(alignment: alignment, padding: const EdgeInsets.symmetric(horizontal: 22), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon), const SizedBox(width: 7), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1))]));

  Future<void> edit(dynamic i) async {
    var editedName = name(i);
    var editedQuantity =
        '${i is Map ? (i['quantity'] ?? i['amount'] ?? '') : ''}';
    var editedCategory = category(i);

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Artikel bearbeiten'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: editedName,
              onChanged: (value) => editedName = value,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: editedQuantity,
              onChanged: (value) => editedQuantity = value,
              decoration: const InputDecoration(labelText: 'Menge'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              initialValue: editedCategory,
              onChanged: (value) => editedCategory = value,
              decoration: const InputDecoration(labelText: 'Kategorie'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () async {
              await weekApi.edit(
                itemId(i),
                editedName,
                editedQuantity,
                editedCategory,
              );
              if (dialogContext.mounted) Navigator.pop(dialogContext);
              await load();
            },
            child: const Text('Speichern'),
          ),
        ],
      ),
    );
  }
}
