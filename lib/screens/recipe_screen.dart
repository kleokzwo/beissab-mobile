import 'package:flutter/material.dart';
import '../api/beissab_api.dart';
import '../widgets/common.dart';

class RecipeScreen extends StatefulWidget {
  final dynamic id, initial;

  const RecipeScreen({
    required this.id,
    this.initial,
    super.key,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _navy = Color(0xFF111827);
  //static const Color _text = Color(0xFF1D2433);
  static const Color _muted = Color(0xFF7D8798);
  static const Color _purple = Color(0xFF6758D6);
  static const Color _border = Color(0xFFE8EBF0);
  static const Color _soft = Color(0xFFF4F5F7);

  List<dynamic> ingredients = [];
  List<dynamic> steps = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final r = await Future.wait([
        mealApi.ingredients(widget.id),
        mealApi.steps(widget.id),
      ]);

      ingredients = r[0];
      steps = r[1];
    } catch (x) {
      if (mounted) {
        snack(context, '$x');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  dynamic _value(dynamic source, List<String> keys) {
    if (source is! Map) {
      return null;
    }

    for (final key in keys) {
      final value = source[key];

      if (value != null && value.toString().trim().isNotEmpty) {
        return value;
      }
    }

    return null;
  }

  String _textValue(
    dynamic source,
    List<String> keys, {
    String fallback = '–',
  }) {
    final value = _value(source, keys);

    if (value == null) {
      return fallback;
    }

    return value.toString();
  }

  String _cookTime(dynamic meal) {
    final value = _value(
      meal,
      [
        'cookTime',
        'cookingTime',
        'cooking_time',
        'maxCookingTime',
        'max_cooking_time',
      ],
    );

    if (value == null) {
      return '–';
    }

    final text = value.toString();

    if (text.toLowerCase().contains('min')) {
      return text;
    }

    return '$text Min.';
  }

  String _ingredientName(dynamic ingredient) {
    return _textValue(
      ingredient,
      [
        'name',
        'ingredientName',
        'ingredient_name',
      ],
      fallback: ingredient?.toString() ?? '',
    );
  }

  String _ingredientAmount(dynamic ingredient) {
    if (ingredient is! Map) {
      return '';
    }

    final amount = ingredient['quantity'] ?? ingredient['amount'];
    final unit = ingredient['unit'];

    return [
      amount,
      unit,
    ]
        .where(
          (value) => value != null && value.toString().trim().isNotEmpty,
        )
        .join(' ');
  }

  String _ingredientCategory(dynamic ingredient) {
    return _textValue(
      ingredient,
      [
        'category',
        'categoryName',
        'category_name',
        'group',
      ],
      fallback: 'Zutaten',
    );
  }

  Map<String, List<dynamic>> _groupedIngredients() {
    final groups = <String, List<dynamic>>{};

    for (final ingredient in ingredients) {
      final category = _ingredientCategory(ingredient);

      groups.putIfAbsent(category, () => []);
      groups[category]!.add(ingredient);
    }

    return groups;
  }

  String _stepText(dynamic step) {
    if (step is! Map) {
      return step?.toString() ?? '';
    }

    return _textValue(
      step,
      [
        'description',
        'text',
        'instruction',
      ],
      fallback: '',
    );
  }

  List<String> _tags(dynamic meal) {
    if (meal is! Map) {
      return [];
    }

    final raw = meal['tags'];

    if (raw is List) {
      return raw
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }

    return [];
  }

  String _household(dynamic meal) {
    final value = _textValue(
      meal,
      [
        'household',
        'householdType',
        'household_type',
      ],
      fallback: 'All',
    );

    switch (value.toLowerCase()) {
      case 'single':
        return 'Single';

      case 'paar':
      case 'couple':
        return 'Paar';

      case 'familie':
      case 'family':
        return 'Familie';

      case 'all':
        return 'All';

      default:
        return value;
    }
  }

  String _familyFriendly(dynamic meal) {
    final value = _value(
      meal,
      [
        'familyFriendly',
        'family_friendly',
        'isFamilyFriendly',
      ],
    );

    if (value == null) {
      return 'Ja';
    }

    if (value == true ||
        value == 1 ||
        value.toString().toLowerCase() == 'true') {
      return 'Ja';
    }

    return 'Nein';
  }

  @override
  Widget build(BuildContext context) {
    final meal = widget.initial;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  10,
                  14,
                  30,
                ),
                children: [
                  _buildHero(meal),
                  const SizedBox(height: 14),
                  _buildIngredients(),
                  const SizedBox(height: 12),
                  _buildSuitableFor(meal),
                  const SizedBox(height: 12),
                  _buildTags(meal),
                  const SizedBox(height: 12),
                  _buildPreparation(),
                ],
              ),
      ),
    );
  }

  Widget _buildHero(dynamic meal) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        14,
        12,
        14,
        16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE7F7C9),
            Color(0xFFCFF7E9),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBackButton(),
          const SizedBox(height: 22),
          const Text(
            'R E Z E P T D E T A I L S',
            style: TextStyle(
              color: Color(0xFF6C8B72),
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mealTitle(meal),
            style: const TextStyle(
              color: _navy,
              fontSize: 30,
              height: 1.08,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.66,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      _buildMetaBox(
                        'Kategorie',
                        _textValue(
                          meal,
                          [
                            'category',
                            'categoryName',
                            'category_name',
                            'type',
                          ],
                          fallback: '–',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMetaBox(
                        'Kochzeit',
                        _cookTime(meal),
                        icon: Icons.schedule_rounded,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      _buildMetaBox(
                        'Ernährung',
                        _textValue(
                          meal,
                          [
                            'dietType',
                            'diet_type',
                            'diet',
                          ],
                          fallback: '–',
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildMetaBox(
                        'Schwierigkeit',
                        _textValue(
                          meal,
                          [
                            'difficulty',
                            'level',
                          ],
                          fallback: '–',
                        ),
                        icon: Icons.tune_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Navigator.of(context).maybePop();
        },
        child: const SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            Icons.arrow_back_rounded,
            size: 19,
            color: _navy,
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBox(
    String label,
    String value, {
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(
        minHeight: 64,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.72,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 13,
                  color: _muted,
                ),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredients() {
    final groups = _groupedIngredients();

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.shopping_basket_outlined,
            'ZUTATEN',
          ),
          const SizedBox(height: 18),
          if (ingredients.isEmpty)
            const Text(
              'Keine Zutaten verfügbar.',
              style: TextStyle(
                color: _muted,
                fontSize: 14,
              ),
            )
          else
            ...groups.entries.map(
              (group) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 17,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.key,
                      style: const TextStyle(
                        color: _navy,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    ...group.value.map(
                      (ingredient) => Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 9,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: _border,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(
                                top: 1,
                              ),
                              child: Text(
                                '•',
                                style: TextStyle(
                                  color: _navy,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                _ingredientName(
                                  ingredient,
                                ),
                                style: const TextStyle(
                                  color: Color(
                                    0xFF465267,
                                  ),
                                  fontSize: 13,
                                  height: 1.35,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _ingredientAmount(
                                ingredient,
                              ),
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(
                                  0xFF465267,
                                ),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSuitableFor(dynamic meal) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.groups_outlined,
            'PASST GUT ZU',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _smallInfoCard(
                  'Familienfreundlich',
                  _familyFriendly(meal),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _smallInfoCard(
                  'Haushalt',
                  _household(meal),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTags(dynamic meal) {
    final tags = _tags(meal);

    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.sell_outlined,
            'TAGS',
          ),
          const SizedBox(height: 14),
          if (tags.isEmpty)
            const Text(
              'Keine Tags verfügbar.',
              style: TextStyle(
                color: _muted,
                fontSize: 14,
              ),
            )
          else
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: tags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 11,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFF0F2F5,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: _muted,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPreparation() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.menu_book_outlined,
            'ZUBEREITUNG',
          ),
          const SizedBox(height: 16),
          if (steps.isEmpty)
            const Text(
              'Keine Zubereitungsschritte verfügbar.',
              style: TextStyle(
                color: _muted,
                fontSize: 14,
              ),
            )
          else
            ...steps.asMap().entries.map(
                  (entry) => Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(
                      bottom: 9,
                    ),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _soft,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Schritt ${entry.key + 1}',
                          style: const TextStyle(
                            color: _navy,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepText(entry.value),
                          style: const TextStyle(
                            color: Color(0xFF4F5B70),
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _border,
        ),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: _purple,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: _purple,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _smallInfoCard(
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _muted,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: _navy,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
