import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/beissab_api.dart';

import '../core/session.dart';

import '../widgets/common.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen>
    with SingleTickerProviderStateMixin {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  List<dynamic> meals = [];

  final selected = <dynamic>[];

  int index = 0;

  int refresh = 0;

  bool loading = true;

  bool _voting = false;

  Map<String, dynamic>? _activeWeek;

  List<dynamic>? _orderedWeekDays;

  String household = 'family';

  String diet = 'all';

  int time = 25;

  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final u = session.user ?? {};

    household =
        (u['householdType'] ?? u['household_type'] ?? 'family').toString();

    diet = (u['dietType'] ?? u['diet_type'] ?? 'all').toString();

    time = int.tryParse(
          '${u['maxCookingTime'] ?? u['max_cooking_time'] ?? 25}',
        ) ??
        25;

    await _loadHome();
  }

  Future<void> _loadHome() async {
    try {
      final w = await weekApi.active();

      final days = (w['days'] as List?) ?? const [];

      if (days.isNotEmpty) {
        final orderedDays =
            await _applyStoredRecipeOrder(List<dynamic>.from(days));

        if (mounted) {
          setState(() {
            _activeWeek = w;

            _orderedWeekDays = orderedDays;

            loading = false;
          });
        }

        return;
      }
    } catch (_) {}

    await load();
  }

  Future<void> load() async {
    setState(() => loading = true);

    try {
      meals = await mealApi.suggestions(
        householdType: household,
        dietType: diet,
        maxCookingTime: time,
        refreshKey: refresh,
        excludeIds: selected,
      );

      index = 0;

      _dragOffset = Offset.zero;
    } catch (x) {
      if (mounted) snack(context, '$x');
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> vote(bool yes) async {
    if (_voting || index >= meals.length) return;

    _voting = true;

    final m = meals[index];

    final id = mealId(m);

    if (yes && id != null) {
      selected.add(id);
    }

    try {
      if (m is Map && m['suggestionId'] != null) {
        await mealApi.status(
          m['suggestionId'],
          yes ? 'accepted' : 'rejected',
        );
      }
    } catch (_) {
      // Die nächste Karte soll trotzdem angezeigt werden.
    }

    if (yes && selected.length >= 7) {
      try {
        final w = await weekApi.create(selected.take(7).toList());

        if (mounted) {
          setState(() {
            _activeWeek = w;

            _orderedWeekDays = (w['days'] as List?)?.cast<dynamic>();

            _dragOffset = Offset.zero;
          });
        }

        _voting = false;

        return;
      } catch (x) {
        if (mounted) snack(context, '$x');
      }
    }

    if (mounted) {
      setState(() {
        index++;

        _dragOffset = Offset.zero;
      });
    }

    _voting = false;
  }

  void _dragUpdate(DragUpdateDetails details) {
    if (_voting) return;

    setState(() {
      _dragOffset += details.delta;
    });
  }

  void _dragEnd(DragEndDetails details) {
    const threshold = 105.0;

    if (_dragOffset.dx > threshold) {
      vote(true);

      return;
    }

    if (_dragOffset.dx < -threshold) {
      vote(false);

      return;
    }

    setState(() {
      _dragOffset = Offset.zero;
    });
  }

  Future<void> _nextSuggestion() async {
    if (_voting || index >= meals.length) return;

    setState(() {
      index++;

      _dragOffset = Offset.zero;
    });

    if (index >= meals.length) {
      refresh++;

      await load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final done = index >= meals.length;

    if (_activeWeek != null) return _weekHome(context);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () {
          refresh++;

          return load();
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 105),
          children: [
            if (loading)
              const SizedBox(
                height: 600,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (done)
              _empty(context)
            else ...[
              _swipeCard(context, meals[index]),
              const SizedBox(height: 24),
              _actionButtons(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _swipeCard(BuildContext context, dynamic meal) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    final rotation = (_dragOffset.dx / screenWidth) * 0.12;

    final swipeStrength = (_dragOffset.dx.abs() / 120).clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: _dragUpdate,
      onPanEnd: _dragEnd,
      child: AnimatedContainer(
        duration: _dragOffset == Offset.zero
            ? const Duration(milliseconds: 220)
            : Duration.zero,
        curve: Curves.easeOutBack,
        transformAlignment: Alignment.center,
        transform: Matrix4.identity()
          ..translate(_dragOffset.dx, _dragOffset.dy * 0.15)
          ..rotateZ(rotation),
        child: Stack(
          children: [
            _mealCard(context, meal),
            if (_dragOffset.dx > 20)
              Positioned(
                top: 32,
                left: 28,
                child: Opacity(
                  opacity: swipeStrength,
                  child: _swipeBadge(
                    'LIKE',
                    Icons.favorite,
                  ),
                ),
              ),
            if (_dragOffset.dx < -20)
              Positioned(
                top: 32,
                right: 28,
                child: Opacity(
                  opacity: swipeStrength,
                  child: _swipeBadge(
                    'WEITER',
                    Icons.close,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _mealCard(BuildContext context, dynamic meal) {
    final category = _category(meal);

    final cookTime = _cookTime(meal);

    final level = _level(meal);

    final type = _type(meal);

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(30),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push(
            '/recipe/${mealId(meal)}',
            extra: meal,
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SizedBox(
                  height: 350,
                  width: double.infinity,
                  child: _image(meal),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'V O R S C H L A G',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2.2,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 9,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F3FF),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFF5964C8),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    mealTitle(meal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          height: 1.0,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: _info(
                          Icons.schedule_outlined,
                          'ZEIT',
                          '$cookTime Min.',
                        ),
                      ),
                      Expanded(
                        child: _info(
                          Icons.speed_outlined,
                          'LEVEL',
                          level,
                        ),
                      ),
                      Expanded(
                        child: _info(
                          Icons.eco_outlined,
                          'TYP',
                          type,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _info(
    IconData icon,
    String title,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: Colors.black38,
            ),
            const SizedBox(width: 5),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black38,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _circleButton(
          icon: Icons.close,
          onPressed: () => vote(false),
        ),
        const SizedBox(width: 28),
        _circleButton(
          icon: Icons.refresh_rounded,
          onPressed: _nextSuggestion,
        ),
        const SizedBox(width: 28),
        _circleButton(
          icon: Icons.favorite,
          primary: true,
          onPressed: () => vote(true),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onPressed,
    bool primary = false,
  }) {
    return Material(
      color: primary ? const Color(0xFFFF315E) : Colors.white,
      elevation: primary ? 8 : 2,
      shadowColor: primary ? const Color(0x55FF315E) : Colors.black12,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _voting ? null : onPressed,
        child: SizedBox(
          width: primary ? 68 : 62,
          height: primary ? 68 : 62,
          child: Icon(
            icon,
            size: primary ? 32 : 29,
            color: primary ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _swipeBadge(
    String text,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              letterSpacing: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _image(dynamic meal) {
    final url = mealImage(meal);

    if (url != null && url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    final file = url?.split('/').last;

    if (file != null) {
      return Image.asset(
        'assets/images/${file.replaceAll('.png', '.webp')}',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imageFallback(),
      );
    }

    return _imageFallback();
  }

  Widget _imageFallback() {
    return Container(
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant_rounded,
        size: 70,
        color: Colors.black26,
      ),
    );
  }

  String _category(dynamic meal) {
    if (meal is! Map) return 'Gericht';

    return '${meal['category'] ?? meal['mealType'] ?? 'Gericht'}';
  }

  int _cookTime(dynamic meal) {
    if (meal is! Map) return time;

    return int.tryParse(
          '${meal['cookTime'] ?? meal['cookingTime'] ?? time}',
        ) ??
        time;
  }

  String _level(dynamic meal) {
    if (meal is! Map) return 'einfach';

    final value = meal['difficulty'] ?? meal['level'] ?? 'einfach';

    return '$value';
  }

  String _type(dynamic meal) {
    if (meal is! Map) return 'Gericht';

    final value =
        meal['dietType'] ?? meal['diet_type'] ?? meal['type'] ?? 'Gericht';

    final text = '$value';

    switch (text.toLowerCase()) {
      case 'vegetarian':
        return 'vegetarisch';

      case 'vegan':
        return 'vegan';

      case 'pescatarian':
        return 'Fisch';

      case 'all':
        return 'gemischt';

      default:
        return text;
    }
  }

  dynamic _recipeFromDay(dynamic d) {
    if (d is! Map) return null;

    return d['recipe'] ??
        d['meal'] ??
        d['menu'] ??
        ((d['recipes'] is List && (d['recipes'] as List).isNotEmpty)
            ? d['recipes'][0]
            : null);
  }

  dynamic _mealStorageId(dynamic meal) {
    if (meal is! Map) return null;

    return meal['id'] ?? meal['mealId'] ?? meal['recipeId'];
  }

  String _dayStorageId(dynamic day, int index) {
    if (day is! Map) return '$index';

    return '${day['id'] ?? day['dayId'] ?? day['dayIndex'] ?? index}';
  }

  String _planOrderStorageKey(List<dynamic> days) {
    final firstDay =
        days.isNotEmpty && days.first is Map ? days.first as Map : null;

    final weekId = firstDay?['weekId'] ?? firstDay?['week_id'] ?? 'active';

    return 'mealplan_day_recipe_order_$weekId';
  }

  Future<List<dynamic>> _applyStoredRecipeOrder(
    List<dynamic> serverDays,
  ) async {
    if (serverDays.isEmpty) return serverDays;

    final storageKey = _planOrderStorageKey(serverDays);

    final saved = await _storage.read(key: storageKey);

    if (saved == null || saved.isEmpty) {
      return serverDays;
    }

    try {
      final decoded = jsonDecode(saved);

      if (decoded is! Map) {
        return serverDays;
      }

      final recipesById = <String, dynamic>{};

      for (final day in serverDays) {
        final recipe = _recipeFromDay(day);

        final recipeId = _mealStorageId(recipe);

        if (recipeId != null) {
          recipesById['$recipeId'] = recipe;
        }
      }

      return List<dynamic>.generate(serverDays.length, (index) {
        final day = serverDays[index];

        if (day is! Map) return day;

        final dayId = _dayStorageId(day, index);

        final recipeIdForThisDay = decoded[dayId];

        if (recipeIdForThisDay == null) {
          return day;
        }

        final recipe = recipesById['$recipeIdForThisDay'];

        if (recipe == null) {
          return day;
        }

        return <String, dynamic>{
          ...Map<String, dynamic>.from(day),
          'recipe': recipe,
          'meal': recipe,
          'recipes': [recipe],
        };
      });
    } catch (_) {
      await _storage.delete(key: storageKey);

      return serverDays;
    }
  }

  Widget _weekHome(BuildContext context) {
    final w = _activeWeek!;
    final serverDays = (w['days'] as List?) ?? const [];
    final days = _orderedWeekDays ?? serverDays;
    final shopping = (w['shoppingItems'] as List?) ?? const [];

    final open = shopping
        .where(
          (x) => !(x is Map &&
              ((x['checked'] ?? x['isChecked']) == true ||
                  (x['checked'] ?? x['isChecked']) == 1)),
        )
        .length;

    dynamic today;

    if (days.isNotEmpty) {
      final todayIndex = DateTime.now().weekday - 1;
      if (todayIndex >= 0 && todayIndex < days.length) {
        today = _recipeFromDay(days[todayIndex]);
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        _activeWeek = null;
        _orderedWeekDays = null;
        await _loadHome();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(30, 24, 30, 116),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: SizedBox(
              height: 320,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (today == null) _imageFallback() else _image(today),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 1.0],
                        colors: [Color(0x00000000), Color(0xB8000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    right: 24,
                    bottom: 25,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HEUTE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2.2,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          today == null
                              ? 'Dein Wochenplan ist bereit'
                              : mealTitle(today),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            height: 1.28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.7,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          '${days.length} Gerichte geplant  ·  $open Einkäufe offen',
                          style: const TextStyle(
                            color: Color(0xFFD7D9DE),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFFE7EBF1)),
            ),
            child: Column(
              children: [
                _pwaHomeAction(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Jetzt kochen',
                  subtitle: 'Rezept ansehen',
                  darkIcon: true,
                  onTap: today == null
                      ? null
                      : () => context.push(
                            '/recipe/${mealId(today)}',
                            extra: today,
                          ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEEF1F5),
                  ),
                ),
                _pwaHomeAction(
                  icon: Icons.shopping_cart_outlined,
                  title: 'Einkaufsliste',
                  subtitle: '$open noch offen',
                  onTap: () => context.go('/shopping'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF9AADC7),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () async {
                await weekApi.remove();
                if (mounted) {
                  setState(() {
                    _activeWeek = null;
                    _orderedWeekDays = null;
                    selected.clear();
                    refresh++;
                  });
                  await load();
                }
              },
              icon: const Icon(Icons.undo_rounded, size: 19),
              label: const Text(
                'Komplette Woche löschen',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pwaHomeAction({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool darkIcon = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: darkIcon
                        ? const Color(0xFF020817)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    icon,
                    size: 22,
                    color: darkIcon ? Colors.white : const Color(0xFF40516A),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Color(0xFF0B1020),
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFF71819B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Text(
                    'Öffnen',
                    style: TextStyle(
                      color: Color(0xFF40516A),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 70,
              ),
              const SizedBox(height: 14),
              Text(
                selected.isEmpty
                    ? 'Keine weiteren Vorschläge'
                    : '${selected.length} Gerichte ausgewählt',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Du kannst neue Vorschläge laden oder aus deiner Auswahl eine Woche erstellen.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              AsyncButton(
                label: 'Wochenplan erstellen',
                onPressed: selected.isEmpty
                    ? null
                    : () async {
                        try {
                          await weekApi.create(selected);

                          if (mounted) {
                            context.go('/plan');
                          }
                        } catch (x) {
                          if (mounted) {
                            snack(context, '$x');
                          }
                        }
                      },
              ),
              TextButton(
                onPressed: () {
                  refresh++;

                  load();
                },
                child: const Text('Neue Vorschläge'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
