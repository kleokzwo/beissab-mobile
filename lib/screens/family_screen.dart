import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../api/beissab_api.dart';
import '../core/session.dart';
import '../widgets/common.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyState();
}

class _FamilyState extends State<FamilyScreen> {
  String household = 'single';
  String diet = 'all';
  int children = 1;
  int time = 25;
  bool busy = false;

  static const _pageBackground = Color(0xFFF7F9FC);
  static const _ink = Color(0xFF0D1222);
  static const _muted = Color(0xFF64748B);
  static const _soft = Color(0xFFF0F4F9);

  @override
  void initState() {
    super.initState();

    final user = session.user ?? {};

    household = (user['householdType'] ??
            user['household_type'] ??
            'single')
        .toString();
    diet = (user['dietType'] ?? user['diet_type'] ?? 'all').toString();
    children = int.tryParse(
          '${user['childrenCount'] ?? user['children_count'] ?? 1}',
        ) ??
        1;
    time = int.tryParse(
          '${user['maxCookingTime'] ?? user['max_cooking_time'] ?? 25}',
        ) ??
        25;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leadingWidth: 78,
        leading: Padding(
          padding: const EdgeInsets.only(left: 18, top: 7, bottom: 7),
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => context.pop(),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: _ink,
                size: 24,
              ),
            ),
          ),
        ),
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'B E I S S A B',
              style: TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Familie',
              style: TextStyle(
                color: _ink,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: Color(0xFFE5EAF1)),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 15, 24, 72),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 19),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFDFA7), Color(0xFFFFF8C7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.people_outline_rounded,
                    color: Color(0xFFFF6B00), size: 27),
                SizedBox(height: 17),
                Text(
                  'Haushalt verwalten',
                  style: TextStyle(
                    color: _ink,
                    fontSize: 26,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.7,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  'Damit die Rezeptvorschläge besser zu deinem Alltag passen.',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 12.5,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _sectionCard(
            icon: Icons.people_outline_rounded,
            title: 'Haushalt',
            subtitle: 'Diese Auswahl steuert Portionen und Familienlogik.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: _choice('Single', 'single', household, (v) => household = v)),
                    const SizedBox(width: 8),
                    Expanded(child: _choice('Paar', 'paar', household, (v) => household = v)),
                    const SizedBox(width: 8),
                    Expanded(child: _choice('Familie', 'familie', household, (v) => household = v)),
                  ],
                ),
                if (household == 'familie') ...[
                  const SizedBox(height: 18),
                  const Text(
                    'Anzahl Kinder',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 9),
                  DropdownButtonFormField<int>(
                    value: children.clamp(1, 12),
                    decoration: _dropdownDecoration(),
                    items: List.generate(12, (index) => index + 1)
                        .map((value) => DropdownMenuItem(
                              value: value,
                              child: Text('$value'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) setState(() => children = value);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            icon: Icons.eco_outlined,
            title: 'Ernährung',
            subtitle: 'Diese Auswahl filtert deine Rezeptvorschläge.',
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: _choice('Alles', 'all', diet, (v) => diet = v)),
                    const SizedBox(width: 8),
                    Expanded(child: _choice('Vegetarisch', 'vegetarian', diet, (v) => diet = v)),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: [
                    Expanded(child: _choice('Vegan', 'vegan', diet, (v) => diet = v)),
                    const SizedBox(width: 8),
                    Expanded(child: _choice('Fisch', 'pescatarian', diet, (v) => diet = v)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            icon: Icons.restaurant_menu_rounded,
            title: 'Kochzeit',
            subtitle: 'Diese Auswahl filtert deine Kochzeit.',
            child: Column(
              children: [
                _timeRow(15, 20),
                const SizedBox(height: 7),
                _timeRow(25, 30),
                const SizedBox(height: 7),
                _timeRow(35, 45),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: FilledButton(
              onPressed: busy ? null : _save,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF020817),
                disabledBackgroundColor: const Color(0xFF020817),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Speichern',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDDE3EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _soft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 20, color: const Color(0xFF2F3C52)),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: _ink,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: _muted,
                        fontSize: 12,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _choice(
    String label,
    String value,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    final active = selected == value;
    return SizedBox(
      height: 39,
      child: Material(
        color: active ? const Color(0xFF020817) : _soft,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          onTap: () => setState(() => onSelected(value)),
          borderRadius: BorderRadius.circular(13),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : const Color(0xFF40516A),
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _timeRow(int left, int right) {
    return Row(
      children: [
        Expanded(child: _timeChoice(left)),
        const SizedBox(width: 8),
        Expanded(child: _timeChoice(right)),
      ],
    );
  }

  Widget _timeChoice(int value) {
    return _choice('bis $value minute', '$value', '$time', (selected) {
      time = int.parse(selected);
    });
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFDDE3EC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF94A3B8)),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => busy = true);

    try {
      await userApi.household({
        'householdType': household,
        'childrenCount': household == 'familie' ? children : 0,
        'dietType': diet,
        'maxCookingTime': time,
      });

      // PATCH kann nur Status/Message liefern. Deshalb danach den Benutzer
      // erneut vom Backend laden, damit Session und spätere Screens garantiert
      // die tatsächlich gespeicherten Werte verwenden.
      session.user = await userApi.me();

      if (mounted) snack(context, 'Gespeichert.');
    } catch (error) {
      if (mounted) snack(context, '$error');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}
