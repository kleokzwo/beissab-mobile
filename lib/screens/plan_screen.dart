import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../api/beissab_api.dart';
import '../widgets/common.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});
  @override State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> with SingleTickerProviderStateMixin {
  Map<String, dynamic>? week;
  List<dynamic> days = [];
  bool loading = true;
  bool editMode = false;
  int? swapFrom;
  late final AnimationController _wiggle;

  @override
  void initState() {
    super.initState();
    _wiggle = AnimationController(vsync: this, duration: const Duration(milliseconds: 180))..repeat(reverse: true);
    load();
  }

  @override void dispose() { _wiggle.dispose(); super.dispose(); }

  Future<void> load() async {
    setState(() => loading = true);
    try {
      week = await weekApi.active();
      days = List<dynamic>.from((week?['days'] as List?) ?? const []);
    } catch (_) {
      week = null; days = [];
    } finally { if (mounted) setState(() => loading = false); }
  }

  dynamic recipe(dynamic d) {
    if (d is! Map) return null;
    return d['recipe'] ?? d['meal'] ?? d['menu'] ?? ((d['recipes'] is List && (d['recipes'] as List).isNotEmpty) ? d['recipes'][0] : null);
  }

  String dayName(dynamic d, int i) {
    if (d is Map) return '${d['dayName'] ?? d['name'] ?? d['weekday'] ?? _fallbackDay(i)}';
    return _fallbackDay(i);
  }

  String _fallbackDay(int i) => const ['MONTAG','DIENSTAG','MITTWOCH','DONNERSTAG','FREITAG','SAMSTAG','SONNTAG'][i.clamp(0, 6)];

  void _swap(int a, int b) {
    if (a == b) return;
    setState(() { final tmp = days[a]; days[a] = days[b]; days[b] = tmp; swapFrom = null; });
  }

  void _tapCard(int i, dynamic meal) {
    if (!editMode) { if (meal != null) context.push('/recipe/${mealId(meal)}', extra: meal); return; }
    if (swapFrom == null) { setState(() => swapFrom = i); } else { _swap(swapFrom!, i); }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: load,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 116),
        children: [
          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('D I E S E   W O C H E', style: TextStyle(color: Color(0xFF6657C8), fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const SizedBox(height: 7),
              const Text('Dein Wochenplan', style: TextStyle(fontSize: 30, height: 1, fontWeight: FontWeight.w900, letterSpacing: -1)),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8), decoration: BoxDecoration(color: const Color(0xFFF0F1F5), borderRadius: BorderRadius.circular(18)), child: Text('${days.length} Gerichte eingeplant', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF687080)))),
            ])),
            if (days.isNotEmpty) IconButton.filledTonal(onPressed: () => setState(() { editMode = !editMode; swapFrom = null; }), icon: Icon(editMode ? Icons.check_rounded : Icons.swap_horiz_rounded)),
          ]),
          if (editMode) ...[
            const SizedBox(height: 12),
            const Text('Tag lange halten und ziehen – oder zwei Karten antippen, um sie zu tauschen.', style: TextStyle(fontSize: 12, color: Color(0xFF747B89))),
          ],
          const SizedBox(height: 22),
          if (loading)
            const SizedBox(height: 420, child: Center(child: CircularProgressIndicator()))
          else if (days.isEmpty)
            _empty()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 14, childAspectRatio: .74),
              itemBuilder: (_, i) => _dropTarget(i),
            ),
          if (days.isNotEmpty) ...[
            const SizedBox(height: 24),
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF7D8491)),
              onPressed: () async { await weekApi.remove(); await load(); },
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
              label: const Text('Komplette Woche löschen', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _dropTarget(int i) {
    final card = _dayCard(i);
    return DragTarget<int>(
      onWillAcceptWithDetails: (d) => editMode && d.data != i,
      onAcceptWithDetails: (d) => _swap(d.data, i),
      builder: (_, candidate, __) => AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: candidate.isNotEmpty ? BoxDecoration(border: Border.all(color: const Color(0xFF6657C8), width: 2), borderRadius: BorderRadius.circular(23)) : null,
        child: editMode
            ? LongPressDraggable<int>(
                data: i,
                feedback: Material(color: Colors.transparent, child: SizedBox(width: 170, height: 225, child: _dayCard(i, feedback: true))),
                childWhenDragging: Opacity(opacity: .3, child: card),
                child: card,
              )
            : card,
      ),
    );
  }

  Widget _dayCard(int i, {bool feedback = false}) {
    final d = days[i];
    final meal = recipe(d);
    final selected = swapFrom == i;
    final content = GestureDetector(
      onLongPress: feedback ? null : () => setState(() { editMode = true; swapFrom = null; }),
      onTap: feedback ? null : () => _tapCard(i, meal),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: selected ? Border.all(color: const Color(0xFF6657C8), width: 2) : null, boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 16, offset: Offset(0, 5))]),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Stack(fit: StackFit.expand, children: [
            _mealImage(meal),
            Positioned(top: 10, right: 9, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: Colors.white.withValues(alpha: .92), borderRadius: BorderRadius.circular(16)), child: Text(_category(meal), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF5F62B7))))),
          ])),
          Padding(padding: const EdgeInsets.fromLTRB(13, 12, 12, 15), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dayName(d, i).toUpperCase(), style: const TextStyle(color: Color(0xFFABB0BA), fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 1.4)),
            const SizedBox(height: 5),
            Text(meal == null ? 'Noch frei' : mealTitle(meal), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, height: 1.05, fontWeight: FontWeight.w900)),
          ])),
        ]),
      ),
    );
    if (!editMode || feedback) return content;
    return AnimatedBuilder(animation: _wiggle, builder: (_, child) { final phase = i.isEven ? 1.0 : -1.0; final angle = (_wiggle.value - .5) * .022 * phase; return Transform.rotate(angle: angle * math.pi, child: child); }, child: content);
  }

  Widget _mealImage(dynamic meal) {
    final u = mealImage(meal);
    if (u != null && u.startsWith('http')) return Image.network(u, fit: BoxFit.cover, errorBuilder: (_,__,___) => _fallback());
    final f = u?.split('/').last;
    if (f != null) return Image.asset('assets/images/${f.replaceAll('.png', '.webp')}', fit: BoxFit.cover, errorBuilder: (_,__,___) => _fallback());
    return _fallback();
  }
  Widget _fallback() => Container(color: const Color(0xFFF0F1F3), alignment: Alignment.center, child: const Icon(Icons.restaurant_rounded, color: Colors.black26, size: 42));
  String _category(dynamic m) => m is Map ? '${m['category'] ?? m['mealType'] ?? 'Gericht'}' : 'Gericht';

  Widget _empty() => Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)), child: Column(children: [const Icon(Icons.calendar_month_outlined, size: 54, color: Color(0xFF9CA3AF)), const SizedBox(height: 12), const Text('Noch kein Wochenplan.', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)), const SizedBox(height: 14), FilledButton(onPressed: () => context.go('/app'), child: const Text('Gerichte auswählen'))]));
}
